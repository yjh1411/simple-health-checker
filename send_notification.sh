#!/bin/bash

send_discord_notification() {
    curl \
        -H "Content-Type: application/json" \
        -d "{ \"embeds\": [{\"type\":\"rich\",\"title\":\"Health check failed\",\"description\":\"$1\",\"color\":$2,\"fields\":[{\"name\":\"URL\",\"value\":\"$3\"},{\"name\":\"Status Code\",\"value\":\"$4\"}],\"footer\":{\"text\":\"$(date)\"}}] }" \
        "$DISCORD_WEBHOOK_URI"
}
