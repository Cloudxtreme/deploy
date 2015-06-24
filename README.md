# deploy
Deploying apps, sometimes not the FreeBSD Ports way... WARNING: this might be dumb

## Example

### Planning

#### FQDN and WEBIPALIAS that would be reachable if this service is to be public
- virtual.local
- 192.168.255.200

#### SQUIDIPALIAS, IP to use as alias for transparent ssl proxy
- 192.168.255.201

### Host (alpha.local 192.168.255.120)

Pulls from github.com and gitlab.com. May be slow.

```
fres ; fres -b
rm /var/ports/packages/All/squid-3.5.5.txz
fzg -r mirror -d ada0 -d ada1 -d ada2 -z 2g -m -n -D -H alpha.local
vi /mnt/etc/rc.conf.d/{network,routing} /mnt/boot/loader.conf.local
reboot

pg pkg || fres
ifconfig lagg0 alias 192.168.255.200/32
ifconfig lagg0 alias 192.168.255.201/32
gdf
env FQDN=virtual.local WEBIPALIAS=192.168.255.200 SQUIDIPALIAS=192.168.255.201 SQUID=10.7.7.1:3128 deploy as_jails good
rsync -viaP --exclude work /usr/jails/squid/var/ports /var/ports/
vi /etc/rc.conf.d/ucar{p,w}
service ucarp start
service ucarw start
```

Setup a valid FQDN SSL certficate and key (in this example: `virtual.local`) in `/usr/jails/nginx/usr/local/etc/nginx/ssl/ssl{.crt,.key}`

You may need to make a bundle:

```
cat server.crt intermediate.pem root.pem > /usr/jails/nginx/usr/local/etc/nginx/ssl/ssl.crt
```

Visit https://virtual.local/explore and setup a GitLab group for:
- alpha.johnko
- alpha.qq99
- alpha.gitlab-org

Then start importing:

```
https://github.com/johnko/apache-config-freebsd.git
https://github.com/johnko/btfc2.git
https://github.com/johnko/crontabbed.git
https://github.com/johnko/deploy.git
https://github.com/johnko/eza.git
https://github.com/johnko/freebsd-install-script.git
https://github.com/johnko/freebsd-pf-script.git
https://github.com/johnko/freebsd-sortconf.git
https://github.com/johnko/freebsd-system-info.git
https://github.com/johnko/github-backup.git
https://github.com/johnko/gtfc.git
https://github.com/johnko/hddid.git
https://github.com/johnko/mount_iso.git
https://github.com/johnko/netconn.git
https://github.com/johnko/nginx-config-sites-enabled.git
https://github.com/johnko/psnap.git
https://github.com/johnko/pwgen.git
https://github.com/johnko/randomword.git
https://github.com/johnko/setproxy.git
https://github.com/johnko/ssh-multi.git
https://github.com/johnko/ssh-tools.git
https://github.com/johnko/zsnapple.git
https://github.com/johnko/skel.git
https://github.com/johnko/dtfc.git
https://github.com/qq99/echoplexus.git
https://gitlab.com/gitlab-org/gitlab-ce.git
```

### Host (sega.local 192.168.255.160)

Pulls from alpha.local. Fast for local network.

```
env SQUID=192.168.255.201:3128 setproxy
env REPOSRC=https://virtual.local/alpha. fres
env REPOSRC=https://virtual.local/alpha. fres -b
fzg -d ada0 -d ada2 -z 2g -m -n -D -H sega.local
vi /mnt/etc/rc.conf.d/{network,routing} /mnt/boot/loader.conf.local
reboot

env SQUID=192.168.255.201:3128 setproxy
pg pkg || env REPOSRC=https://virtual.local/alpha. fres
env REPOSRC=https://virtual.local/alpha. fres -b
env FQDN=sega.local SQUID=192.168.255.201:3128 WEBIPALIAS=192.168.255.200 SQUIDIPALIAS=192.168.255.201 REPOSRC=https://virtual.local/alpha. GITLABSRC=https://virtual.local/alpha. deploy as_jails good
rsync -viaP --exclude work alpha:/var/ports /var/ports/

## Optional
# vi /etc/rc.conf.d/ucar{p,w}
# service ucarp start
# service ucarw start
```
