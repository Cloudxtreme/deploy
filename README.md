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

### Install

```
fres
rm /var/ports/packages/All/squid-*.txz
fzg -r mirror -d ada0 -d ada1 -d ada2 -z 2g -n -H `hostname-by-ptr-dns`
copy-network-conf-to-mnt
reboot
```

### Create zpool tank

```
fzg-random-key
fzg -i
fres
```

### pfsense on bhyve

```
tmux
sh -c "while [ 0 -eq 0 ] ; do deploy pfsense ; echo "Sleeping..." ; sleep 5 ; done"
```

Install the packages:
- OpenVPN Client Export Utility

### EZJails

Pulls from github.com and gitlab.com. May be slow.

```
pg pkg || fres
setenv FQDN virtual.local
cat ~/perm/deploy.a.good | sed "s;virtual.local;${FQDN};g" > ~/local/deploy.${FQDN}.good
cat ~/local/deploy.${FQDN}.good | sed 's;good;nginx;g' > ~/local/deploy.${FQDN}.nginx
sh ~/local/deploy.${FQDN}.good

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

### Piwik

You may want to visit https://virtual.local/piwik/ and set it up.

### owncloud

You may want to visit https://virtual.local/owncloud/ and set it up.

Then https://virtual.local/owncloud/index.php/settings/apps and under Productivity enable:

- RainLoop Webmail / Mail
- Calendar
- Contacts
- Documents
- Bookmarks

Then login to https://virtual.local/owncloud/index.php/apps/rainloop/app/?admin with admin and 12345 and change the admin password.

Then https://virtual.local/owncloud/index.php/settings/admin and set the outgoing Email Server.

### GitLab

You may want to visit https://virtual.local/admin/application_settings and turn off:

- Sign Up
- Gravatar
- Twitter

Visit https://virtual.local/profile/account and get your `Private token`

Then start importing:

```
env TOKEN=... FQDN=virtual.local sh git/deploy/scripts/git_clone
env TOKEN=... FQDN=virtual.local sh git/deploy/scripts/git_clone create
env TOKEN=... FQDN=virtual.local sh git/deploy/scripts/git_clone home
```

### miniDLNA

```
cat perm/pkglist | sed 's/^# //' > local/pkglist
fres
cat perm/pkglist | sed 's/^# //' | sed 's/^## //' > local/pkglist
fres
deploy minidlna
```

Put files in /tank/data/...

## Host (sega.local 192.168.255.160)

### Install

```
env SQUID=192.168.255.201:3128 setproxy
setenv FQDN virtual.local
env REPOSRC=https://${FQDN}/v. fres
fzg -d ada0 -d ada2 -z 2g -n -H `hostname-by-ptr-dns`
copy-network-conf-to-mnt
reboot
```

### Create zpool tank

```
fzg-random-key
fzg -i
setenv FQDN virtual.local
env REPOSRC=https://${FQDN}/v. fres
```

### EZJails

Pulls from alpha.local. Fast for local network.

```
env SQUID=192.168.255.201:3128 setproxy
setenv FQDN virtual.local
pg pkg || env REPOSRC=https://${FQDN}/v. fres
rsync -viaP --exclude work alpha:/var/ports/ /var/ports/
cat ~/perm/deploy.s.good | sed "s;virtual.local;${FQDN};g" > ~/local/deploy.${FQDN}.good
cat ~/local/deploy.${FQDN}.good | sed 's;good;nginx;g' > ~/local/deploy.${FQDN}.nginx
sh ~/local/deploy.${FQDN}.good

## Optional
# vi /etc/rc.conf.d/ucarp*
```

## Notes

Outbound email is not enabled yet.

If running multiple PostgreSQL jails, they each need to have different UIDs in order to not crash each other.


## Updating squid

The files that should be edited are:

- deploy/bin/deploy_squid
- rad/bin/rad_files_conf

## Updating ffmpeg

- deploy/bin/deploy_ffmpeg
- skel/fres
- rad/bin/rad_files_conf
