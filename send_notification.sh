#!/bin/bash

send_discord_notification() {
    local description="$1"
    local color="$2"
    local url="$3"
    local status="$4"

    local json_payload

    json_payload=$(
        cat <<EOF
{
  "embeds": [
    {
      "type": "rich",
      "title": "Health check failed",
      "description": "$description",
      "color": $color,
      "fields": [
        {
          "name": "URL",
          "value": "$url"
        },
        {
          "name": "Status Code",
          "value": "$status"
        }
      ],
      "footer": {
        "text": "$(date)"
      }
    }
  ]
}
EOF
    )

    curl \
        -H "Content-Type: application/json" \
        -d "$json_payload" \
        "$DISCORD_WEBHOOK_URI"
}
