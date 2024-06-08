load 'test_helper/bats-support/load.bash'
load 'test_helper/bats-assert/load.bash'
load 'test_helper/bats-file/load.bash'

TEST_KEYCHAIN="${BATS_TEST_TMPDIR}/pw_test.keychain-db"

_setup() {
  security create-keychain -p pw_test_password "${TEST_KEYCHAIN}"
}

_teardown() {
  security delete-keychain "${TEST_KEYCHAIN}"
}

_add_item_with_name() { _add_item_with_name_and_account "$1" "" "$2"; }
_add_item_with_account() { _add_item_with_name_and_account "" "$1" "$2"; }
_add_item_with_name_and_account() {
  local item_name="$1" item_account="$2" item_pw="$3"
  run security add-generic-password -a "${item_account}" -s "${item_name}" -w "${item_pw}" "${TEST_KEYCHAIN}"
  assert_success
}

_update_item_with_name() { _update_item_with_name_and_account "$1" "" "$2"; }
_update_item_with_account() { _update_item_with_name_and_account "" "$1" "$2"; }
_update_item_with_name_and_account() {
  local item_name="$1" item_account="$2" item_pw="$3"
  run security add-generic-password -U -a "${item_account}" -s "${item_name}" -w "${item_pw}" "${TEST_KEYCHAIN}"
  assert_success
}

_delete_item_with_name() {
  local item_name="$1"
  run security delete-generic-password -s "${item_name}" "${TEST_KEYCHAIN}"
  assert_success
}

_delete_item_with_account() {
  local item_account="$1"
  run security delete-generic-password -a "${item_account}" "${TEST_KEYCHAIN}"
  assert_success
}

_delete_item_with_name_and_account() {
  local item_name="$1" item_account="$2"
  run security delete-generic-password -a "${item_account}" -s "${item_name}" "${TEST_KEYCHAIN}"
  assert_success
}

assert_fail_add_item_with_name() { assert_fail_add_item_with_name_and_account "$1" "" "$2"; }
assert_fail_add_item_with_account() { assert_fail_add_item_with_name_and_account "" "$1" "$2"; }
assert_fail_add_item_with_name_and_account() {
  local item_name="$1" item_account="$2" item_pw="$3"
  run security add-generic-password -a "${item_account}" -s "${item_name}" -w "${item_pw}" "${TEST_KEYCHAIN}"
  assert_failure
  assert_output "security: SecKeychainItemCreateFromContent (${TEST_KEYCHAIN}): The specified item already exists in the keychain."
}

assert_item_with_name() {
  local item_name="$1" item_pw="$2"
  run security find-generic-password -s "${item_name}" -w "${TEST_KEYCHAIN}"
  assert_success
  assert_output "${item_pw}"
}

assert_item_with_account() {
  local item_account="$1" item_pw="$2"
  run security find-generic-password -a "${item_account}" -w "${TEST_KEYCHAIN}"
  assert_success
  assert_output "${item_pw}"
}

assert_item_with_name_and_account() {
  local item_name="$1" item_account="$2" item_pw="$3"
  run security find-generic-password -a "${item_account}" -s "${item_name}" -w "${TEST_KEYCHAIN}"
  assert_success
  assert_output "${item_pw}"
}

assert_no_item_with_name() {
  local item_name="$1"
  run security find-generic-password -s "${item_name}" -w "${TEST_KEYCHAIN}"
  assert_failure
  assert_output "security: SecKeychainSearchCopyNext: The specified item could not be found in the keychain."
}

assert_no_item_with_account() {
  local item_account="$1"
  run security find-generic-password -a "${item_account}" -w "${TEST_KEYCHAIN}"
  assert_failure
  assert_output "security: SecKeychainSearchCopyNext: The specified item could not be found in the keychain."
}

assert_no_item_with_name_and_account() {
  local item_name="$1" item_account="$2"
  run security find-generic-password -a "${item_account}" -s "${item_name}" -w "${TEST_KEYCHAIN}"
  assert_failure
  assert_output "security: SecKeychainSearchCopyNext: The specified item could not be found in the keychain."
}
