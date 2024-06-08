# tests were copied from keepassxc-plugin.bats
# gpg can only show entries based on title, not account
# affected tests were commented out and marked as not implemented

setup() {
  load 'gpg-test-helper.bash'
  _setup
  _set_pwrc_with_keychains "${TEST_KEYCHAIN}"
  export PW_GPG_PASSWORD="${TEST_PASSWORD}"
  export GNUPGHOME="${PROJECT_ROOT}/test/fixtures/.gnupg"
}

teardown() {
  _teardown
}

@test "fails when copying item that doesn't exist" {
  run pw "test-name"
  assert_failure
  assert_output --partial "gpg: decrypt_message failed: No such file or directory"
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

    # not implemented
    # @test "copies item with account" {
    #   _add_item_with_account "test-account" "test-pw"
    #   run pw "" "test-account"
    #   assert_success
    #   refute_output
    #   run pbpaste
    #   assert_output "test-pw"
    # }

    # not implemented
    # @test "copies item with account and spaces" {
    #   _add_item_with_account "test account" "test pw"
    #   run pw "" "test account"
    #   assert_success
    #   refute_output
    #   run pbpaste
    #   assert_output "test pw"
    # }

    # not implemented
    # @test "copies item with name and account" {
    #   _add_item_with_name_and_account "test-name" "test-account" "test-pw"
    #   run pw "test-name" "test-account"
    #   assert_success
    #   refute_output
    #   run pbpaste
    #   assert_output "test-pw"
    # }

    # not implemented
    # @test "copies item with name and account and spaces" {
    #   _add_item_with_name_and_account "test name" "test account" "test pw"
    #   run pw "test name" "test account"
    #   assert_success
    #   refute_output
    #   run pbpaste
    #   assert_output "test pw"
    # }

@test "clears clipboard after copying item" {
  # shellcheck disable=SC2030,SC2031
  export PW_CLIP_TIME=1
  _add_item_with_name_and_account "test name" "test account" "test pw"
  run pw "test name"
  sleep 2
  run pbpaste
  refute_output
}

@test "doesn't clear clipboard when changed" {
  # shellcheck disable=SC2030,SC2031
  export PW_CLIP_TIME=1
  _add_item_with_name_and_account "test name" "test account" "test pw"
  run pw "test name"
  echo -n "after" | pbcopy
  sleep 2
  run pbpaste
  assert_output "after"
}

@test "fails when printing item that doesn't exist" {
  run pw -p "test-name"
  assert_failure
  assert_output --partial "gpg: decrypt_message failed: No such file or directory"
}

@test "prints item with name" {
  _add_item_with_name "test-name" "test-pw"
  run pw -p "test-name"
  assert_success
  assert_output "test-pw"
}

    # not implemented
    # @test "prints item with account" {
    #   _add_item_with_account "test-account" "test-pw"
    #   run pw -p "" "test-account"
    #   assert_success
    #   assert_output "test-pw"
    # }

    # not implemented
    # @test "prints item with name and account" {
    #   _add_item_with_name_and_account "test-name" "test-account" "test-pw"
    #   run pw -p "test-name" "test-account"
    #   assert_success
    #   assert_output "test-pw"
    # }

@test "removes item with name" {
  _add_item_with_name "test-name" "test-pw"
  run pw rm "test-name"
  assert_success
  assert_deleted_item_with_name "test-name"
}

    # not implemented
    # @test "removes item with account" {
    #   _add_item_with_account "test-account" "test-pw"
    #   run pw rm "" "test-account"
    #   assert_success
    #   assert_no_item_with_account "test-account"
    # }

    # not implemented
    # @test "removes item with name and account" {
    #   _add_item_with_name_and_account "test-name" "test-account" "test-pw"
    #   run pw rm "test-name" "test-account"
    #   assert_success
    #   assert_no_item_with_name_and_account "test-name" "test-account"
    # }

@test "fails when wrong password is provided" {
  PW_GPG_PASSWORD="wrong"
  _add_item_with_name "test-name" "test-pw"
  run pw "test-name"
  assert_failure
  assert_output --partial "gpg: decryption failed: Bad passphrase"
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
./test-name
./test2-name
EOF
}

@test "excludes .DS_Store" {
  touch "${TEST_KEYCHAIN}/.DS_Store"
  run pw ls
  assert_success
  refute_output
}

@test "adds item in subfolder" {
  _add_item_with_name "group/test-name" "test-pw"
  run pw -p "group/test-name"
  assert_success
  assert_output "test-pw"
}
