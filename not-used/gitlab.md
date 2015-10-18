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
