: "${PW_KEEPASSXC:="/Applications/KeePassXC.app/Contents/MacOS/keepassxc-cli"}"

_set_password() {
  if [[ ! -v PW_KEEPASSXC_PASSWORD ]]; then
    read -rsp "Enter password to unlock ${PW_KEYCHAIN}:"$'\n' PW_KEEPASSXC_PASSWORD </dev/tty
  fi
}

_keepassxc-cli() { "${PW_KEEPASSXC}" "$@"; }
_keepassxc-cli_with_db_password() { _set_password; _keepassxc-cli "$@" <<< "${PW_KEEPASSXC_PASSWORD}"; }
_keepassxc-cli_with_db_password_and_entry_password() {
  _set_password
  local password="$1"; shift
  _keepassxc-cli "$@" << EOF
${PW_KEEPASSXC_PASSWORD}
${password}
EOF
}

PW_ENTRY=""
declare -ig PW_FZF=0

pw::init() { _keepassxc-cli db-create -p "${PW_KEYCHAIN}"; }
pw::open() { open -a "KeePassXC" "${PW_KEYCHAIN}"; }
pw::lock() { echo "not available for keepassxc-cli"; }
pw::unlock() { _keepassxc-cli open "${PW_KEYCHAIN}"; }

pw::add() {
  _addOrEdit 0 "$@"
}

pw::edit() {
  pw::select_entry_with_prompt edit "$@"
  _addOrEdit 1 "${PW_ENTRY}"
}

_addOrEdit() {
  local -i edit=$1; shift
  local entry account
  entry="$1" account="${2:-}"
  pw::prompt_password "${entry}"

  if ((edit))
  then _keepassxc-cli_with_db_password_and_entry_password "${PW_PASSWORD}" edit -qp "${PW_KEYCHAIN}" "${entry}"
  else _keepassxc-cli_with_db_password_and_entry_password "${PW_PASSWORD}" add -qp "${PW_KEYCHAIN}" -u "${account}" "${entry}"
  fi
}

pw::get() {
  local -i print=$1; shift
  if ((print))
  then pw::select_entry_with_prompt print "$@"
  else pw::select_entry_with_prompt copy "$@"
  fi
  local password
  password="$(_keepassxc-cli_with_db_password show -qsa Password "${PW_KEYCHAIN}" "${PW_ENTRY}")"
  if ((print)); then
    echo "${password}"
  else
    pw::clip_and_forget "${password}"
  fi
}

pw::rm() {
  local -i remove=1
  pw::select_entry_with_prompt remove "$@"
  if ((PW_FZF)); then
    read -rp "Do you really want to remove ${PW_ENTRY} from ${PW_KEYCHAIN}? (y / n): "
    [[ "${REPLY}" == "y" ]] || remove=0
  fi
  ((!remove)) || _keepassxc-cli_with_db_password rm -q "${PW_KEYCHAIN}" "${PW_ENTRY}"
}

pw::list() {
  local list
  if ! list="$(_keepassxc-cli_with_db_password ls -qfR "${PW_KEYCHAIN}" \
    | grep -v -e '/$' -e 'Recycle Bin/' \
    | sort)"
  then
    echo "Error while reading the database ${PW_KEYCHAIN}: Invalid credentials were provided, please try again." >&2
    exit 1
  fi

  [[ "${list}" == "[empty]" ]] || echo "${list}"
}

pw::select_entry_with_prompt() {
  _set_password
  local fzf_prompt="$1"; shift
  if (($#)); then
    PW_ENTRY="$1"
    PW_FZF=0
  else
    local list
    list="$(pw::list)"
    PW_ENTRY="$(echo "${list}" | fzf --prompt="${fzf_prompt}> " --layout=reverse --info=hidden \
              --preview="\"${PW_KEEPASSXC}\" show -q \"${PW_KEYCHAIN}\" {} <<< \"${PW_KEEPASSXC_PASSWORD}\"")"
    [[ -n "${PW_ENTRY}" ]] || exit 1
    # shellcheck disable=SC2034
    PW_FZF=1
  fi
}
