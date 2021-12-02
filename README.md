This repository has now moved to: [https://gitlab.com/container-email/rspamd](https://gitlab.com/container-email/rspamd)

# docker-rspamd
Dockerfile to run [rspamd](https://rspamd.com/) as a docker container, worker-proxy is used instead of worker-normal as it spawns a new worker if there is a crash while processing.

[![Docker Pulls](https://img.shields.io/docker/pulls/a16bitsysop/rspamd.svg?style=plastic)](https://hub.docker.com/r/a16bitsysop/rspamd/)
[![Docker Stars](https://img.shields.io/docker/stars/a16bitsysop/rspamd.svg?style=plastic)](https://hub.docker.com/r/a16bitsysop/rspamd/)
[![Docker Image Version (tag latest semver)](https://img.shields.io/docker/v/a16bitsysop/rspamd/latest?style=plastic)](https://hub.docker.com/r/a16bitsysop/rspamd/)
[![Github SHA](https://img.shields.io/badge/dynamic/json?style=plastic&color=orange&label=Github%20SHA&query=object.sha&url=https%3A%2F%2Fapi.github.com%2Frepos%2Fa16bitsysop%2Fdocker-rspamd%2Fgit%2Frefs%2Fheads%2Fmain)](https://github.com/a16bitsysop/docker-rspamd)
[![GitHub Super-Linter](https://github.com/a16bitsysop/docker-rspamd/workflows/Super-Linter/badge.svg)](https://github.com/marketplace/actions/super-linter)

It has several map files which can be edited in the web UI, including filename for extensions to reject and whitelist for domains to whitelist.  The maps are stored in /etc/rspamd/local.d/maps.d , they are also copied from maps.orig to maps.d if not present during startup for a container with mounted volumes or new maps in a newer image.

To generate a password hash for the web interface run container then run rspamd_pw.sh and copy output into /etc/rspamd/override.d/worker-controller.inc.  Or exec rspamadm pw inside container and use result for password and enable_password.

This is then retained in the persistent volume if mounted.

It is configured to read the dkim/arc keys from redis, to manually add a key to redis instructions are on the Rspamd website [https://rspamd.com/doc/modules/dkim_signing.html#dkim-keys-in-redis](https://rspamd.com/doc/modules/dkim_signing.html#dkim-keys-in-redis).

To change the configuration add changes to the /etc/rspamd/override.d directory, and mount it with a volume.

The Neural module, and alot of changes from default are configured for low email volume.

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

Spamassassin rules from heinlein-support.de are loaded every HLSLEEP hours if set. They include
regularly updated spamassassin filter rules, mainly for German spam.
If the rules changed after the update, rspamd is restarted automatically via SIGHUP.
See [here](https://www.heinlein-support.de/blog/news/aktuelle-spamassassin-regeln-von-heinlein-support/) for a
more detailed description in German.

The [url_redirector](https://rspamd.com/doc/modules/url_redirector.html) module
is configured to read domain names from local.d/maps.d/redirectors.inc
This can be copied from the main rspamd config into local.d/maps.d if SYSREDIR
is set, it will not overrite redirectors.inc if it is already in local.d/maps.d

If the STUNNEL environment variable is set then stunnel will be started to pass
redis commands over a ssl/tls tunnel.  There needs to be a stunnel server at the
other end to receive the connection, it is different from redis native ssl support.
There should also be a file /etc/stunnel/psk.txt with the pre shared key, see
[here](https://www.stunnel.org/auth.html).

## Github
Github Repository: [https://github.com/a16bitsysop/docker-rspamd](https://github.com/a16bitsysop/docker-rspamd)

## Environment Variables

| NAME      | Description                                              | Default            |
| --------- | -------------------------------------------------------- | ------------------ |
| REDIS     | name/container name or IP of the redis server.           | none (No redis)    |
| OLEFY     | name/container name or IP of the Olefy server.           | do not use Olefy   |
| RAZORFY   | name/container name or IP of the Razorfy server.         | do not use Razorfy |
| DCCIFD    | name/container name or IP of the DCCIFD server.          | do not use dccifd  |
| CLAMAV    | name/container name or IP of the ClamAV server.          | do not use ClamAV  |
| CONTROLIP | name/container name or IP of rspamc process.             | none               |
| DNSSEC    | enable dnssec for dns lookups.                           | no dnssec          |
| NOGREY    | disable greylisting (soft reject).                       | greylist           |
| BZSLEEP   | hours between updates of abuse.ch hashes eg 1.5          | unset / disabled   |
| HLSLEEP   | hours between updates of heinleins spamassassin rules    | unset / disabled   |
| SYSREDIR  | copy rsypamd redirectors.inc for url_redirector to use   | unset / don't copy |
| STUNNEL   | Use stunnel to encrypt redis traffic on port 6379 if set | unset              |
| TIMEZONE  | timezone to use inside the container, eg Europe/London   | unset              |

## Examples
To run connecting to container network without exposing ports (accessible from host network), and docker managed volumes
```bash
#docker container run --net MYNET --name rspamd --restart=unless-stopped --mount source=rspamd-var,target=/var/lib/rspamd --mount source=rspamd-over,target=/etc/rspamd/override.d -d a16bitsysop/rspamd
```

To run without connecting to container network exposing ports (accessible from host network), and docker managed volumes
```bash
#docker container run -p 11332:11332 -p 11334:11334 --name rspamd --restart=unless-stopped --mount source=rspamd-var,target=/var/lib/rspamd --mount source=rspamd-over,target=/etc/rspamd/override.d -d a16bitsysop/rspamd
```

### Sources
Based on configuration [here](https://thomas-leister.de/en/mailserver-debian-stretch/)

The rspamd [user mailing list](https://lists.rspamd.com/mailman/listinfo)
