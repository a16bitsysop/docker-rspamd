# docker-rspamd
Dockerfile to run [rspamd](https://rspamd.com/) as a docker container, worker-proxy is used instead of worker-normal as it spawns a new worker if there is a crash while processing.

[![Docker Pulls](https://img.shields.io/docker/pulls/a16bitsysop/rspamd.svg?style=flat-square)](https://hub.docker.com/r/a16bitsysop/rspamd/)
[![Docker Stars](https://img.shields.io/docker/stars/a16bitsysop/rspamd.svg?style=flat-square)](https://hub.docker.com/r/a16bitsysop/rspamd/)
[![Version](https://images.microbadger.com/badges/version/a16bitsysop/rspamd.svg)](https://microbadger.com/images/a16bitsysop/rspamd "Get your own version badge on microbadger.com")
[![Commit](https://images.microbadger.com/badges/commit/a16bitsysop/rspamd.svg)](https://microbadger.com/images/a16bitsysop/rspamd "Get your own commit badge on microbadger.com")
[![GitHub Super-Linter](https://github.com/a16bitsysop/docker-rspamd/workflows/Super-Linter/badge.svg)](https://github.com/marketplace/actions/super-linter)

It has several map files which can be edited in the web UI, including filename for extensions to reject and whitelist for domains to whitelist.  The maps are stored in /etc/rspamd/local.d/maps.d , they are also copied from maps.orig to maps.d if not present during startup for a container with mounted volumes or new maps in a newer image.

To generate a password hash for the web interface run container then run rspamd_pw.sh and copy output into /etc/rspamd/override.d/worker-controller.inc.  Or exec rspamadm pw inside container and use result for password and enable_password.

This is then retained in the persistent volume if mounted.

It is configured to read the dkim/arc keys from redis, to manually add a key to redis instructions are on the Rspamd website [https://rspamd.com/doc/modules/dkim_signing.html#dkim-keys-in-redis](https://rspamd.com/doc/modules/dkim_signing.html#dkim-keys-in-redis).

To change the configuration add changes to the /etc/rspamd/override.d directory, and mount it with a volume.

Neural is configured for low email volume.

The docker offical image for redis has an alpine variant as well which is redis:alpine

Configuration for Spamhaus [DQS](https://github.com/spamhaus/rspamd-dqs) is now added, to enable DQS:

* Check the [usage terms](https://www.spamhaus.org/organization/dnsblusage/)
* Register for a key with [Spamhaus](https://www.spamhaustech.com/dqs/).
* Confirm email address, then access details will be emailed.
* Login to portal, DQS key is the "Datafeed Query Account Key" [here](https://portal.spamhaustech.com/manuals/dqs)
* Copy the key and write it to a file, then bind mount the file with docker to /etc/rspamd/rspamd-dqs/dqs-key
* If the file exists DQS is then configured.

Abuse.ch, the Malware Bazaar hashes are downloaded every BZSLEEP hours if set,
minimum is 1 hour as they are updated every hour.
See [here](https://bazaar.abuse.ch/).

## Github
Github Repository: [https://github.com/a16bitsysop/docker-rspamd](https://github.com/a16bitsysop/docker-rspamd)

## Environment Variables

| NAME      | Description                                            | Default            |
| --------- | ------------------------------------------------------ | ------------------ |
| REDIS     | name/container name or IP of the redis server.         | none (No redis)    |
| OLEFY     | name/container name or IP of the Olefy server.         | do not use Olefy   |
| RAZORFY   | name/container name or IP of the Razorfy server.       | do not use Razorfy |
| DCCIFD    | name/container name or IP of the DCCIFD server.        | do not use dccifd  |
| CLAMAV    | name/container name or IP of the ClamAV server.        | do not use ClamAV  |
| CONTROLIP | name/container name or IP of rspamc process.           | none               |
| DNSSEC    | enable dnssec for dns lookups.                         | no dnssec          |
| NOGREY    | disable greylisting (soft reject).                     | greylist           |
| BZSLEEP   | hours between updates of abuse.ch hashes eg 1.5        | unset / disabled   |
| TIMEZONE  | timezone to use inside the container, eg Europe/London | unset              |

## Examples
To run connecting to container network without exposing ports (accessible from host network), and docker managed volumes
```bash
#docker container run --net MYNET --name rspamd --restart=unless-stopped --mount source=rspamd-var,target=/var/lib/rspamd --mount source=rspamd-over,target=/etc/rspamd/override.d -d a16bitsysop/rspamd
```

To run without connecting to container network exposing ports (accessible from host network), and docker managed volumes
```bash
#docker container run -p 11332:11332 -p 11334:11334 --name rspamd --restart=unless-stopped --mount source=rspamd-var,target=/var/lib/rspamd --mount source=rspamd-over,target=/etc/rspamd/override.d -d a16bitsysop/rspamd
```
