PW_ENTRY=""
declare -ig PW_FZF=0

_gpg() {
  if [[ -v PW_GPG_PASSWORD ]]
  then gpg --quiet --batch --pinentry-mode loopback --passphrase "${PW_GPG_PASSWORD}" "$@"
  else gpg --quiet "$@"
  fi
}

# shellcheck disable=SC2174
_init() { mkdir -m 700 -p "${PW_KEYCHAIN}"; }

pw::init() { _init; }
pw::open() { open "${PW_KEYCHAIN}"; }
pw::lock() { echo "not available for gpg"; }
pw::unlock() { echo "not available for gpg"; }

pw::add() {
  _addOrEdit 0 "$@"
}

pw::edit() {
  pw::select_entry_with_prompt edit "$@"
  _addOrEdit 1 "${PW_ENTRY}"
}

_addOrEdit() {
  local -i edit=$1; shift
  local entry="$1"
  pw::prompt_password "${entry}"
  _init
  local path
  path="$(dirname "${entry}")"
  mkdir -p "${PW_KEYCHAIN}/${path}"

  if ((edit)); then
    _gpg --yes --output "${PW_KEYCHAIN}/${entry}" --encrypt --default-recipient-self <<< "${PW_PASSWORD}"
  else
    if [ "${entry##*.}" == "asc" ]
    then _gpg --output "${PW_KEYCHAIN}/${entry}" --encrypt --armor --default-recipient-self <<< "${PW_PASSWORD}"
    else _gpg --output "${PW_KEYCHAIN}/${entry}" --encrypt --default-recipient-self <<< "${PW_PASSWORD}"
    fi
  fi
}

pw::get() {
  local -i print=$1; shift
  if ((print))
  then pw::select_entry_with_prompt print "$@"
  else pw::select_entry_with_prompt copy "$@"
  fi
  local password
  password="$(_gpg --decrypt "${PW_KEYCHAIN}/${PW_ENTRY}")"
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
    read -rp "Do you really want to remove ${PW_KEYCHAIN}/${PW_ENTRY}? (y / N): "
    [[ "${REPLY}" == "y" ]] || remove=0
  fi
  ((!remove)) || rm "${PW_KEYCHAIN}/${PW_ENTRY}"
}

pw::list() {
  pushd "${PW_KEYCHAIN}" > /dev/null || exit 1
    find . -type f ! -name .DS_Store | sort
  popd > /dev/null || exit 1
}

pw::select_entry_with_prompt() {
  local fzf_prompt="$1"; shift
  if (($#)); then
    PW_ENTRY="$1"
    PW_FZF=0
  else
    local list
    list="$(pw::list)"
    PW_ENTRY="$(echo "${list}" | fzf --prompt="${fzf_prompt}> " --layout=reverse --info=hidden)"
    [[ -n "${PW_ENTRY}" ]] || exit 1
    # shellcheck disable=SC2034
    PW_FZF=1
  fi
}
