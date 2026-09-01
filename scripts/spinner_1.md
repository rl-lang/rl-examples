# spinner

> A feature-rich terminal spinner for RL with process wrapper, color support, and live output.

**© Mohamed Gonem**

## Quick Start

```bash
rl run spinner_1.rl -- -s wave -m "Loading..."
```

## Usage

```bash
rl run spinner_1.rl -- [options]
```

> **Note:** Use `--` to pass flags to the spinner (prevents conflicts with `rl run`).

## Options

### Animation

| Flag | Description |
|------|-------------|
| `-s <style>` | Animation style (see [Styles](#styles)) |
| `-r` | Reverse the animation direction |
| `-d <ms>` | Delay between frames (default: 100ms) |
| `-f <a b c>` | Custom frames (space-separated) |

### Message

| Flag | Description |
|------|-------------|
| `-m <text>` | Text to display next to the spinner |
| `-M <text>` | Text to display after spinner finishes |
| `-F <a,b,c>` | Animated messages (comma-separated, cycles with frames) |

### Process Wrapper

| Flag | Description |
|------|-------------|
| `-e <cmd>` | Run command with spinner (captures output) |
| `-o` | Show stdout on success (always shown on failure) |
| `-L` | Show live output line from `-e` command |
| `-t <sec>` | Timeout: kill command after N seconds (exit code 124) |

### Output

| Flag | Description |
|------|-------------|
| `--json` | JSON output: `{"status", "exit_code", "duration", "output"}` |
| `--notify` | Desktop notification on success (Linux only) |
| `-q` | Quiet mode: suppress animation, show result only |

### Appearance

| Flag | Description |
|------|-------------|
| `-C [colors]` | Color mode (see [Colors](#colors)) |
| `--pre <text>` | Prefix before spinner |
| `--suf <text>` | Suffix after spinner |

### Misc

| Flag | Description |
|------|-------------|
| `-n <count>` | Run for N cycles, then stop |
| `-h` | Show help message |

## Styles

| Style | Description |
|-------|-------------|
| `dots` | Braille dot rotation |
| `wave` | Braille wave pattern |
| `pulse` | Braille pulse |
| `fill` | Braille fill |
| `bounce` | Braille bounce |
| `heavy` | Heavy braille rotation |
| `line` | ASCII line rotation |
| `arc` | Arc rotation |
| `dots2` | Alternative braille dots |
| `marks` | Arrow marks |
| `star` | Star rotation |
| `toggle` | Block toggle |
| `bounce2` | Alternative bounce |
| `clock` | Clock emoji rotation |

## Colors

### Color Names

`random` | `black` | `red` | `green` | `yellow` | `blue` | `magenta` | `cyan` | `white`

### Color Modes

| Mode | Description |
|------|-------------|
| `-C` | Random color per frame |
| `-C <color>` | Single color for frames |
| `-C <f> <m>` | Frames + messages |
| `-C <f> <m> <fm>` | Frames + messages + finish |
| `-C <f> <m> <fm> <a> <o>` | Frames + messages + finish + arrow + output |
| `-C random <m>` | Random frames with colored messages |

### Fallback with `_`

Use `_` to inherit a previous color:

- 3rd arg `_` -> uses 2nd (message color)
- 4th arg `_` -> uses 1st (frame color, or red if random)
- 5th arg `_` -> uses 1st (frame color, or red if random)

## Examples

### Basic Usage

```bash
# Simple spinner with message
rl run spinner_1.rl -- -s wave -m "Loading..."

# Pulse style with 50 cycles
rl run spinner_1.rl -- -s pulse -n 50 -M "Done!"

# Red colored spinner
rl run spinner_1.rl -- -C red -m "Working..."
```

### Process Wrapper

```bash
# Run make with spinner
rl run spinner_1.rl -- -e "make build" -C red

# Run cargo test with custom colors
rl run spinner_1.rl -- -e "cargo test" -m "Running tests" -M "Tests passed"

# Show live output during command
rl run spinner_1.rl -- -e "make" -L -C random cyan green _ red yellow
```

### Colors

```bash
# Single color
rl run spinner_1.rl -- -C cyan -m "Loading..."

# Frame + message colors
rl run spinner_1.rl -- -C red blue -m "Building..."

# Full 5-color mode
rl run spinner_1.rl -- -C cyan green red blue yellow -m "Compiling..."

# Random frames + colored messages
rl run spinner_1.rl -- -C random cyan -m "Processing..."
```

### JSON Output

```bash
# JSON output (auto-enables quiet mode)
rl run spinner_1.rl -- -e "sleep 2" --json

# Output: {"status":"success","exit_code":0,"duration":2001,"output":""}
```

### Live Output

```bash
# Show latest output line below spinner
rl run spinner_1.rl -- -e "echo first; sleep 1; echo second; sleep 1; echo third" -L
```

## Exit Codes

| Code | Meaning |
|------|---------|
| `0` | Success |
| `1` | General error (failed to start command, etc.) |
| `2` | Usage error (invalid option) |
| `3` | Missing argument (e.g. `-e` without command) |
| `4` | Invalid value (e.g. unknown style or color) |
| `124` | Command timed out (`-t`) |

## Dependencies

- `rl` runtime
- `notify-send` (for `--notify` flag, Linux only)

## License

MIT or Apache 2
