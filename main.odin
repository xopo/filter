package main

import "core:bufio"
import "core:fmt"
import "core:log"
import "core:os"
import "core:strings"

main :: proc() {

	opt, ok := initial_check()
	defer delete(opt)
	if !ok {
		return
	}


	s: bufio.Scanner
	bufio.scanner_init(&s, os.to_stream(os.stdin))
	defer bufio.scanner_destroy(&s)

	started := false

	for bufio.scan(&s) {
		line := bufio.scanner_text(&s)

		new_line := format_line(line, &started, opt)
		if new_line != "" {
			fmt.println(new_line)
			delete(new_line)
		}
	}
}

format_line :: proc(line: string, started: ^bool, opt: []string) -> string {
	if strings.contains(line, "PASS") {
		return check_and_replace(line, "PASS", green)
	}

	if strings.contains(line, "FAIL") {
		return check_and_replace(line, "FAIL", red)

	}

	upd_line: string

	if (strings.contains(line, "passed") || strings.contains(line, "failed")) {
		if (!started^) {
			fmt.println()
			started^ = true
		}

		if strings.contains(line, "failed") {
			upd_line = check_and_replace(line, "failed", red)
		}

		if strings.contains(line, "passed") {
			old := upd_line
			upd_line = check_and_replace(old, "passed", green)
			delete(old)
		}

		for o in opt {
			if strings.contains(line, o) {
				upd_line = check_and_replace(upd_line, o, yellow)
			}
		}

		return upd_line
	}

	return ""
}

check_and_replace :: proc(
	line, target: string,
	cb: proc(inp: string, alocator := context.allocator) -> string,
) -> string {
	split := strings.split(line, target)
	defer delete(split)
	log.info("split result", split)

	color_target := cb(target)
	defer delete(color_target)

	// return fmt.aprintf("%s%s%s", split[0], color_target, split[1], allocator = context.allocator)
	return strings.join([]string{split[0], color_target, split[1]}, "")
}

initial_check :: proc() -> ([]string, bool) {
	if os.is_tty(os.stdin) {
		print_usage()
		return nil, false
	}

	if len(os.args) > 1 {
		flag := os.args[1]
		if flag != "-w" && flag != "--watch" {
			print_usage()
			return nil, false
		}
	}

	if len(os.args) != 3 {
		print_usage()
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
