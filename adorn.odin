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


print_on_same_line :: proc(line: string) {
	fmt.printf("\r%s2K%s", ESC, line)
}

print_separator :: proc() {
	fmt.printf("\n%s\n", get_separator())
}

print_end_summary :: proc(line: string) {
	fmt.printf("\n%s", line)
	print_separator()
	fmt.println()
}
