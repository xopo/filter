# filter

A CLI tool to colorize and filter piped input.

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
