load 'test_helper/bats-support/load.bash'
load 'test_helper/bats-assert/load.bash'
load 'test_helper/bats-file/load.bash'
load 'pw-test-helper.bash'

TEST_KEYCHAIN="${BATS_TEST_TMPDIR}/pw_test"
TEST_PASSWORD="pw_test_password"

_gpg() {
  gpg --quiet --homedir "${PROJECT_ROOT}/test/fixtures/.gnupg" \
      --batch --pinentry-mode loopback --passphrase "${TEST_PASSWORD}" "$@"
}

_setup() {
  mkdir "${TEST_KEYCHAIN}"
}

_teardown() {
  rm -rf "${TEST_KEYCHAIN}"
  killall gpg-agent 2> /dev/null || true
}

_not_implemented() {
  echo "Not implemented"
  return 1
}

_add_item_with_name() { _add_item_with_name_and_account "$1" "" "$2"; }
_add_item_with_account() { _not_implemented; }
_add_item_with_name_and_account() {
  local item_name="$1" _="$2" item_pw="$3"
  mkdir -p "${TEST_KEYCHAIN}/$(dirname "${item_name}")"
  run _gpg --output "${TEST_KEYCHAIN}/${item_name}" --encrypt --default-recipient-self <<< "${item_pw}"
  assert_success
}

_update_item_with_name() { _update_item_with_name_and_account "$1" "" "$2"; }
_update_item_with_account() { _not_implemented; }
_update_item_with_name_and_account() {
  run _pp_update_item_with_name "$@"
  assert_success
}
_pp_update_item_with_name() {
  local item_name="$1" item_pw="$3"
  _gpg --yes --output "${TEST_KEYCHAIN}/${item_name}" --encrypt --default-recipient-self <<< "${item_pw}"
}

_delete_item_with_name() {
  local item_name="$1"
  run rm "${TEST_KEYCHAIN}/${item_name}"
  assert_success
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
  run _add_item_with_name_and_account "$@"
  assert_failure
  assert_output --partial "encryption failed: File exists"
}

assert_item_with_name() {
  local item_name="$1" item_pw="$2"
  run _gpg --decrypt "${TEST_KEYCHAIN}/${item_name}"
  assert_success
  assert_output "${item_pw}"
}

assert_item_with_account() {
  _not_implemented
}

assert_item_with_name_and_account() {
  _not_implemented
}

assert_no_item_with_name() {
  local item_name="$1"
  run _gpg --decrypt "${TEST_KEYCHAIN}/${item_name}"
  assert_failure
  assert_output --partial "gpg: decrypt_message failed: No such file or directory"
}

assert_no_item_with_account() {
  _not_implemented
}

assert_no_item_with_name_and_account() {
  _not_implemented
}

assert_deleted_item_with_name() {
  local item_name="$1"
  assert_file_not_exists "${TEST_KEYCHAIN}/${item_name}"
}
