package main

import "core:bufio"
import "core:fmt"
import "core:os"
import "core:strings"


main :: proc() {

	user_opt, ok := initial_check()
	defer delete(user_opt)
	if !ok {
		return
	}

	opt := combineOptions(user_opt, default_opt[:])

	s: bufio.Scanner
	bufio.scanner_init(&s, os.to_stream(os.stdin))
	defer bufio.scanner_destroy(&s)

	summary_started: bool

	fmt.println(strings.repeat("=", 50))
	for bufio.scan(&s) {
		line := bufio.scanner_text(&s)

		formated_line := format_line(line, &summary_started, opt)
		if formated_line != "" {
			fmt.println(formated_line)
			delete(formated_line)
		}
	}
}

combineOptions :: proc(first, second: []string) -> []string {
	if len(first) == 0 || first == nil {
		return second
	}

	if len(second) == 0 || second == nil {
		return first
	}

	result: [dynamic]string
	for s in second {
		append(&result, s)
	}

	for s in first {
		append(&result, s)
	}

	return result[:]
}


format_line :: proc(line: string, summary_started: ^bool, opt: []string) -> string {
	if strings.contains(line, "PASS") {
		reset_started(summary_started, false)
		return check_and_replace(line, "PASS", green)
	}

	if strings.contains(line, "FAIL") {
		reset_started(summary_started, false)
		return check_and_replace(line, "FAIL", red)
	}

	if strings.contains(line, "WARN") {
		reset_started(summary_started, false)
		return check_and_replace(line, "WARN", yellow)
	}


	upd_line: string

	if (strings.contains(line, "passed") ||
		   strings.contains(line, "failed") ||
		   strings.contains(line, "warning")) {
		if (!summary_started^) {
			summary_started^ = true
			fmt.println()
		}

		if strings.contains(line, "failed") {
			upd_line = check_and_replace(line, "failed", red)
		}

		if strings.contains(line, "passed") {
			old := len(upd_line) > 0 ? upd_line : line
			should_delete_old := len(upd_line) > 0
			upd_line = check_and_replace(old, "passed", green)
			if should_delete_old {
				delete(old)
			}
		}


		return upd_line
	}

	for o in opt {
		if strings.contains(line, o) {
			return fmt.aprintf("%s", check_and_replace(line, o, yellow_bold))
		}
	}

	return summary_started^ ? strings.clone(line) : ""
}

reset_started :: proc(started: ^bool, value: bool) {
	if started^ != value {
		fmt.println()
		started^ = value
	}
}

check_and_replace :: proc(
	line, target: string,
	colorize_callback: proc(inp: string, allocator := context.allocator) -> string,
) -> string {
	split := strings.split(line, target)
	defer delete(split)

	last_part: string

	if len(split) > 1 {
		last_part = split[1]
	}

	color_target := colorize_callback(target)
	defer delete(color_target)

	return strings.join([]string{split[0], color_target, last_part}, "")
}

initial_check :: proc() -> ([]string, bool) {
	if os.is_tty(os.stdin) {
		print_usage()
		return nil, false
	}

	if len(os.args) == 1 {
		return []string{}, true
	}

	if len(os.args) > 1 {
		flag := os.args[1]
		if flag != "-w" && flag != "--watch" {
			fmt.eprintf("flag not accepted\n")
			print_usage()
			return nil, false
		}
	}

	if len(os.args) > 3 {
		fmt.eprintf("Too many arguments \n")
		print_usage()
		return nil, false
	}

	return strings.split(os.args[2], ","), true
}


print_usage :: proc() {
	fmt.println("Usage: filter -w \"word1,word2,...\"")
	fmt.println("")
	fmt.println("Options:")
	fmt.println("  -w <words>    Filter lines containing the specified word(s)")
	fmt.println("                Use comma-separated values for multiple words")
	fmt.println("                Example: -w \"error,warn,fatal\"")
}
