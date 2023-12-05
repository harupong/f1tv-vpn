#!/bin/bash
# healthcheck.io

API_KEY=${HC_RW_API_KEY}
HOSTNAME=$(hostname)

####################################
# CHECK FOR TAILSCALE STATUS
## create a check for the server if not available 
ts_url=$(curl -s --header "X-Api-Key: ${API_KEY}" "https://healthchecks.io/api/v3/checks/?slug=ts-${HOSTNAME}" | jq -r '.checks[]?.ping_url')
if [ -z "${ts_url}" ]; then
    TS_PAYLOAD='{"name": "ts-'$HOSTNAME'", "slug": "ts-'$HOSTNAME'", "grace": 900, "schedule": "*/10 * * * *", "tz": "Asia/Tokyo" , "unique": ["name"], "tags": "f1vpn tailscale", "channels": "*"}'
    ts_url=$(curl --silent https://healthchecks.io/api/v3/checks/  -H "X-Api-Key: $API_KEY" -d "$TS_PAYLOAD" | jq -r '.ping_url')
fi

## if tailscale fails, there is no ping made
tailscale status && curl -m 10 --retry 5 ${ts_url}

####################################
# CHECK FOR SERVER BANDWIDTH USAGE
bw_url=$(curl -s --header "X-Api-Key: ${API_KEY}" "https://healthchecks.io/api/v3/checks/?slug=bw-${HOSTNAME}" | jq -r '.checks[]?.ping_url')
if [ -z "${bw_url}" ]; then
    BW_PAYLOAD='{"name": "bw-'$HOSTNAME'", "slug": "bw-'$HOSTNAME'", "grace": 43200, "schedule": "*/10 * * * *", "tz": "Asia/Tokyo" , "unique": ["name"], "tags": "f1vpn bandwidth", "channels": "*"}'
    bw_url=$(curl --silent https://healthchecks.io/api/v3/checks/  -H "X-Api-Key: $API_KEY" -d "$BW_PAYLOAD" | jq -r '.ping_url')
fi

## Check fails if monthly tx/rx total is greater than 900GB
MONTHLY_BW_USAGE=$(sudo docker exec vnstat vnstat --oneline b | expr $(cut -d ";" -f 11) / 1024 / 1024 / 1024)
if [ ${MONTHLY_BW_USAGE} -gt 900 ]; then bw_url=${bw_url}/fail; fi
curl -m 10 --retry 5 --data-raw "Bandwidth used: ${MONTHLY_BW_USAGE} GB" ${bw_url}