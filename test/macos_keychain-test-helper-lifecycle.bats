setup() {
  load 'macos_keychain-test-helper.bash'
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

@test "don't setup keychain in ~/Library/Keychains" {
  run _setup
  assert_success
  assert_file_exists "${TEST_KEYCHAIN}"

  run ls ~/Library/Keychains
  refute_output --partial "$(basename "${TEST_KEYCHAIN}")"
}
