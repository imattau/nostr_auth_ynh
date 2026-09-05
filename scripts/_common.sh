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
