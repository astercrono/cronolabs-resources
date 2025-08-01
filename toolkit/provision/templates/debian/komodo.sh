#!/usr/bin/env bash

set -e
set -o pipefail

[ -d komodo ] && rm -r komodo

wget -P komodo https://raw.githubusercontent.com/moghtech/komodo/main/compose/mongo.compose.yaml &&
	wget -P komodo https://raw.githubusercontent.com/moghtech/komodo/main/compose/compose.env

[ ! -f komodo/mongo.compose.yaml ] && echo "Missing compose file" && exit 1
[ ! -f komodo/compose.env ] && echo "Missing compose env file" && exit 1

cd komodo

echo "** Applying KOMODO_DB_USERNAME"
sed -i "s/^KOMODO_DB_USERNAME=.*/KOMODO_DB_USERNAME=$APP_SEC_KOMODO_DB_USERNAME/" compose.env

echo "** Applying KOMODO_DB_PASSWORD"
password=$(echo "$APP_SEC_KOMODO_DB_PASSWORD" | sed -e 's/[]\/$*.^[]/\\&/g')
sed -i "s/^KOMODO_DB_PASSWORD=.*/KOMODO_DB_PASSWORD=$password/" compose.env

echo "** Applying KOMODO_PASSKEY"
passkey=$(echo "$APP_SEC_KOMODO_PASSKEY" | sed -e 's/[]\/$*.^[]/\\&/g')
sed -i "s/^KOMODO_PASSKEY=.*/KOMODO_PASSKEY=$passkey/" compose.env

echo "** Applying TZ"
tz="America/New_York"
sed -i "s#^TZ=.*#TZ=$tz#" compose.env

echo "** Applying KOMODO_HOST"
host=$(echo "$APP_SEC_KOMODO_HOST" | sed -e 's/[]\/$*.^[]/\\&/g')
sed -i "s/^KOMODO_HOST=.*/KOMODO_HOST=$host/" compose.env

echo "** Applying KOMODO_WEBHOOK_SECRET"
webhook_secret=$(echo "$APP_SEC_KOMODO_WEBHOOK_SECRET" | sed -e 's/[]\/$*.^[]/\\&/g')
sed -i "s/^KOMODO_WEBHOOK_SECRET=.*/KOMODO_WEBHOOK_SECRET=$webhook_secret/" compose.env

echo "** Applying KOMODO_JWT_SECRET"
jwt_secret=$(echo "$APP_SEC_KOMODO_JWT_SECRET" | sed -e 's/[]\/$*.^[]/\\&/g')
sed -i "s/^KOMODO_JWT_SECRET=.*/KOMODO_JWT_SECRET=$jwt_secret/" compose.env

cd ..
docker compose -p komodo -f komodo/mongo.compose.yaml --env-file komodo/compose.env up -d --force-recreate
