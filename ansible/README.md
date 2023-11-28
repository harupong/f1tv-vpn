reserve-seattle-rnd
172.245.108.57
Root/Admin Password: 5046Rzy1ah1CNWGAnz




## initial setup
```
# on client
ansible-playbook -i inventory playbook.yml

# then, on the node, bring up docker based services and configure cron jobs
cd docker
docker compose up -d
crontab utils.crontab
```

## various commands
### Check status
```
docker exec -it tailscaled tailscale --socket /tmp/tailscaled.sock status
docker exec -it vnstat vnstat
```

### backup tailscale conf file
```
# backup on vps
tar -czvf ${HOME}/tailscale-conf-$(hostname).tar.gz /var/lib/tailscale/
tar -czvf ${HOME}/vnstat-conf-$(hostname).tar.gz /var/lib/vnstat/

# on client
scp "root@<host ip>:./*-conf*.tar.gz" .

# restore on vps

```


