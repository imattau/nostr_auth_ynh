# nostr_auth_ynh

YunoHost packaging for [`yunohost-nostr-auth`](https://github.com/imattau/yunohost-nostr-auth):
lets an existing YunoHost user sign in with one or more linked Nostr
identities (NIP-07, NIP-46, or passkey), without replacing password login.
The admin Config panel can independently pause Nostr login or self-service
identity linking without deleting existing mappings.

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

Phase 9 (a "Sign in with Nostr" link on the *stock* YunoHost login page, not
just the standalone `/nostr-login`) is also implemented and verified live:
since the portal is a compiled Nuxt SPA with no supported JS extension
point (only a CSS one), this works by directly injecting a small inline
script into YunoHost's shared `index.html`, gated by hostname so it only
activates on this app's own installed domain even though the underlying
file is shared across every domain on the server. Confirmed on a real
install: the button appeared on the real login page for the app's own
domain (clicking it correctly reached `/nostr-login`, no console errors),
the main domain's login page was pixel-for-pixel unaffected, and removing
the app restored the shared `index.html` to be byte-for-byte identical to
its pre-patch original. A cron job self-heals the injection, since no core
hook fires after a `yunohost`/`yunohost-portal` package upgrade that would
let us reapply it the clean way. See `conf/reapply-portal-patch.sh` for the
full reasoning, and `nostr_auth_install_portal_patch`/
`nostr_auth_remove_portal_patch` in `scripts/_common.sh` for how it's
wired into install/upgrade/restore/remove.

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
    reapply-portal-patch.sh           # injects/self-heals the portal login-button (Phase 9)
    cron                              # runs the above every 30 minutes
doc/
    DESCRIPTION.md
    PRE_INSTALL.md
    ADMIN.md
```
