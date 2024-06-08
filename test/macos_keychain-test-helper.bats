setup() {
  load 'macos_keychain-test-helper.bash'
  _setup
}

teardown() {
  _teardown
}

@test "keychain doesn't contain item with name" {
  assert_no_item_with_name "test-name"
}

@test "keychain doesn't contain item with account" {
  assert_no_item_with_account "test-account"
}

@test "keychain doesn't contain item with name and account" {
  assert_no_item_with_name_and_account "test-name" "test-account"
}

@test "adds item with name" {
  _add_item_with_name "test-name" "test-pw"
  assert_item_with_name "test-name" "test-pw"
}

@test "fails when adding item with existing name" {
  _add_item_with_name "test-name" "test-pw"
  assert_fail_add_item_with_name "test-name" "test-pw"
}

@test "updates item with existing name" {
  _add_item_with_name "test-name" "test-pw"
  _update_item_with_name "test-name" "test-pw-new"
  assert_item_with_name "test-name" "test-pw-new"
}

@test "adds item with different name" {
  _add_item_with_name "test-name" "test-pw"
  _add_item_with_name "test2-name" "test2-pw"
  assert_item_with_name "test-name" "test-pw"
  assert_item_with_name "test2-name" "test2-pw"
}

@test "adds item with account" {
  _add_item_with_account "test-account" "test-pw"
  assert_item_with_account "test-account" "test-pw"
}

@test "fails when adding item with existing account" {
  _add_item_with_account "test-account" "test-pw"
  assert_fail_add_item_with_account "test-account" "test-pw"
}

@test "updates item with existing account" {
  _add_item_with_account "test-account" "test-pw"
  _update_item_with_account "test-account" "test-pw-new"
  assert_item_with_account "test-account" "test-pw-new"
}

@test "adds item with different account" {
  _add_item_with_account "test-account" "test-pw"
  _add_item_with_account "test2-account" "test2-pw"
  assert_item_with_account "test-account" "test-pw"
  assert_item_with_account "test2-account" "test2-pw"
}

@test "adds item with name and account" {
  _add_item_with_name_and_account "test-name" "test-account" "test-pw"
  assert_item_with_name "test-name" "test-pw"
  assert_item_with_account "test-account" "test-pw"
  assert_item_with_name_and_account "test-name" "test-account" "test-pw"
}

@test "fails when adding item with existing name and account" {
  _add_item_with_name_and_account "test-name" "test-account" "test-pw"
  assert_fail_add_item_with_name_and_account "test-name" "test-account" "test-pw"
}

@test "updates item with existing name and account" {
  _add_item_with_name_and_account "test-name" "test-account" "test-pw"
  _update_item_with_name_and_account "test-name" "test-account" "test-pw-new"
  assert_item_with_name_and_account "test-name" "test-account" "test-pw-new"
}

@test "adds item with different name and existing account" {
  _add_item_with_name_and_account "test-name" "test-account" "test-pw"
  _add_item_with_name_and_account "test2-name" "test-account" "test2-pw"

  assert_item_with_name "test-name" "test-pw"
  assert_item_with_name_and_account "test-name" "test-account" "test-pw"

  assert_item_with_name "test2-name" "test2-pw"
  assert_item_with_name_and_account "test2-name" "test-account" "test2-pw"

  assert_item_with_account "test-account" "test-pw"
}

@test "adds item with existing name and different account" {
  _add_item_with_name_and_account "test-name" "test-account" "test-pw"
  _add_item_with_name_and_account "test-name" "test2-account" "test2-pw"

  assert_item_with_account "test-account" "test-pw"
  assert_item_with_name_and_account "test-name" "test-account" "test-pw"

  assert_item_with_account "test2-account" "test2-pw"
  assert_item_with_name_and_account "test-name" "test2-account" "test2-pw"

  assert_item_with_name "test-name" "test-pw"
}

@test "removes item with name" {
  _add_item_with_name "test-name" "test-pw"
  _add_item_with_name "test2-name" "test2-pw"
  _delete_item_with_name "test-name"
  assert_no_item_with_name "test-name"
  assert_item_with_name "test2-name" "test2-pw"
}

@test "removes item with account" {
  _add_item_with_account "test-account" "test-pw"
  _add_item_with_account "test2-account" "test2-pw"
  _delete_item_with_account "test-account"
  assert_no_item_with_account "test-account"
  assert_item_with_account "test2-account" "test2-pw"
}

@test "removes item with name and account" {
  _add_item_with_name_and_account "test-name" "test-account" "test-pw"
  _add_item_with_name_and_account "test2-name" "test-account" "test2-pw"
  _add_item_with_name_and_account "test-name" "test2-account" "test3-pw"
  _delete_item_with_name_and_account "test-name" "test-account"
  assert_no_item_with_name_and_account "test-account" "test-account"
  assert_item_with_name_and_account "test2-name" "test-account" "test2-pw"
  assert_item_with_name_and_account "test-name" "test2-account" "test3-pw"
}
