#!/usr/bin/env bash

# Console colors
black='\033[0;30m'
red='\033[0;31m'
green='\033[0;32m'
green_bg='\033[39;42m'
yellow='\033[1;33m'
bold='\033[1m'
NC='\033[0m'

echo-red () { echo -e "${red}$1${NC}"; }
echo-green () { echo -e "${green}$1${NC}"; }
echo-green-bg () { echo -e "${green_bg}$1${NC}"; }
echo-yellow () { echo -e "${yellow}$1${NC}"; }

function slack_notify {
    MESSAGE_TEXT=${1}
    MESSAGE_TEXT="${MESSAGE_TEXT//\'/\'}"
    curl -X POST --data-urlencode "payload={'channel': '${SLACK_CHANNEL}', 'username': '${SLACK_USERNAME}', 'text': '${MESSAGE_TEXT}', 'icon_emoji': ':${SLACK_ICON}:'}" ${SLACK_WEBHOOK}
}
# Usage: random_string N
function random_string {
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-32} | head -n 1
}

function my_ip {
    ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | head -n 1
}

function sanitize_string {
    echo $1 | tr A-Z a-z | sed -e 's/[^a-zA-Z0-9]/_/g'
}
