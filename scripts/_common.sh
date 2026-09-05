#!/bin/bash
#=================================================
# PACKAGE-SPECIFIC HELPERS
#=================================================

# Create the app's Python virtual environment and install
# yunohost-nostr-auth into it from the unpacked source tree in
# $install_dir. Runs as root during install/upgrade; the resulting venv is
# then used by both systemd services (this app's own, and
# nostr_auth-mint-session, both running as different unprivileged users -
# neither needs root, see conf/systemd.service and
# conf/nostr_auth-mint-session.service).
#
# --system-site-packages: ldap_lookup.py (used only by
# nostr_auth-mint-session.service, which runs as ynh-portal) imports
# `ldap` from Debian's python3-ldap apt package, not from PyPI (avoids
# needing to compile python-ldap against libldap/libsasl headers) -
# matching how YunoHost's own moulinette dependencies are reached rather
# than duplicated.
nostr_auth_install_venv() {
	python3 -m venv --system-site-packages "$install_dir/venv"
	ynh_hide_warnings "$install_dir/venv/bin/pip" install --upgrade pip
	ynh_hide_warnings "$install_dir/venv/bin/pip" install "$install_dir"
}

# Installs the reapply-portal-patch.sh helper and its cron job (PLAN.md
# Phase 9), then runs the helper once with --force so the currently
# packaged version of the injected snippet takes effect immediately rather
# than waiting for the next cron tick. Safe to call on install, upgrade,
# and restore - it's idempotent (see reapply-portal-patch.sh itself).
nostr_auth_install_portal_patch() {
	ynh_config_add --template="reapply-portal-patch.sh" --destination="$install_dir/reapply-portal-patch.sh"
	chown root:root "$install_dir/reapply-portal-patch.sh"
	chmod 700 "$install_dir/reapply-portal-patch.sh"

	ynh_config_add --template="cron" --destination="/etc/cron.d/$app"
	chown root:root "/etc/cron.d/$app"
	chmod 644 "/etc/cron.d/$app"

	"$install_dir/reapply-portal-patch.sh" --force \
		|| ynh_print_warn "Could not inject the Nostr login button into the YunoHost portal - password login is unaffected, but /nostr-login won't be linked from it. This will retry automatically (see conf/cron)."
}

# Strips this app's injection back out of the shared portal index.html and
# removes the cron job - called on remove, since this is one of the few
# things this package does that isn't confined to its own install_dir.
nostr_auth_remove_portal_patch() {
	ynh_safe_rm "/etc/cron.d/$app"

	local portal_index="/usr/share/yunohost/portal/index.html"
	[ -f "$portal_index" ] || return 0

	python3 - "$portal_index" <<'PYEOF'
import re
import sys

BEGIN = "<!-- nostr_auth:begin -->"
END = "<!-- nostr_auth:end -->"

path = sys.argv[1]
html = open(path, encoding="utf-8").read()
new_html = re.sub(re.escape(BEGIN) + r".*?" + re.escape(END) + r"\n?", "", html, flags=re.DOTALL)
if new_html != html:
    open(path, "w", encoding="utf-8").write(new_html)
PYEOF
}
