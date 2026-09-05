# Administration

## Linking your first identity

1. Log in to YunoHost normally with your password.
2. Visit `https://<domain>/nostr-account` and click **Link identity**
   (requires a NIP-07 browser extension, e.g. Alby or nos2x) - see the
   core repo's PLAN.md Phase 5 for how this is verified.
3. Visit `https://<domain>/nostr-login` afterwards to sign in with Nostr.

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
