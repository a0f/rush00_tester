#!/bin/bash

# Rush Tester Script for Rush0X
# Run it by executing:
# chmod +x rush_tester.sh
# then run ./rush_tester.sh rush00

# by default it runs in regular mode, showing only failures in detail.
# adding -v or --verbose will show all test details, and save outputs to logs
# even in the case of passes.

# You can add more test cases here. The current number is 42 :)
declare -a test_cases=(
    "0 0" "1 1" "2 2" "1 50" "50 1" "2 50" "50 2" "3 3" "6 4" "7 7"
    "2 1" "1 2" "3 1" "1 3" "8 8" "20 1" "1 20" "15 10" "100 5" "5 100"
    "2 3" "3 2" "4 1" "1 4" "6 6" "12 12" "50 2" "2 50" "25 25" "30 15"
    "1 10" "10 1" "7 3" "3 7" "9 4" "4 9" "11 11" "13 7" "-5 0" "0 -5"
    "-50 -2" "42 42"
)

# check if rush name is provided

if [ -z "$1" ]; then
    echo "Usage: ./rush_tester.sh rush00|rush01|rush02|rush03|rush04 [-v|--verbose]"
    exit 1
fi

# parse the arguments given to the script
VERBOSE=false
RUSH_NAME=""

for arg in "$@"; do
    case $arg in
        -v|--verbose)
            VERBOSE=true
            ;;
        rush0[0-4])
            RUSH_NAME="$arg"
            ;;
        *)
            echo "Unknown argument: $arg"
            echo "Usage: ./rush_tester.sh rush00|rush01|rush02|rush03|rush04 [-v|--verbose]"
            exit 1
            ;;
    esac
done

# check if rush name is set

if [ -z "$RUSH_NAME" ]; then
    echo "Error: No rush version specified"
    echo "Usage: ./rush_tester.sh rush00|rush01|rush02|rush03|rush04 [-v|--verbose]"
    exit 1
fi

# set up variables
RUSH_FILE="$RUSH_NAME.c"
EXEC="./$RUSH_NAME"
SRC_FILES="main.c ft_putchar.c $RUSH_FILE"
CFLAGS="-Wall -Wextra -Werror"
TMP_OUT="tmp_output.txt"
TMP_EXP="tmp_expected.txt"
BACKUP_MAIN="main_original_backup.c"
LOG_DIR="test_logs/$RUSH_NAME"

# check if rush file exists

if [ ! -f "$RUSH_FILE" ]; then
    echo "❌ Error: $RUSH_FILE not found"
    exit 1
fi

# create log directory if it doesn't exist and or clean it up

mkdir -p "$LOG_DIR"
rm -f "$LOG_DIR"/*

# backup the original main.c file
# then create a new main.c file for testing
# this is non-destructive to the original main.c

cp main.c "$BACKUP_MAIN"

cat << 'EOF' > main.c
#include <stdlib.h>

void rush(int x, int y);

int main(int argc, char **argv)
{
    if (argc != 3)
        return 1;
    int x = atoi(argv[1]);
    int y = atoi(argv[2]);
    rush(x, y);
    return 0;
}
EOF

# compile the rush file with the test main.c

echo "Compiling $RUSH_FILE with test main.c..."
cc $CFLAGS $SRC_FILES -o $EXEC
if [ $? -ne 0 ]; then
    echo "❌ Compilation failed"
    mv "$BACKUP_MAIN" main.c
    exit 1
fi

# check if generate_expected.sh exists

if [ ! -f "./generate_expected.sh" ]; then
    echo "❌ Error: generate_expected.sh not found"
    mv "$BACKUP_MAIN" main.c
    exit 1
fi

PASSED=0
FAILED=0
TEST_NUM=0

# run the tests for each case in test_cases array (top of document to edit test cases)

for input in "${test_cases[@]}"; do
    ((TEST_NUM++))
    ./generate_expected.sh $RUSH_NAME $input > "$TMP_EXP"
    
    $EXEC $input > "$TMP_OUT"

    input_clean=$(echo "$input" | tr ' ' 'x')
    
    if [ "$VERBOSE" = true ]; then
        cp "$TMP_OUT" "$LOG_DIR/output_${input_clean}.txt"
        cp "$TMP_EXP" "$LOG_DIR/expected_${input_clean}.txt"
    fi
    
    # compare the output with the expected output
    # if they match, pass and increment passed count
    # if they don't match, fail and increment failed count
    # also print the expected and actual output for debugging

    if diff -q "$TMP_OUT" "$TMP_EXP" > /dev/null; then
        echo "[Test $TEST_NUM/42] $RUSH_NAME($input) [✅ PASS]"
        # print expected and actual output even on pass if verbose is true
        if [ "$VERBOSE" = true ]; then
            echo "Expected:"
            cat "$TMP_EXP"
            echo "---"
            echo "Got:"
            cat "$TMP_OUT"
            echo "======"
        fi
        ((PASSED++))
    # if they don't match, print the expected and actual output
    # and save them to log directory (always save failed tests for debugging)
    else
        # always save failed test outputs for debugging (if not already saved in verbose mode)
        if [ "$VERBOSE" = false ]; then
            cp "$TMP_OUT" "$LOG_DIR/output_${input_clean}.txt"
            cp "$TMP_EXP" "$LOG_DIR/expected_${input_clean}.txt"
        fi
        echo "[Test $TEST_NUM/42] $RUSH_NAME($input) [❌ FAIL]"
        echo "Expected:"
        cat "$TMP_EXP"
        echo "---"
        echo "Got:"
        cat "$TMP_OUT"
        echo "======"
        ((FAILED++))
    fi
done

# clean up temporary files and restore original main.c

rm -f "$TMP_OUT" "$TMP_EXP" "$EXEC"
mv "$BACKUP_MAIN" main.c

# print final total of passed and failed tests

echo "Summary of results for $RUSH_NAME:"
echo "✅ Passed: $PASSED"
echo "❌ Failed: $FAILED"
if [ "$FAILED" -eq 0 ]; then
    echo "All $RUSH_NAME tests passed! Congratulations!"
    if [ "$VERBOSE" = true ]; then
        echo "All test outputs saved to $LOG_DIR/ for review."
    fi
else
    echo "Some tests failed. Check $LOG_DIR/ for detailed output diffs."
    echo "Example: diff -u $LOG_DIR/expected_5x3.txt $LOG_DIR/output_5x3.txt"
fi