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

	allocator := context.allocator
	opt := combineOptions(user_opt, default_opt[:])
	all_opt := combineOptions(opt, default_check[:], allocator = allocator)
	defer delete(all_opt)

	s: bufio.Scanner
	bufio.scanner_init(&s, os.to_stream(os.stdin))
	defer bufio.scanner_destroy(&s)

	summary_started: bool
	once: bool
	prev_ephemere: bool

	for bufio.scan(&s) {
		scan := bufio.scanner_text(&s)
		split_scan := strings.split(scan, "\n")
		// fmt.printf("** found %d split in %q", len(split_scan), scan)
		for line in split_scan {
			lower_line := strings.to_lower(line)
			if !should_format(lower_line, all_opt) {
				if strings.contains(line, end) {
					print_end_summary(line)
					once = false
					summary_started = false
				} else {
					ephemere_print(line, &prev_ephemere)
				}

				delete(lower_line)
				continue
			}
			formated_line := format_line(strings.trim_space(line), &summary_started, opt)

			// separator for summary
			if once == false && summary_started == true {
				once = true
				print_separator()
			}

			if formated_line != "" {
				prev_ephemere = false
				fmt.printf("%s\n", formated_line)
				delete(formated_line)
			}
		}
	}
}

should_format :: proc(line: string, opt: []string) -> bool {
	// fmt.println("check line ", line)
	for o in opt {
		// if the line is exactly one word
		if o == line {
			fmt.println("-- return true, 1")
			return true
		}

		pos := 0

		for {
			i := strings.index(line[pos:], o)
			if i < 0 do break

			i += pos
			end := i + len(o)

			if end >= len(line) || is_boundary(line[end]) {
				return true
			}
		}
	}

	return false
}

is_boundary :: proc(b: byte) -> bool {
	fmt.printf("check boundary: %c\n", b)
	return true
}

combineOptions :: proc(first, second: []string, allocator := context.temp_allocator) -> []string {
	if len(first) == 0 || first == nil {
		return second
	}

	if len(second) == 0 || second == nil {
		return first
	}

	result := make([]string, len(first) + len(second), allocator)
	for s, i in second {
		result[i] = s
	}

	for s, i in first {
		result[i + len(second)] = s
	}

	return result[:]
}

optional_word :: proc(opt: []string, word: string) -> string {
	if len(opt) == 0 || len(word) == 0 {
		return ""
	}
	for o in opt {
		if o == word {
			return word
		}
	}
	for o in opt {
		if strings.contains(word, o) {
			return word
		}
	}
	return ""
}

cached := map[string]string{}

color_word :: proc(w: string, color: string) -> string {
	result, found := cached[w]
	if found {
		return result
	}
	colored := fmt.aprintf("%s%s%s", color, w, RESET)
	cached[w] = colored
	return cached[w]
}

format_line :: proc(
	line: string,
	summary_started: ^bool,
	opt: []string,
	allocator := context.temp_allocator,
) -> string {
	split := strings.split(line, " ")
	sf := strings.builder_make()

	first := true
	for word in split {
		lower_word := strings.to_lower(word)
		if !first {
			strings.write_string(&sf, " ")
		}
		first = false
		switch lower_word {

		case "pass", "fail", "warn":
			color := lower_word == "pass" ? GREEN : lower_word == "fail" ? RED : YELLOW
			strings.write_string(
				&sf,
				fmt.aprintf("%s%s%s", color, word, RESET, allocator = allocator),
			)
			break

		case "expected", "expected:", "received", "received:":
			word_to_color := word
			has_suffix := strings.has_suffix(word, ":")
			if has_suffix {
				word_to_color = word[:len(word) - 1]
			}
			strings.write_string(
				&sf,
				fmt.aprintf("%s%s%s", YELLOW, word_to_color, RESET, allocator = allocator),
			)
			if has_suffix {
				strings.write_string(&sf, ":")
			}
			break

		case:
			optional := optional_word(opt, lower_word)

			if len(optional) > 0 {
				strings.write_string(
					&sf,
					fmt.aprintf("%s%s%s", YELLOW, word, RESET, allocator = allocator),
				)
				break
			}

			passed := strings.contains(lower_word, "passed")
			if passed || strings.contains(lower_word, "failed") {
				sp := passed ? "passed" : "failed"
				color := passed ? GREEN : RED
				passed_split := strings.split(word, sp)
				strings.write_string(&sf, passed_split[0])
				strings.write_string(
					&sf,
					fmt.aprintf("%s%s%s", color, sp, RESET, allocator = allocator),
				)
				strings.write_string(&sf, passed_split[1])
				summary_started^ = true
				delete(passed_split)
				break
			}

			strings.write_string(&sf, word)
			break
		}

		delete(lower_word)
	}

	delete(split)
	return strings.to_string(sf)
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
