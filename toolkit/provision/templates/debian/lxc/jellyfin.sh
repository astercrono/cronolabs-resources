#!/usr/bin/env bash

set -e
set -o pipefail

apt-get update -y
apt-get install -y ffmpeg software-properties-common gnupg

if ! command -v jellyfin &>/dev/null; then
	curl -s https://repo.jellyfin.org/install-debuntu.sh | bash

	usermod -a -G video jellyfin
	usermod -a -G render jellyfin
	usermod -a -G input jellyfin
	usermod -a -G ssl-cert jellyfin

	apt install -y jellyfin-ffmpeg7

	systemctl restart jellyfin
	systemctl enable jellyfin
fi
