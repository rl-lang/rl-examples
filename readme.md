# RL Programming Language Examples

## What Is This?

Repository for:
* examples
* random scripts
* interesting programs
* ideal solutions for common problems

Why is it useful?
* Provides examples for users to learn more
* will be useful for feature Coding AI model for RL 

## Scripts

### Spinner v1
Feature-rich terminal spinner with process wrapper, colors, and live output.
[Documentation](scripts/spinner_1.md)

## Exit Code Standard

All scripts in this repository follow a consistent exit code convention:

| Code | Meaning | Description |
|------|---------|-------------|
| `0` | Success | Script completed normally |
| `1` | General error | Unexpected failure or runtime error |
| `2` | Usage error | Invalid flag or bad argument combination |
| `3` | Missing argument | A flag was provided but no value followed it |
| `4` | Invalid value | A value was provided but was wrong type or out of range |
| `5` | Permission denied | Insufficient permissions to perform the operation |
| `6` | File not found | A required file or resource does not exist |

**Usage in scripts:**

```bash
dec args = args()

if args.arr_contains("-h")? {
  print_usage()
  exit(0)
}

if args.arr_contains("-f")? {
  dec target_index = args.arr_index_of("-f")?
  if !(args[target_index] == args.arr_last()?) {
    if target_index + 1 < args.len()? {
      dec path = args[target_index + 1]
      if !file_exists(path) {
        eprintln(format("error: file '{}' not found", path))
        exit(6)
      }
    } else {
      eprintln("error: '-f' requires a file path")
      exit(3)
    }
  } else {
    eprintln("error: missing file path after '-f'")
    exit(3)
  }
}
```

**Checking in pipelines:**

```bash
rl run script.rl -f config.txt
case $? in
  0) echo "success" ;;
  2) echo "bad usage" ;;
  3) echo "missing argument" ;;
  4) echo "invalid value" ;;
  5) echo "permission denied" ;;
  6) echo "file not found" ;;
  *) echo "unexpected error" ;;
esac
```

## License

MIT or Apache 2
