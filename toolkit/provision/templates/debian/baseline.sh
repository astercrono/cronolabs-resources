#!/usr/bin/env bash

set -e
set -o pipefail

install_yq() {
	if ! command -v yq &>/dev/null; then
		yq_version=$(curl -s "https://api.github.com/repos/mikefarah/yq/releases/latest" | grep -Po '"tag_name": "\K[^"]*')
		if [ -z "$yq_version" ]; then
			echo "Error: Could not determine the latest yq version."
			exit 1
		fi

		echo "Found latest yq version: ${yq_version}"

		install_path="/usr/local/bin/yq"
		download_url="https://github.com/mikefarah/yq/releases/download/${yq_version}/yq_linux_amd64"

		sudo curl -L "$download_url" -o "$install_path"
		sudo chmod +x "$install_path"
	fi
}

install_uv() {
	if command -v uv &>/dev/null; then
		uv self update
	else
		curl -LsSf https://astral.sh/uv/install.sh | sh
	fi
}

apt-get update -y
apt-get full-upgrade -y

backport_source_file="/etc/apt/sources.list.d/debian-backports.list"
if [ ! -f "$backport_source_file" ]; then
	touch "$backport_source_file"
	echo "deb http://deb.debian.org/debian bookworm-backports main contrib non-free" | tee -a "$backport_source_file"
fi

apt-get update -y
apt-get install -y cifs-utils cockpit curl less openssh-server openssl python3 sqlite3 tmux tree wget2 vim neovim gnupg htop btop

install_yq
install_uv
