#!/bin/bash
#
# healthcheck.io

set -aux

API_KEY=${HC_RW_API_KEY}
HOSTNAME=${1}

####################################
# CHECK FOR EXIT NODE STATUS
## create a check for the server if not available 
function exitnode_status() {
    local en_prefix="en-"
    local en_url
    en_url=$(get_check_url ${en_prefix})

    if [[ -z "${en_url}" ]]; then
        local en_payload
        en_payload=$(jq -n '{
            "name": "'$en_prefix''$HOSTNAME'",
            "slug": "'$en_prefix''$HOSTNAME'",
            "grace": 900,
            "schedule": "*/10 * * * *",
            "tz": "Asia/Tokyo",
            "unique": ["name"],
            "tags": "f1vpn exitnode",
            "channels": "*"}')
        en_url=$( \
            curl \
                --silent \
                --header "X-Api-Key: $API_KEY" \
                --data "$en_payload" \
                https://healthchecks.io/api/v3/checks/ \
            | jq -r '.ping_url')
    fi

    curl_command "Exit node ${HOSTNAME} is working" "${en_url}"
}


#######################################
# Get existing check url from healthchecks.io
# Arguments:
#   PREFIX for a slug
#######################################
function get_check_url() {
    curl \
        --silent \
        --header "X-Api-Key: ${API_KEY}" \
        "https://healthchecks.io/api/v3/checks/?slug=${1}${HOSTNAME}" \
    | jq -r '.checks[]?.ping_url'
}

#######################################
# Post status to healthchecks.io
# Arguments:
#   STATUS to be posted to healthchecks.io
#   URL to post to
#######################################
function curl_command() {
    curl --max-time 10 --retry 5 --data-raw "${1}" "${2}" 
}

function main() {
    exitnode_status
}

main "$@"