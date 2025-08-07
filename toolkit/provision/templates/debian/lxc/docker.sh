#!/usr/bin/env bash

set -e
set -o pipefail

if ! command -v docker &>/dev/null; then
	# Add Docker's official GPG key:
	apt-get update -y
	apt-get install -y ca-certificates curl
	install -m 0755 -d /etc/apt/keyrings
	curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
	chmod a+r /etc/apt/keyrings/docker.asc

	# Add the repository to Apt sources
	docker_source_list="/etc/apt/sources.list.d/docker.list"
	if [ ! -f "$docker_source_list" ]; then
		echo \
			"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
		$(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
			sudo tee "$docker_source_list" >/dev/null
	fi

	apt-get update -y
	apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

	# Enable log rotation
	cat >"/etc/docker/daemon.json" <<EOF
{
	"log-driver": "json-file",
	"log-opts": {
		"max-size": "10m",
		"max-file": "3"
	}
}
EOF
fi
