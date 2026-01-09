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
                echo "Eroare: -n necesită un număr"
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

process_command() {
    local base_file=$1
    local cmd=$2
    
    FILES=()
    for i in 4 3 2 1; do
        [[ -f "${base_file}.${i}" ]] && FILES+=("${base_file}.${i}")
    done
    FILES+=("$base_file")
    
    ARGS=""
    [[ -n "$PRINT_HOSTNAME" ]] && ARGS="$ARGS -w"
    [[ -n "$SHOW_SYSTEM" ]] && ARGS="$ARGS -x"
    [[ -n "$SHOW_TIME" ]] && ARGS="$ARGS -F"
    
    for file in "${FILES[@]}"; do
        $cmd $ARGS -f "$file" 2>/dev/null
    done | if [[ -n "$NUM_LINES" ]]; then
        head -n "$NUM_LINES"
    else
        cat
    fi
}

if [[ "$COMMAND_TYPE" == "last" ]]; then
    process_command "/var/log/wtmp" "last"
elif [[ "$COMMAND_TYPE" == "lastb" ]]; then
    process_command "/var/log/btmp" "lastb"
fi