# docker-rspamd
Dockerfile to run [rspamd](https://rspamd.com/) as a docker container, worker-proxy is used instead of worker-normal as it spawns a new worker if there is a crash while processing.

It has two map files which can be edited in the web UI, filename for extensions to reject and whitelist for domains to whitelist.

Environment Variables

| NAME   | Description                                     | Default           |
| ------ | ----------------------------------------------- | ----------------- | 
| REDIS  | name/container name or IP of the redis server.  | none (No redis)   |
| OLEFY  | name/container name or IP of the Olefy server.  | do not use Olefy  |
| DCCIFD | name/container name or IP of the DCCIFD server. | do not use dccifd |

To run connecting to container network without exposing ports (accessible from host network), and docker managed volumes
```
#docker container run --net MYNET --name rspamd --restart=unless-stopped --mount source=rspamd-var,target=/var/lib/rspamd --mount source=rspamd-over,target=/etc/rspamd/override.d -d a16bitsysop/rspamd
```

To run without connecting to container network exposing ports (accessible from host network), and docker managed volumes
```
#docker container run -p 11332:11332 -p 11334:11334 --name rspamd --restart=unless-stopped --mount source=rspamd-var,target=/var/lib/rspamd --mount source=rspamd-over,target=/etc/rspamd/override.d -d a16bitsysop/rspamd
```
