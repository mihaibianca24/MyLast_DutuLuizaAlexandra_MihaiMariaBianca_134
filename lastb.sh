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
                echo "Eroare: -n necesită un număr" >&2
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
    
    if ! command -v "$cmd" &> /dev/null; then
        echo "Eroare: Comanda '$cmd' nu este instalată." >&2
        exit 1
    fi
    local files=()
    for i in 4 3 2 1; do
        [[ -f "${base_file}.${i}.gz" ]] && files+=("${base_file}.${i}.gz")
        [[ -f "${base_file}.${i}" ]] && files+=("${base_file}.${i}")
    done
    [[-f "$base_file" ]] &&
    files+=("$base_file")

    if [[ ${#files[@]} -eq 0 ]]; then
        echo "Eroare: Fisierele $base_file* nu exista." >&2
        exit 1
    fi

    local readable_count=0
    for file in "${files[@]}"; do
        [[ -r "$file" ]] && ((readable_count++))
    done
    
    if [[ $readable_count -eq 0]]; then
        echo "Eroare: Nu aveti permisiuni pentru a citi $base_file*" >&2
        echo "Incercati: sudo $0 $*" >&2
        exit 1
    fi
    local args=""
    [[ -n "$PRINT_HOSTNAME" ]] && args="$args -w"
    [[ -n "$SHOW_SYSTEM" ]] && args="$args -x"
    [[ -n "$SHOW_TIME" ]] && args="$args -F"
   {
    for file in "${files[@]}"; do
        [[ ! -r "$file" ]] && continue
        if [[ "$file" == *.gz ]]; then
            if ! command -v zcat &> /dev/null; then
                echo "Avertisment: zcat nu este instalat, sar peste $file" >&2
                continue
            fi
            local temp=$(mktemp)
            if zcat "$file" > "$temp" 2>/dev/null; then
                 $cmd $args -f "$temp" 2>/dev/null
            fi
            rm -f "$temp"
        else
            $cmd $args -f "$file" 2>/dev/null
        fi
    done 
   } | if [[ -n "$NUM_LINES" ]]; then
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