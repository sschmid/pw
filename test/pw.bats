setup() {
  load 'test-helper.bash'
  _setup
  PROJECT_ROOT="$(cd "${BATS_TEST_DIRNAME}/.." >/dev/null 2>&1 && pwd)"
  PATH="${PROJECT_ROOT}/src:${PATH}"
  export PW_KEYCHAIN="${TEST_KEYCHAIN}"
}

teardown() {
  _teardown
}

assert_pw_home() {
  assert_equal "${PW_HOME}" "${PROJECT_ROOT}"
}

assert_require_bash() {
  local version_info=("$1" "$2" "$3")
  ((version_info[0] >= 4)) || exit 1
  if ((version_info[0] == 4)); then
    ((version_info[1] >= 2)) || exit 1
  fi
}

@test "requires bash-4.2 or later" {
  run assert_require_bash 5 0 0
  assert_success

  run assert_require_bash 4 4 0
  assert_success

  run assert_require_bash 4 2 0
  assert_success

  run assert_require_bash 4 1 0
  assert_failure

  run assert_require_bash 3 2 0
  assert_failure
}

@test "resolves pw home" {
  # shellcheck disable=SC1090,SC1091
  source "${PROJECT_ROOT}/src/pw"
  assert_pw_home
}

@test "resolves pw home and follows symlink" {
  ln -s "${PROJECT_ROOT}/src/pw" "${BATS_TEST_TMPDIR}/pw"
  # shellcheck disable=SC1090,SC1091
  source "${BATS_TEST_TMPDIR}/pw"
  assert_pw_home
}

@test "resolves pw home and follows multiple symlinks" {
  mkdir "${BATS_TEST_TMPDIR}/src" "${BATS_TEST_TMPDIR}/bin"
  ln -s "${PROJECT_ROOT}/src/pw" "${BATS_TEST_TMPDIR}/src/pw"
  ln -s "${BATS_TEST_TMPDIR}/src/pw" "${BATS_TEST_TMPDIR}/bin/pw"
  # shellcheck disable=SC1090,SC1091
  source "${BATS_TEST_TMPDIR}/bin/pw"
  assert_pw_home
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
  cat << 'EOF' | assert_output -
test-name       	test-account    	pw_test.keychain
test2-name      	test2-account   	pw_test.keychain
EOF
}

@test "list filters <NULL> name" {
  _add_item_with_account "test-account" "test-pw"
  run pw ls
  assert_success
  cat << 'EOF' | assert_output -
                	test-account    	pw_test.keychain
EOF
}

@test "list filters <NULL> account" {
  _add_item_with_name "test-name" "test-pw"
  run pw ls
  assert_success
  cat << 'EOF' | assert_output -
test-name       	                	pw_test.keychain
EOF
}

@test "generates and copies password" {
  skip "Doesn't work with GitHub actions for some reason"
  # shellcheck disable=SC2030,SC2031
  export PW_GEN_LENGTH=5
  run pw gen
  assert_success
  refute_output
  run pbpaste
  run echo "${#output}"
  assert_output "5"
}

@test "generates and prints password" {
  skip "Doesn't work with GitHub actions for some reason"
  # shellcheck disable=SC2030,SC2031
  export PW_GEN_LENGTH=5
  run pw -p gen
  assert_success
  assert_output
  run echo "${#output}"
  assert_output "5"
}
