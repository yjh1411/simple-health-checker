#!/bin/bash

send_discord_notification() {
    curl \
        -H "Content-Type: application/json" \
        -d "{ \"embeds\": [{\"type\":\"rich\",\"title\":\"Health check failed\",\"description\":\"$1\",\"color\":$2,\"fields\":[{\"name\":\"URL\",\"value\":\"$3\"},{\"name\":\"Status Code\",\"value\":\"$4\"}],\"footer\":{\"text\":\"$(date)\"}}] }" \
        "$DISCORD_WEBHOOK_URI"
}

readarray -t http_status_check_list <<<"$HTTP_STATUS_CHECK"

for url in "${http_status_check_list[@]}"; do
    http_status=$(curl -s -o /dev/null -w "%{http_code}" "$url")

    if [ "$http_status" -eq 000 ]; then
        send_discord_notification '❌ The URL you provided does not seem to exist.' 10395294 "$url" "$http_status"
        echo "⚪Failed: $url with status $http_status"
    elif [ "$http_status" -ge 400 ]; then
        send_discord_notification '🚨 Failed to check sites health.' 16007990 "$url" "$http_status"
        echo "🔴Failed: $url with status $http_status"
    elif [ "$http_status" -ge 300 ]; then
        send_discord_notification '🚚 Server responded with a redirection message.' 16761095 "$url" "$http_status"
        echo "🟡Failed: $url with status $http_status"
    else
        echo "🟢Succeed: $url with status $http_status"
    fi
done
