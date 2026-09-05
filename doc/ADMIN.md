# Administration

## Linking your first identity

1. Log in to YunoHost normally with your password.
2. Visit `https://<domain>/nostr-account` and click **Link identity**
   (requires a NIP-07 browser extension, e.g. Alby or nos2x), or use one
   of the alternatives below - see the core repo's PLAN.md Phase 5 for
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

## Managing saved signers

`/nostr-account` shows a **Saved on this device** panel listing whichever
NIP-46 bunker session and/or locally-generated key this browser currently
has stored, each with its own **Forget** button - use it to clear a saved
signer without unlinking the identity itself. Unlinking always clears
both.

## Using your identity outside YunoHost (NIP-05)

Once linked, your identity is exposed as a standard NIP-05 identifier at
`<username>@<domain>` (resolvable at
`https://<domain>/.well-known/nostr.json?name=<username>`), so any Nostr
client - or another app - can verify it. This is opt-in by virtue of
having linked an identity at all, and only ever resolves one exact
username at a time; it never lists every linked user.

## Recovery

If you lose access to your linked Nostr key, password login still works:
log in with your password, visit `/nostr-account`, and click **Replace
identity** (or **Unlink**, then link a new one later).

## CLI (planned)

```bash
yunohost nostr-auth status
yunohost nostr-auth users
yunohost nostr-auth show <username>
yunohost nostr-auth unlink <username>
```

Not yet implemented - see PLAN.md Phase 14 in the core repo.
