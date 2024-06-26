setup() {
  load 'pw-test-helper.bash'
}

assert_require_bash() {
  local version_info=("$1" "$2" "$3")
  ((version_info[0] >= 4)) || exit 1
  if ((version_info[0] == 4)); then
    ((version_info[1] >= 2)) || exit 1
  fi
}

assert_pw_home() {
  assert_equal "${PW_HOME}" "${PROJECT_ROOT}"
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

@test "generates and copies password" {
  skip "Doesn't work with GitHub actions for some reason"
  # shellcheck disable=SC2030,SC2031
  export PW_GEN_LENGTH=5
  run pw gen
  assert_success
  refute_output
  run pbpaste
  run echo "${#output}"
  assert_output "${PW_GEN_LENGTH}"
}

@test "generates and prints password" {
  skip "Doesn't work with GitHub actions for some reason"
  # shellcheck disable=SC2030,SC2031
  export PW_GEN_LENGTH=5
  run pw -p gen
  assert_success
  assert_output
  run echo "${#output}"
  assert_output "${PW_GEN_LENGTH}"
}

@test "ignores sample plugin" {
  # shellcheck disable=SC1090,SC1091
  source "${PROJECT_ROOT}/src/pw"
  run pw::plugins
  assert_output --partial "macos_keychain/hook.bash"
  assert_output --partial "keepassxc/hook.bash"

  refute_output --partial "sample/hook.bash"
}
