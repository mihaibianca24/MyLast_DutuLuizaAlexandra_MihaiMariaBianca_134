#!/bin/bash

NUM_LINES=""
PRINT_HOSTNAME=""
SHOW_SYSTEM=""
SHOW_TIME=""
COMMAND_TYPE="last"

usage() {
    echo "Utilizare: $0 [-n NUM] [-p] [-s] [-t] [last|lastb]"
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -n)
            if [[ -z "$2" || ! "$2" =~ ^[0-9]+$ ]]; then
                echo "Eroare: -n necesita un nr"
                exit 1
            fi
            NUM_LINES="$2"
            shift 2
            ;;
        -p)
            PRINT_HOSTNAME="yes"
            shift
            ;;
        -s)
            SHOW_SYSTEM="yes"
            shift
            ;;
        -t)
            SHOW_TIME="yes"
            shift
            ;;
        last|lastb)
            COMMAND_TYPE="$1"
            shift
            ;;
        *)
            usage
            ;;
    esac
done

if [[ "$COMMAND_TYPE" == "last" ]]; then
    BASE_FILE="/var/log/wtmp"
    
    FILES=()
    for i in 4 3 2 1; do
        [[ -f "${BASE_FILE}.${i}" ]] && FILES+=("${BASE_FILE}.${i}")
    done
    FILES+=("$BASE_FILE")

    ARGS=""
    [[ -n "$PRINT_HOSTNAME" ]] && ARGS="$ARGS -w"
    [[ -n "$SHOW_SYSTEM" ]] && ARGS="$ARGS -x"
    [[ -n "$SHOW_TIME" ]] && ARGS="$ARGS -F"
    
    for file in "${FILES[@]}"; do
        last -f "$file" 2>/dev/null
    done | if [[ -n "$NUM_LINES" ]]; then
        head -n "$NUM_LINES"
    else
        cat
    fi
fi  
