package main

import "core:fmt"
import "core:log"
import "core:strings"
import "core:testing"

test1 := `Running tests...

PASS  tests/math/add.test.js
  ✓ add(1, 2) returns 3 (3 ms)
  ✓ add(-1, 5) returns 4

PASS  tests/math/multiply.test.js
  ✓ multiply(2, 3) returns 6

WARN  tests/utils/config.test.js
  ⚠ deprecated config key "timeout"

FAIL  tests/user/login.test.js
  ✕ should reject invalid password

  ● should reject invalid password

    Expected: true
    Received: false

    at login.test.js:24:10

TypeError: Cannot read properties of undefined (reading 'password')
    at auth.js:45:15
    at login.test.js:20:5

console.log
  Attempting login for user: admin

console.warn
  Missing optional field: rememberMe

Test Suites: 1 failed, 3 passed, 4 total
Tests:       1 failed, 4 passed, 5 total
Warnings:    1
Time:        1.72 s`


Test_Case :: struct {
	input, expecting: string,
}

@(test)
test_pass_coloring2 :: proc(t: ^testing.T) {
	test_cases := []Test_Case {
		{"bla", ""},
		{
			"PASS  tests/math/add.test.js",
			fmt.tprintf("%sPASS%s  tests/math/add.test.js", GREEN, RESET),
		},
		{
			"FAIL  tests/user/login.test.js",
			fmt.tprintf("%sFAIL%s  tests/user/login.test.js", RED, RESET),
		},
		{
			"Test Suites: 1 failed, 3 passed, 4 total",
			fmt.tprintf(
				"Test Suites: 1 %sfailed%s, 3 %spassed%s, 4 total",
				RED,
				RESET,
				GREEN,
				RESET,
			),
		},
	}
	for test in test_cases {
		passed := false
		opt := []string{}
		result := format_line(test.input, &passed, opt)
		delete(opt)
		defer delete(result)

		testing.expect_value(t, result, test.expecting)

	}
}
