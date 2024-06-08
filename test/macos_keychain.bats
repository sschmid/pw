setup() {
  load 'pw-test-helper.bash'
  load 'macos_keychain-test-helper.bash'
  _setup
  _set_pwrc_with_keychains "${TEST_KEYCHAIN}"
}

teardown() {
  _teardown
}

@test "fails when copying item that doesn't exist" {
  run pw "test-name"
  assert_failure
  assert_output "security: SecKeychainSearchCopyNext: The specified item could not be found in the keychain."
}

@test "copies item with name" {
  _add_item_with_name "test-name" "test-pw"
  run pw "test-name"
  assert_success
  refute_output
  run pbpaste
  assert_output "test-pw"
}

@test "copies item with name and spaces" {
  _add_item_with_name "test name" "test pw"
  run pw "test name"
  assert_success
  refute_output
  run pbpaste
  assert_output "test pw"
}

@test "copies item with account" {
  _add_item_with_account "test-account" "test-pw"
  run pw "" "test-account"
  assert_success
  refute_output
  run pbpaste
  assert_output "test-pw"
}

@test "copies item with account and spaces" {
  _add_item_with_account "test account" "test pw"
  run pw "" "test account"
  assert_success
  refute_output
  run pbpaste
  assert_output "test pw"
}

@test "copies item with name and account" {
  _add_item_with_name_and_account "test-name" "test-account" "test-pw"
  run pw "test-name" "test-account"
  assert_success
  refute_output
  run pbpaste
  assert_output "test-pw"
}

@test "copies item with name and account and spaces" {
  _add_item_with_name_and_account "test name" "test account" "test pw"
  run pw "test name" "test account"
  assert_success
  refute_output
  run pbpaste
  assert_output "test pw"
}

@test "clears clipboard after copying item" {
  # shellcheck disable=SC2030,SC2031
  export PW_CLIP_TIME=1
  _add_item_with_name_and_account "test name" "test account" "test pw"
  run pw "test name" "test account"
  sleep 2
  run pbpaste
  refute_output
}

@test "doesn't clear clipboard when changed" {
  # shellcheck disable=SC2030,SC2031
  export PW_CLIP_TIME=1
  _add_item_with_name_and_account "test name" "test account" "test pw"
  run pw "test name" "test account"
  echo -n "after" | pbcopy
  sleep 2
  run pbpaste
  assert_output "after"
}

@test "fails when printing item that doesn't exist" {
  run pw -p "test-name"
  assert_failure
  assert_output "security: SecKeychainSearchCopyNext: The specified item could not be found in the keychain."
}

@test "prints item with name" {
  _add_item_with_name "test-name" "test-pw"
  run pw -p "test-name"
  assert_success
  assert_output "test-pw"
}

@test "prints item with account" {
  _add_item_with_account "test-account" "test-pw"
  run pw -p "" "test-account"
  assert_success
  assert_output "test-pw"
}

@test "prints item with name and account" {
  _add_item_with_name_and_account "test-name" "test-account" "test-pw"
  run pw -p "test-name" "test-account"
  assert_success
  assert_output "test-pw"
}

@test "removes item with name" {
  _add_item_with_name "test-name" "test-pw"
  run pw rm "test-name"
  assert_success
  assert_no_item_with_name "test-name"
}

@test "removes item with account" {
  _add_item_with_account "test-account" "test-pw"
  run pw rm "" "test-account"
  assert_success
  assert_no_item_with_account "test-account"
}

@test "removes item with name and account" {
  _add_item_with_name_and_account "test-name" "test-account" "test-pw"
  run pw rm "test-name" "test-account"
  assert_success
  assert_no_item_with_name_and_account "test-name" "test-account"
}

@test "lists empty keychain" {
  run pw ls
  assert_success
  refute_output
}

@test "lists items in keychain" {
  _add_item_with_name_and_account "test-name" "test-account" "test-pw"
  _add_item_with_name_and_account "test2-name" "test2-account" "test-pw"
  run pw ls
  assert_success
  cat << EOF | assert_output -
test-name                               	test-account
test2-name                              	test2-account
EOF
}

@test "list filters <NULL> name" {
  _add_item_with_account "test-account" "test-pw"
  run pw ls
  assert_success
  assert_output "                                        	test-account"
}

@test "list filters <NULL> account" {
  _add_item_with_name "test-name" "test-pw"
  run pw ls
  assert_success
  assert_output "test-name                               	"
}
