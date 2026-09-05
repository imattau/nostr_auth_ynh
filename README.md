# nostr_auth_ynh

YunoHost packaging for [`yunohost-nostr-auth`](https://github.com/imattau/yunohost-nostr-auth):
lets an existing YunoHost user sign in with a linked Nostr identity (NIP-07
first), without replacing password login.

This repo is packaging only - install/remove/upgrade/backup/restore scripts,
Nginx and systemd config, and YunoHost permissions. The service itself and
its full architecture/roadmap live in the core repo, in `PLAN.md`.

## Status

Verified against a real YunoHost 12 test install: the login and account-
linking HTTP flow works end-to-end (real password login, our own
`/link/challenge` → sign → `/link`). Installs two systemd services (see
Layout below) - the split exists because minting a session needs the
`ynh-portal` system user's privileges, and a `sudo`-based helper doesn't
work on a containerized install (see the core repo's
`PHASE0_INVESTIGATION.md`, "Privilege-drop redesign"). `/authenticate`
against the current (socket-based) design is implemented and unit-tested
upstream but its live re-verification here was cut short by an unrelated
connection outage - see the core repo's open items.

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
