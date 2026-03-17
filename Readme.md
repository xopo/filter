# filter

A CLI tool to colorize and filter piped input.

<img width="976" height="438" alt="Screenshot 2026-03-17 at 08 15 22" src="https://github.com/user-attachments/assets/ae4a1375-6f32-4d3d-b5c4-a4cc7a8eb07d" />


## Install

```zsh
brew tap xopo/filter
brew install filter
```

## Features

- PASS → green
- FAIL → red
- failed/passed summary → highlighted
- Custom watch words → yellow bold (default: expected, received)

## Usage

### Basic - uses default watch words (expected, received)

some_test_command | filter

### Watch custom words

some_test_command | filter -w "error,warn,timeout"

### Single word

echo "got expected value" | filter -w expected

## Requirements

- Input via stdin (not TTY)
- Pipe or redirect output into the tool
