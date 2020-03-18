#!/bin/ash
# This script is not used by Terraform; this is soley to assist in the testing pipeline.
/usr/bin/curl -s -H 'Content-Type: application/json' -H "X-Auth-Token: $PACKET_TOKEN" https://api.packet.net/ssh-keys -d "{\"label\":\"$KEY_NAME\", \"key\":\"$(cat drone-key-$KEY_NAME.pub)\"}" -X POST | jq .id 