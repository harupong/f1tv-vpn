## various utility for maintaining f1vpn
### healthchecks.sh
This script pings [Healthchecks\.io](https://healthchecks.io/) periodically for:

- tailscale status check
- monthly rx/tx bandwidth check

#### how to setup cron job
1. `apt install curl jq vnstat` to install deps
2. `scp -p -r utils/ <server address>: ` and cd into it
3. `mv .env.example .env` and fill in API KEY for healthchecks.io
4. make sure to `chmod +x healthchecks.sh`
5. `crontab utils.crontab` and all good to go!!