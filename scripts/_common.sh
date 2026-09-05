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
nostr_auth_install_venv() {
	python3 -m venv "$install_dir/venv"
	ynh_hide_warnings "$install_dir/venv/bin/pip" install --upgrade pip
	ynh_hide_warnings "$install_dir/venv/bin/pip" install "$install_dir"
}
