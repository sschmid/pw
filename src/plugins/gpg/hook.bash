# shellcheck disable=SC2034
FILE_TYPE="PGP"
FILE_EXTENSION="gpg"

register() {
  [[ -d "${PW_KEYCHAIN}" ]]
}

register_with_extension() {
  [[ ! -f "$1" && ! -d "$1" ]]
}
