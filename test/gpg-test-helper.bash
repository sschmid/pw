load 'test_helper/bats-support/load.bash'
load 'test_helper/bats-assert/load.bash'
load 'test_helper/bats-file/load.bash'

: "${PW_KEEPASSXC:="/Applications/KeePassXC.app/Contents/MacOS/keepassxc-cli"}"
TEST_KEYCHAIN="${BATS_TEST_TMPDIR}/pw_test.kdbx"
TEST_PASSWORD="pw_test_password"

_keepassxc-cli() {
  "${PW_KEEPASSXC}" "$@"
}

_keepassxc-cli_with_db_password() {
  _keepassxc-cli "$@" <<< "${TEST_PASSWORD}"
}

_keepassxc-cli_with_db_password_and_entry_password() {
  local password="$1"; shift
  _keepassxc-cli "$@" << EOF
${TEST_PASSWORD}
${password}
EOF
}

_setup() {
  _keepassxc-cli_with_db_password_and_entry_password "${TEST_PASSWORD}" db-create -qp "${TEST_KEYCHAIN}"
}

_teardown() {
  rm -f "${TEST_KEYCHAIN}"
}

_not_implemented() {
  echo "Not implemented"
  return 1
}

_add_item_with_name() { _add_item_with_name_and_account "$1" "" "$2"; }
_add_item_with_account() { _not_implemented; }
_add_item_with_name_and_account() {
  run _pp_add_item_with_name_and_account "$@"
  assert_success
}
_pp_add_item_with_name_and_account() {
  local item_name="$1" item_account="$2" item_pw="$3"
  _keepassxc-cli_with_db_password_and_entry_password "${item_pw}" add -qp "${TEST_KEYCHAIN}" -u "${item_account}" "${item_name}"
}

_update_item_with_name() { _update_item_with_name_and_account "$1" "" "$2"; }
_update_item_with_account() { _not_implemented; }
_update_item_with_name_and_account() {
  run _pp_update_item_with_name "$@"
  assert_success
}
_pp_update_item_with_name() {
  local item_name="$1" item_pw="$3"
  _keepassxc-cli_with_db_password_and_entry_password "${item_pw}" edit -qp "${TEST_KEYCHAIN}" "${item_name}"
}

_delete_item_with_name() {
  run _pp__delete_item_with_name "$@"
  assert_success
}
_pp__delete_item_with_name() {
  local item_name="$1"
  _keepassxc-cli_with_db_password rm -q "${TEST_KEYCHAIN}" "${item_name}"
}

_delete_item_with_account() {
  _not_implemented
}

_delete_item_with_name_and_account() {
  _not_implemented
}

assert_fail_add_item_with_name() { assert_fail_add_item_with_name_and_account "$1" "" "$2"; }
assert_fail_add_item_with_account() { _not_implemented; }
assert_fail_add_item_with_name_and_account() {
  run _pp_add_item_with_name_and_account "$@"
  assert_failure
  assert_output "Could not create entry with path $1."
}

assert_item_with_name() {
  local item_name="$1" item_pw="$2"
  run _pp_assert_item_with_name "${item_name}"
  assert_success
  assert_output "${item_pw}"
}
_pp_assert_item_with_name() {
  _keepassxc-cli_with_db_password show -qsa Password "${TEST_KEYCHAIN}" "$1"
}

assert_item_with_account() {
  _not_implemented
}

assert_item_with_name_and_account() {
  _not_implemented
}

assert_no_item_with_name() {
  local item_name="$1"
  run _pp_assert_no_item_with_name "${item_name}"
  assert_failure
  assert_output "Could not find entry with path ${item_name}."
}
_pp_assert_no_item_with_name() {
  _keepassxc-cli_with_db_password show -qsa Password "${TEST_KEYCHAIN}" "$1"
}

assert_no_item_with_account() {
  _not_implemented
}

assert_no_item_with_name_and_account() {
  _not_implemented
}

assert_deleted_item_with_name() {
  local item_name="$1"
  run _pp_assert_deleted_item_with_name "${item_name}"
  assert_success
}
_pp_assert_deleted_item_with_name() {
  _keepassxc-cli_with_db_password show -qsa Password "${TEST_KEYCHAIN}" "/Recycle Bin/$1"
}
