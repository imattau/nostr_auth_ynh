#!/bin/bash
# Injects (or, without --force, re-injects only if missing) a small inline
# script into YunoHost's shared portal index.html that adds a "Sign in
# with Nostr" link below the login form - but only when the visiting
# browser's hostname matches __DOMAIN__ (this app's own installed domain).
# The index.html itself is shared across every domain on the server (one
# yunohost-portal install, not one per domain), so the hostname check is
# what actually keeps this scoped to just this app's domain rather than
# every login page on the box.
#
# Run with --force (install/upgrade/restore) to always re-inject the
# current version of the snippet, replacing any old one - e.g. after this
# package itself changes what gets injected. Run with no arguments (the
# cron job in ../conf/cron does this every 30 minutes) to only act if the
# marker is missing - which happens when a `yunohost`/`yunohost-portal`
# package upgrade has overwritten index.html with the pristine, unpatched
# file. There is no core hook for "after a system package upgrade" apps
# could register into instead (checked against yunohost's own
# tools_upgrade() - it calls no hook_callback for this), so periodic
# self-healing is the least-bad option here.
set -euo pipefail

PORTAL_INDEX="/usr/share/yunohost/portal/index.html"
DOMAIN="__DOMAIN__"
BEGIN_MARKER="<!-- nostr_auth:begin -->"

FORCE=0
[ "${1:-}" = "--force" ] && FORCE=1

# The portal package may not be installed at all (unlikely on YunoHost 12,
# but this must never be what breaks install/upgrade/restore of this app).
[ -f "$PORTAL_INDEX" ] || exit 0

if [ "$FORCE" -eq 0 ] && grep -qF "$BEGIN_MARKER" "$PORTAL_INDEX"; then
	exit 0
fi

python3 - "$PORTAL_INDEX" "$DOMAIN" <<'PYEOF'
import re
import sys

BEGIN = "<!-- nostr_auth:begin -->"
END = "<!-- nostr_auth:end -->"

path, target_domain = sys.argv[1], sys.argv[2]
html = open(path, encoding="utf-8").read()

# Idempotent: strip any previous injection (ours or a stale one from an
# older version of this package) before adding the current one.
html = re.sub(re.escape(BEGIN) + r".*?" + re.escape(END) + r"\n?", "", html, flags=re.DOTALL)

snippet = f"""{BEGIN}
<script>
(function () {{
  "use strict";
  var TARGET_HOSTNAME = {target_domain!r};
  var LOGIN_LINK_ID = "nostr-auth-portal-link";
  if (window.location.hostname !== TARGET_HOSTNAME) return;
  function injectIfNeeded() {{
    if (document.getElementById(LOGIN_LINK_ID)) return;
    var passwordField = document.querySelector('input[type="password"]');
    if (!passwordField) return;
    var form = passwordField.closest("form");
    if (!form) return;
    var link = document.createElement("a");
    link.id = LOGIN_LINK_ID;
    link.href = "/nostr-login";
    link.textContent = "Sign in with Nostr";
    link.style.cssText = "display:block;text-align:center;margin-top:16px;padding:10px;border-radius:8px;border:1px solid currentColor;text-decoration:none;font-weight:600;opacity:0.85;";
    form.insertAdjacentElement("afterend", link);
  }}
  new MutationObserver(injectIfNeeded).observe(document.body, {{childList: true, subtree: true}});
  injectIfNeeded();
}})();
</script>
{END}
"""

if "</body>" not in html:
    print("no </body> tag found in portal index.html - refusing to patch", file=sys.stderr)
    sys.exit(1)

open(path, "w", encoding="utf-8").write(html.replace("</body>", snippet + "</body>", 1))
PYEOF
