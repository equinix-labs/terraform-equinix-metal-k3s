import json
import requests
import os

# This is only used for the "Clean Up" pipeline stage in Drone-- If your name is not Drone, please stop. 

PACKET_TOKEN = os.environ['PACKET_TOKEN']
KEY_TAG = os.environ['KEY_TAG']

response_keys = requests.get("https://api.packet.net/ssh-keys", headers={"X-Auth-Token":"%s" % (PACKET_TOKEN)}).text
keys = json.loads(response_keys)['ssh_keys']

for key in keys:
    if key['label'].startswith(KEY_TAG):
        print("Deleting %s" % key['id'])
        d = requests.delete("https://api.packet.net/ssh-keys/%s" % (key['id']), headers={"X-Auth-Token":"%s" % (PACKET_TOKEN)})
        print(d.text)
