# nostr_auth_ynh

YunoHost packaging for [`yunohost-nostr-auth`](https://github.com/imattau/yunohost-nostr-auth):
lets an existing YunoHost user sign in with a linked Nostr identity (NIP-07
first), without replacing password login.

This repo is packaging only - install/remove/upgrade/backup/restore scripts,
Nginx and systemd config, and YunoHost permissions. The service itself and
its full architecture/roadmap live in the core repo, in `PLAN.md`.

## Status

Verified end-to-end against a real YunoHost 12 test install: real password
login → our `/link/challenge` → sign → `/link` → `200`, then `/challenge`
→ sign → `/authenticate` → `200` with a real, checked
`Set-Cookie: yunohost.portal=...`. Installs two systemd services (see
Layout below) - the split exists because minting a session needs the
`ynh-portal` system user's privileges, and a `sudo`-based helper doesn't
work on this install at all (see the core repo's `PHASE0_INVESTIGATION.md`,
"Privilege-drop redesign"). Getting here took four real, live-only bugs
(also in that doc) - a systemd `ProtectHome` interaction, a missing `Host`
header, the `sudo` dead end itself, and `install_dir`'s default
permissions blocking the `ynh-portal` service from even starting - each
fixed and re-verified live, not just reasoned about from source.

## Layout

```text
manifest.toml
scripts/
    install / remove / upgrade / backup / restore / change_url
conf/
    nginx.conf                        # proxies the app's API to the localhost service
    systemd.service                   # the main, unprivileged daemon ($app user)
    nostr_auth-mint-session.service   # the privileged session-minting helper (ynh-portal user) -
                                       # the main daemon talks to it over a Unix socket, never sudo
doc/
    DESCRIPTION.md
    PRE_INSTALL.md
    ADMIN.md
```
