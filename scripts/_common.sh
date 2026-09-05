#!/bin/bash
#=================================================
# PACKAGE-SPECIFIC HELPERS
#=================================================

# Create the app's Python virtual environment and install
# yunohost-nostr-auth into it from the unpacked source tree in
# $install_dir. Runs as root during install/upgrade; the resulting venv is
# then used by the systemd service running as $app (see
# conf/systemd.service - unlike yunohost-mcp, this service does not need
# root).
#
# --system-site-packages: ldap_lookup.py (used only by the mint-session
# helper, which runs as ynh-portal, not $app) imports `ldap` from Debian's
# python3-ldap apt package, not from PyPI (avoids needing to compile
# python-ldap against libldap/libsasl headers) - matching how YunoHost's
# own moulinette dependencies are reached rather than duplicated.
nostr_auth_install_venv() {
	python3 -m venv --system-site-packages "$install_dir/venv"
	ynh_hide_warnings "$install_dir/venv/bin/pip" install --upgrade pip
	ynh_hide_warnings "$install_dir/venv/bin/pip" install "$install_dir"
}

# Install the sudoers rule that lets $app invoke the mint-session helper
# as ynh-portal (see conf/sudoers and yunohost-nostr-auth's
# PHASE0_INVESTIGATION.md/ynh/permissions.py for why this privilege split
# exists at all). Deliberately not done via ynh_config_add: that helper
# sets 640/$app-owned permissions, but sudo refuses to honor a sudoers
# drop-in unless it's root:root 0440 - so this is applied and validated by
# hand instead.
nostr_auth_install_sudoers() {
	local sudoers_file="/etc/sudoers.d/$app"

	cp "$YNH_APP_BASEDIR/conf/sudoers" "$sudoers_file"
	sed --in-place \
		-e "s|__APP__|$app|g" \
		-e "s|__INSTALL_DIR__|$install_dir|g" \
		"$sudoers_file"
	chown root:root "$sudoers_file"
	chmod 0440 "$sudoers_file"

	visudo -cf "$sudoers_file" \
		|| ynh_die "Generated sudoers rule at $sudoers_file failed validation - refusing to leave a broken sudoers file in place"
}

nostr_auth_remove_sudoers() {
	ynh_safe_rm "/etc/sudoers.d/$app"
}
