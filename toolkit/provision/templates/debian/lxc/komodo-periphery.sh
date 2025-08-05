#!/usr/bin/env bash

set -e
set -o pipefail

[ -d komodo-periphery ] && rm -r komodo-periphery

wget -P komodo-periphery https://raw.githubusercontent.com/moghtech/komodo/refs/heads/main/compose/periphery.compose.yaml

[[ "$?" != "0" ]] && echo "Failed to download compose file" && exit 1
[ ! -f komodo-periphery/periphery.compose.yaml ] && echo "Missing compose file" && exit 1

cd komodo-periphery

echo "** Applying KOMODO_PASSKEY"
yq -i ".services.periphery.environment.PERIPHERY_PASSKEYS = \"$APP_SEC_KOMODO_PASSKEY\"" periphery.compose.yaml

echo "** Enabling port mapping"
sed -i "s|    #   - 8120:8120|      - 8120:8120|" periphery.compose.yaml
sed -i "s|    # ports:|    ports:|" periphery.compose.yaml

cd ..

docker compose -p komodo-periphery -f komodo-periphery/periphery.compose.yaml up -d --force-recreate
