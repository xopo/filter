#+feature global-context
package main

import "core:fmt"

@(private = "package")

ESC :: "\033["

RESET :: ESC + "0m"
BLACK :: ESC + "30m"
RED :: ESC + "31m"
GREEN :: ESC + "32m"
YELLOW :: ESC + "33m"
BLUE :: ESC + "34m"
MAGENTA :: ESC + "35m"

color :: proc(color, input: string, allocator := context.allocator) -> string {
	return fmt.aprintf("%s%s%s", color, input, RESET, allocator = allocator)
}

red :: proc(input: string, allocator := context.allocator) -> string {
	return color(RED, input, allocator = allocator)
}

yellow :: proc(input: string, allocator := context.allocator) -> string {
	return color(YELLOW, input, allocator = allocator)
}

green :: proc(input: string, allocator := context.allocator) -> string {
	return color(GREEN, input, allocator = allocator)
}

blue :: proc(input: string, allocator := context.allocator) -> string {
	return color(BLUE, input, allocator = allocator)
}

magenta :: proc(input: string, allocator := context.allocator) -> string {
	return color(MAGENTA, input, allocator = allocator)
}
