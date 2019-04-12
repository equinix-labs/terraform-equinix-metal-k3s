Anycast IP Demo on Packet K3s
===

The purpose of this project is to demonstrate multiple regions responding to your request from your distributed network of K3s clusters through the use of Packet's network automation tooling.  

To be used in conjunction with the [Packet K3s](https://github.com/packet-labs/packet-k3s) project; this application just returns the node IP and location serving the request to demonstrate the global distribution of the backing clusters' ability to serve traffic in a highly-available, distributed manner. 

In the K3s repository, a subnet is provisioned for use by Kubernetes services, which will be your Fission endpoint:

This deploys [Traefik](https://docs.traefik.io/user-guide/kubernetes/) as an edge ingress controller, and this application as a DaemonSet behind a Traefik-backed Ingress object, on K3s. 

Packet Anycast Application
==

Using Packet's Global IPv4, we can create highly-available anycast IP addresses, that we can use our K3s cluster controllers to back up (and thus, serve that region's traffic from). 

Please ensure [Local BGP is enabled in your Packet project](https://support.packet.com/kb/articles/global-anycast-ips), and make note of the project ID for use with [Packet K3s](github.com/packet-labs/packet-k3s).

Setup
==

Keep in mind that the Ingress requires a FQDN, please populate this (and update your local hosts file accordingly if this is not a resolvable domain), before applying. 

To complete this, in `example/deploy_demo/roles/demo/files/traefik.sh`, update the following line to reflect your FQDN:

```
  48   │ spec:
  49   │   rules:
  50   │   - host: your.host.name
```

Deploy
==

Run `create_inventory.sh` to generate a hosts inventory, and then in the `deploy_demo` Ansible directory, you can apply the apply:

```
sh create_inventory.sh
cd deploy_demo
ansible-playbook -i inventory.yaml main.yml
```

or manually copy `example/deploy_demo/roles/demo/files/traefik.sh` to your `kubectl` client machine and run manually to deploy Traefik and the application.


The `trafik.sh` script will deploy the application as a DaemonSet on your cluster, and expose this through an ingress on port 80, by default, so from there, you can access the application (and verify the distribution of requests through the Anycast IP) using:

```
curl -s http://${ANYCAST_IP} | jq .      
{
    "node_ip": "1.2.3.4",
    "node_location": "Los Angeles, California"
}
```

or using the controller IP to target a specific cluster to compare responses. 

With the Packet K3s cluster deployed, a Global Anycast IP address will use the K3s controller IP address as a backend for requests for the location nearest the client request. 


