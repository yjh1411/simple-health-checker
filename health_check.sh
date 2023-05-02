#!/bin/bash

. ./send_notification.sh

check_http_status() {
    local url="$1"
    local http_status
    http_status=$(curl -s -o /dev/null -w "%{http_code}" "$url")
    local status="unknown"
    local color="0"
    local message=""

    if [ "$http_status" -eq 000 ]; then
        status='Failed (URL not found)'
        message='❌ The URL you provided does not seem to exist.'
        color="10395294"
    elif [ "$http_status" -ge 400 ]; then
        status='Failed (HTTP error)'
        message='🚨 Failed to check sites health.'
        color='16007990'
    elif [ "$http_status" -ge 300 ]; then
        status='Failed (Redirection)'
        message='🚚 Server responded with a redirection message.'
        color='16761095'
    else
        status='Succeeded'
        color='3066993'
    fi

    if [ "$status" != 'Succeeded' ]; then
        send_discord_notification "$message" "$color" "$url" "$http_status"
    fi

    echo "$status: $url with status $status"
}

readarray -t http_status_check_list <<<"$HTTP_STATUS_CHECK"

for url in "${http_status_check_list[@]}"; do
    check_http_status "$url"
done
