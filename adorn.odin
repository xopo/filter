package main

import "core:fmt"
import "core:strings"

separator: string

get_separator :: proc() -> string {
	if separator == "" {
		separator = strings.repeat("-", 50)
	}
	return separator
}


ephemere_print :: proc(line: string, prev_ephemere: ^bool) {
	fmt.printf("\t ** %t - line: %q\n", prev_ephemere^, line)
	if prev_ephemere^ {
		fmt.printf("\r%s2K", ESC)
	}
	fmt.printf(line)
	prev_ephemere^ = true
}

print_separator :: proc() {
	fmt.printf("\n%s\n", get_separator())
}

print_end_summary :: proc(line: string) {
	fmt.printf("\n%s", line)
	print_separator()
	fmt.println()
}

raw_print :: proc(line: string) {
	for b, _ in line {
		switch b {
		case '\n':
			fmt.printf("\\n")
		case '\r':
			fmt.printf("\\r")
		case '\t':
			fmt.printf("\\t")
		case:
			fmt.printf("%c", b)
		}
	}
	fmt.println()
}
