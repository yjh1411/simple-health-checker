#!/bin/bash

. ./send_notification.sh

check_http_status() {
    local url="$1"
    local status="unknown"
    local color="0"
    local message=""
    local http_response
    local http_status
    local time_taken

    http_response=$(curl -s -w "%{http_code} %{time_total}\n" "$url" -o /dev/null)
    http_status=$(awk '{print $1}' <<<"$http_response")
    time_taken=$(awk '{printf "%.3f", $2 * 1000}' <<<"$http_response")

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

        if (($(bc <<<"$time_taken >= 500"))); then
            message='🐌 Server responded successfully, but it was too slow.'
            color='16761095'
        fi
    fi

    if [ "$message" != '' ]; then
        send_discord_notification "$message" "$color" "$url" "$http_status" "$time_taken ms"
    fi

    echo "$status: $url with status $status"
}

if [ "$HTTP_STATUS_CHECK" == '' ]; then
    echo "There's nothing to check"
    exit 5
fi

readarray -t http_status_check_list <<<"$HTTP_STATUS_CHECK"

for url in "${http_status_check_list[@]}"; do
    check_http_status "$url"
done
