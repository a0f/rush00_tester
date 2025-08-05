#!/bin/bash

# generates expected outputs for rush functions
# Usage: ./generate_expected.sh rush00|rush01|rush02|rush03| x y

generate_rectangle() {
    local x=$1 y=$2 rush_type=$3
    
    # return prompt if dimensions are invalid
    if [ $x -le 0 ] || [ $y -le 0 ]; then
        return
    fi
    
    # character sets for each rush type
    case $rush_type in
        rush00)
            top_left="o"; top_mid="-"; top_right="o"
            mid_left="|"; mid_mid=" "; mid_right="|"
            bot_left="o"; bot_mid="-"; bot_right="o"
            ;;
        rush01)
            top_left="/"; top_mid="*"; top_right="\\"
            mid_left="*"; mid_mid=" "; mid_right="*"
            bot_left="\\"; bot_mid="*"; bot_right="/"
            ;;
        rush02)
            top_left="A"; top_mid="B"; top_right="A"
            mid_left="B"; mid_mid=" "; mid_right="B"
            bot_left="C"; bot_mid="B"; bot_right="C"
            ;;
        rush03)
            top_left="A"; top_mid="B"; top_right="C"
            mid_left="B"; mid_mid=" "; mid_right="B"
            bot_left="A"; bot_mid="B"; bot_right="C"
            ;;
        rush04)
            top_left="A"; top_mid="B"; top_right="C"
            mid_left="B"; mid_mid=" "; mid_right="B"
            bot_left="C"; bot_mid="B"; bot_right="A"
            ;;
    esac
    
    if [ $y -eq 1 ]; then
        # will trigger only on single row
        if [ $x -eq 1 ]; then
            printf "$top_left"
        else
            printf "$top_left"
            for ((i=2; i<x; i++)); do printf "$top_mid"; done
            printf "$top_right"
        fi
    else
        # will trigger on multiple rows
        # first line
        if [ $x -eq 1 ]; then
            printf "$top_left"
        else
            printf "$top_left"
            for ((i=2; i<x; i++)); do printf "$top_mid"; done
            printf "$top_right"
        fi
        printf "\n"
        
        # middle lines
        for ((row=2; row<y; row++)); do
            if [ $x -eq 1 ]; then
                printf "$mid_left"
            else
                printf "$mid_left"
                for ((i=2; i<x; i++)); do printf "$mid_mid"; done
                printf "$mid_right"
            fi
            printf "\n"
        done

        # last line
        if [ $x -eq 1 ]; then
            printf "$bot_left"
        else
            printf "$bot_left"
            for ((i=2; i<x; i++)); do printf "$bot_mid"; done
            printf "$bot_right"
        fi
    fi
    printf "\n"
}

# run it if you used it properly
if [ $# -eq 3 ]; then
    rush_func=$1
    x=$2
    y=$3
    generate_rectangle $x $y $rush_func
else
	echo "Too many arguments nerd. Usage: $0 rush00|rush01|rush02|rush03| x y"
fi
