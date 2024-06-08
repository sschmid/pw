setup() {
  load 'keepassxc_cli-test-helper.bash'
}

@test "sets up and tears down test database" {
  assert_file_not_exists "${TEST_KEYCHAIN}"

  run _setup
  assert_success
  assert_file_exists "${TEST_KEYCHAIN}"

  run _teardown
  assert_success
  assert_file_not_exists "${TEST_KEYCHAIN}"
}
