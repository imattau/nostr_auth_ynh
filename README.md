# nostr_auth_ynh

YunoHost packaging for [`yunohost-nostr-auth`](https://github.com/imattau/yunohost-nostr-auth):
lets an existing YunoHost user sign in with a linked Nostr identity (NIP-07
first), without replacing password login.

This repo is packaging only - install/remove/upgrade/backup/restore scripts,
Nginx and systemd config, and YunoHost permissions. The service itself and
its full architecture/roadmap live in the core repo, in `PLAN.md`.

## Status

Not yet installable. Waiting on the core service's Phase 1 findings (how
YunoHost 12 actually creates portal sessions) before the install script and
systemd unit can be finished - see the core repo's `PHASE0_INVESTIGATION.md`.

## Layout

```text
manifest.toml
scripts/
    install / remove / upgrade / backup / restore / change_url
conf/
    nginx.conf       # proxies /nostr-login to the localhost service
    systemd.service
doc/
    DESCRIPTION.md
    PRE_INSTALL.md
    ADMIN.md
```
