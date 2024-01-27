#!/bin/bash
#
# healthcheck.io

set -aux

API_KEY=${HC_RW_API_KEY}
HOSTNAME=$(hostname)

####################################
# CHECK FOR TAILSCALE STATUS
## create a check for the server if not available 
function tailscale_status() {
    local ts_prefix="ts-"
    local ts_url
    ts_url=$(get_check_url ${ts_prefix})

    if [[ -z "${ts_url}" ]]; then
        local ts_payload
        ts_payload=$(jq -n '{
            "name": "'$ts_prefix''$HOSTNAME'",
            "slug": "'$ts_prefix''$HOSTNAME'",
            "grace": 900,
            "schedule": "*/10 * * * *",
            "tz": "Asia/Tokyo",
            "unique": ["name"],
            "tags": "f1vpn tailscale",
            "channels": "*"}')
        ts_url=$( \
            curl \
                --silent \
                --header "X-Api-Key: $API_KEY" \
                --data "$ts_payload" \
                https://healthchecks.io/api/v3/checks/ \
            | jq -r '.ping_url')
    fi

    ## if tailscale fails, there is no ping made
    local server_stats
    server_stats=$(top -n 1 -b -d 2 | head -n5)
    tailscale status && curl_command "${server_stats}" "${ts_url}"
}

####################################
# CHECK FOR SERVER BANDWIDTH USAGE
function bandwidth_status() {
    local bw_prefix="bw-"
    local bw_url
    bw_url=$(get_check_url ${bw_prefix})

    if [[ -z "${bw_url}" ]]; then
        local bw_payload
        bw_payload=$(jq -n '{
            "name": "'$bw_prefix''$HOSTNAME'",
            "slug": "'$bw_prefix''$HOSTNAME'",
            "grace": 43200,
            "schedule": "*/10 * * * *",
            "tz": "Asia/Tokyo",
            "unique": ["name"],
            "tags": "f1vpn bandwidth",
            "channels": "*"}')
        bw_url=$( \
            curl \
                --silent \
                --header "X-Api-Key: $API_KEY" \
                --data "$bw_payload" \
                https://healthchecks.io/api/v3/checks/ \
            | jq -r '.ping_url')
    fi

    ## Check fails if monthly tx/rx total is greater than 900GB
    local monthly_bw_usage
    monthly_bw_usage=$( \
        sudo docker exec vnstat vnstat --oneline b \
        | cut -d';' -f11 \
        | awk '{ printf "%d", $1 / (1024 * 1024 * 1024) }')
    if [[ ${monthly_bw_usage} -gt 900 ]]; then bw_url=${bw_url}/fail; fi
    
    status="Bandwidth used: ${monthly_bw_usage} GB"
    sudo docker container exec vnstat pgrep vnstatd \
    && curl_command "${status}" "${bw_url}"
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
    tailscale_status
    bandwidth_status
}

main "$@"