*** THIS IS NOT A SUBSTISTUTE FOR ACTUAL TESTING, ON FAILURES VERIFY THIS TESTER IS WORKING AS INTENDED ***

# Rush Tester

Script to test rush00-rush04 projects.

## Setup

Place rush_tester.sh generate_expected.sh into the directory with the rush c files to test (main.c, putchar_c. rush.c)

```bash
chmod +x rush_tester.sh generate_expected.sh
```

## Usage

```bash
./rush_tester.sh rush00          # Test rush00
./rush_tester.sh rush01 -v       # Test rush01 verbose mode
```

Options:
- `rush00|rush01|rush02|rush03|rush04` - Which rush to test
- `-v` or `--verbose` - Show all test details

## Individual Scripts

### rush_tester.sh
Main testing script. Tests the given implementation against reference.

### generate_expected.sh
Reference implementation written in bash. Generates correct output to compare to.

```bash
./generate_expected.sh rush00 5 3    # Generate 5x3 rush00 output
./generate_expected.sh rush01 1 1    # Generate 1x1 rush01 output
```

## Test Cases

42 test cases including:
- Basic rectangles (5x3, 2x2)
- Edge cases (0x0, 1x1)
- Large rectangles (100x5)
- Invalid inputs (-5, 0)

## Customizing

Edit test_cases array at top of rush_tester.sh:

```bash
declare -a test_cases=(
    "0 0" "1 1" "2 2" "5 3"
)
```

## Files Required

- rush00.c (or rush01.c, etc. for whatever version/s you want to test against)
- main.c
- ft_putchar.c

## Debugging

Failed tests saved to test_logs/rushXX/:

```bash
cat test_logs/rush00/expected_5x3.txt
cat test_logs/rush00/output_5x3.txt
```

## Common Issues

- "Command not found": Run chmod +x on scripts
- "Compilation failed": Check code compiles with -Wall -Wextra -Werror
- All tests fail: Make sure rush function prints newline at end

*** THIS IS NOT A SUBSTISTUTE FOR ACTUAL TESTING, ON FAILURES VERIFY THIS TESTER IS WORKING AS INTENDED ***
