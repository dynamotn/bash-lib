setup() {
  load test_helper
}

@test "dybatpho::require installed tool" {
  run dybatpho::require "bash"
  assert_success
}

@test "dybatpho::require not installed tool" {
  run -127 dybatpho::require "dyfoooo"
  assert_failure
  assert_output --partial "dyfoooo isn't installed"
}

@test "dybatpho::expect_args have right spec" {
  test_function() {
    local arg1 arg2
    dybatpho::expect_args arg1 arg2 -- "$@"
    assert_equal "$arg1" "this is first arg"
    assert_equal "$arg2" "this is second arg"
  }
  run test_function "this is first arg" "this is second arg"
  assert_success
}

@test "dybatpho::expect_args not have right spec" {
  test_function() {
    local arg1 arg2
    dybatpho::expect_args arg1 arg2 "$@"
  }
  run test_function "this is first arg" "this is second arg"
  assert_failure
}

@test "dybatpho::expect_args not have enough args" {
  test_function() {
    local arg1 arg2
    dybatpho::expect_args arg1 arg2 -- "$@"
  }
  run test_function
  assert_failure
  run test_function "1"
  assert_failure
}

@test "dybatpho::is with empty" {
  run dybatpho::is
  assert_failure
}

@test "dybatpho::is command" {
  run dybatpho::is "command" "bash"
  assert_success
  refute_output
  run dybatpho::is "command" "dyfoooo"
  assert_failure
  refute_output
}

@test "dybatpho::is file" {
  run dybatpho::is "file" "${BASH_SOURCE[0]}"
  assert_success
  refute_output
  run dybatpho::is "file" "dyfoooo"
  assert_failure
  refute_output
}

@test "dybatpho::is dir" {
  run dybatpho::is "dir" "$(dirname "${BASH_SOURCE[0]}")"
  assert_success
  refute_output
  run dybatpho::is "dir" "dyfoooo"
  assert_failure
  refute_output
}

@test "dybatpho::is link" {
  local temp="${BATS_TEST_TMPDIR}/link"
  ln -sf "${BASH_SOURCE[0]}" "$temp"
  run dybatpho::is "link" "$temp"
  assert_success
  refute_output
  run dybatpho::is "link" "dyfoooo"
  assert_failure
  refute_output
}

@test "dybatpho::is exist" {
  run dybatpho::is "exist" "$(dirname "${BASH_SOURCE[0]}")"
  assert_success
  refute_output
  run dybatpho::is "exist" "dyfoooo"
  assert_failure
  refute_output
}

@test "dybatpho::is readable" {
  local temp="$(mktemp -p "$BATS_TEST_TMPDIR")"
  chmod +r "$temp"
  run dybatpho::is "readable" "$temp"
  assert_success
  refute_output
  chmod -r "$temp"
  run dybatpho::is "readable" "$temp"
  assert_failure
  refute_output
}

@test "dybatpho::is writeable" {
  local temp="$(mktemp -p "$BATS_TEST_TMPDIR")"
  chmod +w "$temp"
  run dybatpho::is "writeable" "$temp"
  assert_success
  refute_output
  chmod -w "$temp"
  run dybatpho::is "writeable" "$temp"
  assert_failure
  refute_output
}

@test "dybatpho::is executable" {
  local temp="$(mktemp -p "$BATS_TEST_TMPDIR")"
  chmod +x "$temp"
  run dybatpho::is "executable" "$temp"
  assert_success
  refute_output
  chmod -x "$temp"
  run dybatpho::is "executable" "$temp"
  assert_failure
  refute_output
}

@test "dybatpho::is set" {
  local dyfoooo=""
  run dybatpho::is "set" "$dyfoooo"
  assert_failure
  refute_output
  dyfoooo="v"
  run dybatpho::is "set" "$dyfoooo"
  assert_success
  refute_output
}

@test "dybatpho::is empty" {
  local dyfoooo=""
  run dybatpho::is "empty" "$dyfoooo"
  assert_success
  refute_output
}

@test "dybatpho::is number" {
  run dybatpho::is "number" "1.11"
  assert_success
  refute_output
  run dybatpho::is "number" "1a"
  assert_failure
  refute_output
}

@test "dybatpho::is int" {
  run dybatpho::is "int" "11"
  assert_success
  refute_output
  run dybatpho::is "int" "1.11"
  assert_failure
  refute_output
  run dybatpho::is "int" "1a"
  assert_failure
  refute_output
}

@test "dybatpho::is true" {
  run dybatpho::is "true" "0"
  assert_success
  refute_output
  run dybatpho::is "true" "tRuE"
  assert_success
  refute_output
  run dybatpho::is "true" "YeS"
  assert_success
  refute_output
  run dybatpho::is "true" "oN"
  assert_success
  refute_output
  run dybatpho::is "true" ""
  assert_failure
  refute_output
  run dybatpho::is "true" "dyfoooo"
  assert_failure
  refute_output
}

@test "dybatpho::is false" {
  run dybatpho::is "false" "1"
  assert_success
  refute_output
  run dybatpho::is "false" "FaLsE"
  assert_success
  refute_output
  run dybatpho::is "false" "nO"
  assert_success
  refute_output
  run dybatpho::is "false" "oFf"
  assert_success
  refute_output
  run dybatpho::is "false" ""
  assert_failure
  refute_output
  run dybatpho::is "false" "dyfoooo"
  assert_failure
  refute_output
}

@test "dybatpho::is something undefined" {
  run dybatpho::is "fool" "I'm in love"
  assert_failure
  refute_output
}
