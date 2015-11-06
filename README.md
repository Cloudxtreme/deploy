# deploy
Deploying apps, sometimes not the FreeBSD Ports way... WARNING: this might be dumb

# Example

## Planning

### FQDN and IP that would be reachable if this service is to be public
- virtual.local
- 192.168.255.200

### IP to use as transparent ssl proxy
- 192.168.255.201

## Host (alpha.local 192.168.255.120)

### Install

```
## Optional
# env SQUID=192.168.255.201:3128 setproxy

fres
rm /var/ports/packages/All/squid-*.txz
fzg -r mirror -d ada0 -d ada1 -d ada2 -z 5g -n -H `hostname-by-ptr-dns`
fzg-copy-network-conf-to-mnt
reboot
```

### First run

```
## Optional
# env SQUID=192.168.255.201:3128 setproxy

pg pkg || fres
cp ~/perm/cshvars ~/local/cshvars
vi local/cshvars
source local/cshvars
```

### Create zpool tank

```
fzg-random-key
fzg -i -t 4 -p tank -r mirror -d ada0 -d ada1 -d ada2
fzg-unlock-on-boot
```

### pfsense on bhyve

```
tmux
sh -c "while [ 0 -eq 0 ] ; do deploy pfsense ; echo "Sleeping..." ; sleep 5 ; done"
```

Install the packages:
- OpenVPN Client Export Utility

### Jails

Pulls from github.com and gitlab.com.

```
sh ~/perm/deploy.a.good

## Optional
# vi /etc/rc.conf.d/ucarp*
```

Setup a valid FQDN SSL certficate and key (in this example: `virtual.local`) in `$( ioc-pathof nginx )/usr/local/etc/nginx/ssl/ssl{.crt,.key}`

You may need to make a bundle:

```
cat server.crt intermediate.pem root.pem > $( ioc-pathof nginx )/usr/local/etc/nginx/ssl/ssl.crt
```

Then start jails:

```
service iocage start
```

### Dynamic DNS with EasyDNS

Maybe setup scheduled dynamic easydns as user urep:

```
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

### Klaus

You may want to visit https://virtual.local/git/ :

You should add your ssh public key to `/usr/local/git/.ssh/authorized_keys2`

And create bare repos in the jail:

```
mkdir -p /usr/local/git/repos/repo_name
cd /usr/local/git/repos/repo_name
git init --bare
```

Then on a remote client you can set the git remotes to:

```
git remote add home ssh://git@virtual.local:23/usr/local/git/repos/repo_name
git push home master
```

### miniDLNA

```
deploy minidlna
```

Put files in /vault/data/...

## Host (sega.local 192.168.255.160)

### Install

```
env SQUID=192.168.255.201:3128 setproxy
setenv FQDN virtual.local
env REPOSRC=https://${FQDN}/git fres
fzg -d ada0 -d ada2 -z 5g -n -H `hostname-by-ptr-dns`
fzg-copy-network-conf-to-mnt
reboot
```

### First run

```
env SQUID=192.168.255.201:3128 setproxy
setenv FQDN virtual.local
pg pkg || env REPOSRC=https://${FQDN}/git fres
cp ~/perm/cshvars ~/local/cshvars
vi local/cshvars
source local/cshvars
```

### Create zpool tank

```
fzg-random-key
fzg -i -t 4 -p tank -r mirror -d ada0 -d ada1 -d ada2
fzg-unlock-on-boot
```

### Jails

Pulls from alpha.local.

```
rsync -viaP --exclude work alpha:/var/ports/ /var/ports/
sh ~/perm/deploy.a.good

## Optional
# vi /etc/rc.conf.d/ucarp*
```

## Notes

Outbound email is not enabled yet.

If running multiple PostgreSQL jails, they each need to have different UIDs in order to not crash each other.


## Updating squid

The files that should be edited are:

- skel/perm/cshvars
- rad/bin/rad_files_conf

## Updating ffmpeg

- skel/perm/cshvars
- rad/bin/rad_files_conf
