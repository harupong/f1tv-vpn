#!/usr/bin/env -S bash -l

set -ex

push_url="https://f1vpn-uptime-kuma.fly.dev/api/push/"

df_status() {
    local percentage=$(df --total --human-readable --exclude-type=tmpfs | tail -n1 | awk '{printf $5}')
    local threshold="80"  # 80%
    local number=${percentage%\%*}
    local message="Used disk space is ${number}%" 

    if [ $number -lt $threshold ]; then
        local service_status="up"
    else
        local service_status="down"
    fi

    curl_command ${service_status} "${message}" ${number} ${DF_ID}
}

tailscale_status() {
    local state=$(tailscale status > /dev/null && tailscale netcheck | head -n11 | tail -n1 | awk -F ': |(m|µ)s' '{print $2}')
    state=${state%.*}

    if [ $state -ge 0 ]; then
        local service_status="up"
        local message="Ping to Closest DERP server returned in ${state} seconds."
    else
        local service_status="down"
        local message="Ping to Closest DERP server failed"
    fi

    curl_command ${service_status} "${message}" ${state} ${TS_ID}
}

bw_status() {
    local usage=$(sudo docker exec vnstat vnstat --oneline b | expr $(cut -d ";" -f 11) / 1024 / 1024 / 1024)
    local threshold="900"  # 900GB
    local message="Used bandwidth is ${usage}GB" 

    if [ $usage -lt $threshold ]; then
        local service_status="up"
    else
        local service_status="down"
    fi

    curl_command ${service_status} "${message}" ${usage} ${BW_ID}
}

# curl_command <service_status> <message> <ping> <uptimekuma_id>
curl_command() {
    curl \
        --get \
        --data-urlencode "status=${1}" \
        --data-urlencode "msg=${2}" \
        --data-urlencode "ping=${3}" \
        --silent \
        "${push_url}${4}" \
        > /dev/null
}

df_status
tailscale_status
bw_status
