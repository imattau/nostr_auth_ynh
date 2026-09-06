# Administration

## Linking your first identity

1. Log in to YunoHost normally with your password.
2. Visit `https://<domain>/nostr-account` and click **Link identity**
   (requires a NIP-07 browser extension, e.g. Alby or nos2x), or use one
   of the alternatives below - see the core repo's PLAN.md Phase 5/11 for
   how this is verified.
3. Visit `https://<domain>/nostr-login` afterwards to sign in with Nostr.

### Don't have a Nostr identity yet?

Expand **Don't have a Nostr identity? Generate one** on `/nostr-account`
to create a key pair directly in your browser. Copy the `nsec` into a real
Nostr extension or signer app before relying on it for anything beyond
quick testing; check "Remember this key in this browser" only if you
understand it will then be stored unencrypted in this browser's storage.

### Remote signers (NIP-46)

Expand **Use a remote signer instead (NIP-46)** to paste a `bunker://`
link or scan a `nostrconnect://` QR code from a signer app (e.g. Amber,
nsec.app) instead of using a browser extension.

### Passkeys

Expand **Use a passkey on this device** to create or unlock a passkey-backed
Nostr identity. Where the browser supports WebAuthn PRF, the private key is
encrypted locally and unlocked only after biometric or security-key
verification; it is never sent to the server. A generated key can be imported
into the passkey vault, and an offline recovery `nsec` can be exported and
restored on another device. Treat that recovery key like a password: anyone
who has it can control the Nostr identity.

## Managing saved signers

`/nostr-account` shows a **Saved on this device** panel listing whichever
NIP-46 bunker session, locally-generated key, and/or passkey identity this
browser currently has stored, each with its own **Forget** button - use it to
clear a saved signer without unlinking the identity itself. Unlinking clears
the NIP-46/local-key conveniences; passkey storage can be forgotten separately.

## Using your identity outside YunoHost (NIP-05)

Once linked, your identity is exposed as a standard NIP-05 identifier at
`<username>@<domain>` (resolvable at
`https://<domain>/.well-known/nostr.json?name=<username>`), so any Nostr
client - or another app - can verify it. This is opt-in by virtue of
having linked an identity at all, and only ever resolves one exact
username at a time; it never lists every linked user.

## Brute-force protection

Failed login/link/unlink attempts are logged (with the requesting IP) to
`/var/log/nostr_auth/nostr_auth.log`, watched by a fail2ban jail installed
alongside the app - repeated failures from the same IP get banned the
same way YunoHost's own portal login does.

## Runtime policy switches

The Config tab's **Authentication policy** panel can independently pause
Nostr login or self-service identity linking. Disabling either switch keeps
the existing SQLite mappings intact. Password login remains available, and
administrators can still use the CLI/config panel to provision, rename,
revoke, or unlink identities. Re-enabling a switch restarts the service and
makes the corresponding flow available again.

The same panel also tunes challenge timing: challenge lifetime can be set from
30 to 120 seconds, and timestamp clock-skew tolerance from 0 to 300 seconds.
Keep both values low unless remote signers or poorly synchronized client
clocks require extra time.

## Recovery

If you lose access to your linked Nostr key, password login still works:
log in with your password, visit `/nostr-account`, and click **Replace
identity** (or **Unlink**, then link a new one later).

## Admin dashboard

Administrators get a second tile on their YunoHost portal - **Nostr
Identities (Admin)** - pointing straight at `https://<domain>/nostr-admin`:
a dedicated dashboard listing every linked identity across every account,
searchable/filterable, with link/rename/revoke/unlink actions. It's a
faster alternative to the config-panel's numeric-ID form below for anyone
managing more than a couple of identities. This tile and its `/nostr-admin`
path are restricted to the `admins` group at the SSOwat level (a real,
separate permission from the app's main `visitors` one), and the app
double-checks the same group membership itself for every request, so
visiting the URL directly is equally protected for anyone not already a
server administrator.

## Admin-provisioned linking (no live signature required)

The webadmin's app page for nostr_auth has a **Config** tab with a
**Nostr identities** panel: replace, add, rename, revoke, or unlink identities
for any YunoHost account by pubkey/identity ID directly, and see everything
currently linked. Unlike the self-service
`/nostr-account` flow, this does **not** require a live signature proving
the linker controls the key - reaching this panel at all already means
administering the server, so use it when the account holder can't do the
signing themselves (most concretely: giving an agent/bot its own YunoHost
account using an npub it reports itself, with no browser in the loop).
Create the account normally first (`yunohost user create`, or the
webadmin's Users page) and link its npub here afterwards.

The same actions are reachable from the CLI/API:

```bash
yunohost app action run nostr_auth identities.link.do_link \
    --args="link_username=agentuser&link_npub=npub1...&link_signer_type=passkey&link_label=Agent%20passkey"
yunohost app action run nostr_auth identities.add.do_add \
    --args="add_username=agentuser&add_npub=npub1...&add_signer_type=nip46&add_label=Phone%20bunker"
yunohost app action run nostr_auth identities.rename.do_rename \
    --args="rename_username=agentuser&rename_identity_id=12&rename_label=Main%20laptop"
yunohost app action run nostr_auth identities.revoke.do_revoke \
    --args="revoke_username=agentuser&revoke_identity_id=12"
yunohost app action run nostr_auth identities.unlink.do_unlink \
    --args="unlink_username=agentuser"
```

`identities.link.do_link` keeps its historical replace behavior: it removes
the account's previous identities before linking the supplied one. Use
`identities.add.do_add` when the account should retain existing devices.

See the core repo's PLAN.md Phase 5/14 and `docs/mcp-integration.md` for
how this relates to (and stays deliberately separate from) a service like
yunohost-mcp's own pubkey→role/scope model, for agents that only need API
access and no real YunoHost account at all.
