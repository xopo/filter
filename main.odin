package main

import "core:bufio"
import "core:fmt"
import "core:os"
import "core:strings"

main :: proc() {

	ok := initial_check()
	if !ok {
		return
	}

	opt := []string{}
	defer delete(opt)

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
		return replace(line, "PASS", green)

	}

	if strings.contains(line, "FAIL") {
		return replace(line, "FAIL", red)

	}

	upd_line: string

	if (strings.contains(line, "passed") || strings.contains(line, "failed")) {
		if (!started^) {
			fmt.println()
			started^ = true
		}

		if strings.contains(line, "failed") {
			upd_line = replace(line, "failed", red)
		}

		if strings.contains(line, "passed") {
			upd_line = replace(upd_line, "passed", green)
		}

		for o in opt {
			if strings.contains(line, o) {
				upd_line = replace(upd_line, o, yellow)
			}
		}

		return upd_line
	}

	return ""
}


replace :: proc(
	line, target: string,
	cb: proc(inp: string, alocator := context.allocator) -> string,
) -> string {
	split := strings.split(line, target)
	defer delete(split)

	color_target := cb(target)
	defer delete(color_target)

	return fmt.aprintf("%s%s%s", split[0], color_target, split[1], allocator = context.allocator)
}

initial_check :: proc() -> bool {
	if os.is_tty(os.stdin) {
		fmt.printf("Ussage: <command> |%s\n", os.args[0])
		return false
	}
	return true
}
