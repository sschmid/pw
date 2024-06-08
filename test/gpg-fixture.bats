setup() {
  load 'gpg-test-helper.bash'
}

@test "sets up and tears down test database and uses test key" {
  assert_dir_not_exists "${TEST_KEYCHAIN}"

  run _setup
  assert_success
  assert_dir_exists "${TEST_KEYCHAIN}"

  # check if test key exists and start gpg-agent process
  run _gpg -K
  assert_success
  assert_output --partial "50BBF2BD2593DF9D321CD904BA0C06BF55D1758A"

  run _teardown
  assert_success
  assert_dir_not_exists "${TEST_KEYCHAIN}"

  # check if gpg-agent process got killed
  run ps -A
  assert_success
  refute_output --partial "gpg-agent --homedir"
}
