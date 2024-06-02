#!/bin/bash

send_discord_notification() {
    local description="$1"
    local color="$2"
    local url="$3"
    local status="$4"
    local time_taken="$5"

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
        },
        {
          "name": "Time taken",
          "value": "$time_taken"
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

send_to_groups_custom() {
  curl -X POST "https://kapi.kakao.com/v1/api/talk/friends/message/default/send" \
       -H "Authorization: Bearer ${INPUT_KAKAO_ACCESS_TOKEN}" \
       -H "Content-Type: application/x-www-form-urlencoded" \
       -d "template_id=${INPUT_TEMPLATE_ID}&template_args=${INPUT_TEMPLATE_ARGS}&receiver_uuids=${INPUT_RECEIVER_UUIDS}"
}

send_to_me_custom() {
  curl -X POST "https://kapi.kakao.com/v2/api/talk/memo/send" \
       -H "Authorization: Bearer ${INPUT_KAKAO_ACCESS_TOKEN}" \
       -H "Content-Type: application/x-www-form-urlencoded" \
       -d "template_id=${INPUT_TEMPLATE_ID}&template_args=${INPUT_TEMPLATE_ARGS}"
}

# Execute the desired function based on the function_name input
case "${INPUT_FUNCTION_NAME}" in
  send_to_groups_custom)
    send_to_groups_custom
    ;;
  send_to_me_custom)
    send_to_me_custom
    ;;
  *)
    echo "Invalid function name: ${INPUT_FUNCTION_NAME}"
    exit 1
    ;;
esac
