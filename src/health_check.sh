#!/bin/bash

. src/send_notification.sh

max_timeout="${TIMEOUT:-500}"

check_http_status() {
    local url="$1"

    if [ -z "$url" ]; then
        return 0
    fi

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

        if (($(bc <<<"$time_taken >= $max_timeout"))); then
            message='🐌 Server responded successfully, but it was too slow.'
            color='16761095'
        fi
    fi

    if [ -n "$message" ]; then
        send_discord_notification "$message" "$color" "$url" "$http_status" "$time_taken ms"
    fi

    echo "$status: $url with status $http_status"
}

check_response_contains_text() {
    local url="$1"

    if [ -z "$url" ]; then
        return 0
    fi

    local target_string="$2"
    local status="unknown"
    local color="0"
    local message=""
    local http_response
    local http_status
    local time_taken
    local response_body

    http_response=$(curl -s -w '\n%{http_code} %{time_total}\n' "$url")
    http_status=$(echo "$http_response" | tail -n 1 | awk '{print $1}')
    time_taken=$(echo "$http_response" | tail -n 1 | awk '{printf "%.3f", $2 * 1000}')
    response_body=$(echo "$http_response" | sed '$d')

    if echo "$response_body" | grep -q "$target_string"; then
        status='Succeeded'
    else
        status='Failed'
        message="😑 String \`$target_string\` not found in HTTP response"
        color='16007990'
    fi

    if [ -n "$message" ]; then
        send_discord_notification "$message" "$color" "$url" "$http_status" "$time_taken ms"
    fi

    echo "$status: $url with status $http_status"
}

if [ -z "$HTTP_STATUS_CHECK" ] && [ -z "$HTTP_REPONSE_CHECK" ]; then
    echo "There's nothing to check"
    exit 5
fi

# Check HTTP status of URLs
if [ -n "$HTTP_STATUS_CHECK" ]; then
    readarray -t http_status_check_list <<<"$HTTP_STATUS_CHECK"

    for url in "${http_status_check_list[@]}"; do
        check_http_status "$url"
    done
fi

# Check if the response of URLs contains a target string
if [ -n "$HTTP_RESPONSE_CHECK" ]; then
    readarray -t http_response_check_list <<<"$HTTP_RESPONSE_CHECK"

    for line in "${http_response_check_list[@]}"; do
        read -ra splitted <<<"$line"
        check_response_contains_text "${splitted[0]}" "${splitted[1]}"
    done
fi
