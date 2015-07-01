# deploy
Deploying apps, sometimes not the FreeBSD Ports way... WARNING: this might be dumb

# Example

## Planning

### FQDN and WEBIPALIAS that would be reachable if this service is to be public
- virtual.local
- 192.168.255.200

### SQUIDIPALIAS, IP to use as alias for transparent ssl proxy
- 192.168.255.201

## Host (alpha.local 192.168.255.120)

Pulls from github.com and gitlab.com. May be slow.

```
fres ; fres -b
rm /var/ports/packages/All/squid-3.5.5.txz
fzg -r mirror -d ada0 -d ada1 -d ada2 -z 2g -m -n -D -H `hostname-by-etc-hosts`
copy-network-conf-to-mnt
reboot

## Optional
mkdir -p /root/local/gitcache/johnko
mkdir -p /root/local/gitcache/gitlab-org
mkdir -p /root/local/gitcache/qq99
git clone https://github.com/johnko/dtfc.git /root/local/gitcache/johnko/dtfc
git clone https://github.com/qq99/echoplexus.git /root/local/gitcache/qq99/echoplexus
git clone https://gitlab.com/gitlab-org/gitlab-ce.git -b 7-8-stable /root/local/gitcache/gitlab-org/gitlab-ce.git

pg pkg || fres
env FQDN=virtual.local SQUID=10.7.7.1:3128 SQUIDIPALIAS=192.168.255.201 WEBIPALIAS=192.168.255.202 XMPPIPALIAS=192.168.255.203 MURMURIPALIAS=192.168.255.204 MONITIPALIAS=192.168.255.205 ZABBIXIPALIAS=192.168.255.206 MINIDLNAIPALIAS=192.168.255.207 FIREFLYIPALIAS=192.168.255.208 deploy as_jails good
rsync -viaP --exclude work /usr/jails/squid/var/ports /var/ports/

## Optional
# vi /etc/rc.conf.d/ucarp*
```

Setup a valid FQDN SSL certficate and key (in this example: `virtual.local`) in `/usr/jails/nginx/usr/local/etc/nginx/ssl/ssl{.crt,.key}`

You may need to make a bundle:

```
cat server.crt intermediate.pem root.pem > /usr/jails/nginx/usr/local/etc/nginx/ssl/ssl.crt
```

Then start jails:

```
eza stop ; eza start
```

### Dynamic DNS with EasyDNS

Maybe setup scheduled dynamic easydns as user urep:

```
eza console squid
su -l urep
crontabbed
echo >crontabbed/zsnapple_bootpool_hourly
echo >crontabbed/zsnapple_pool_hourly
echo "0 * * * * /usr/home/urep/bin/easydns-client username password fqdn" >crontabbed/easydns_hourly
crontabbed
crontab -l
```

### CouchDB

You may want to visit https://virtual.local/couch/_utils/ and set it up.

### owncloud

You may want to visit https://virtual.local/owncloud/ and set it up.

Then https://virtual.local/owncloud/index.php/settings/apps and under Productivity enable:

- RainLoop Webmail / Mail
- Calendar
- Contacts
- Documents
- Bookmarks
- Search Lucene

Then https://virtual.local/owncloud/index.php/settings/admin and set the Email Server.

### GitLab

You may want to visit https://virtual.local/admin/application_settings and turn off:

- Sign Up
- Gravatar
- Twitter

Visit https://virtual.local/profile/account and get your `Private token`

Then start importing:

```
env TOKEN=... FQDN=virtual.local git/deploy/scripts/gitlab_import
```

## Host (sega.local 192.168.255.160)

Pulls from alpha.local. Fast for local network.

```
env SQUID=192.168.255.201:3128 setproxy
env REPOSRC=https://virtual.local/v. fres
env REPOSRC=https://virtual.local/v. fres -b
fzg -d ada0 -d ada2 -z 2g -m -n -D -H `hostname-by-etc-hosts`
copy-network-conf-to-mnt
reboot

env SQUID=192.168.255.201:3128 setproxy
pg pkg || env REPOSRC=https://virtual.local/v. fres
rsync -viaP --exclude work alpha:/var/ports /var/ports/
env FQDN=virtual.local SQUID=192.168.255.201:3128 REPOSRC=https://virtual.local/v. GITLABSRC=https://virtual.local/v. SQUIDIPALIAS=192.168.255.201 WEBIPALIAS=192.168.255.202 XMPPIPALIAS=192.168.255.203 MURMURIPALIAS=192.168.255.204 MONITIPALIAS=192.168.255.205 ZABBIXIPALIAS=192.168.255.206 MINIDLNAIPALIAS=192.168.255.207 FIREFLYIPALIAS=192.168.255.208  deploy as_jails good

## Optional
# vi /etc/rc.conf.d/ucarp*
```

## Notes

Outbound email is not enabled yet.

If running multiple PostgreSQL jails, they each need to have different UIDs in order to not crash each other.
