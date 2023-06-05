# Notes

## Terraform tries to replace all variables within the templated script, so it fails

As a workaround, an extra dollar symbol ($) has been added to the variables that doesn't need to be replaced by terraform templating.

See [this](https://discuss.hashicorp.com/t/invalid-value-for-vars-parameter-vars-map-does-not-contain-key-issue/12074/4) and [this](https://github.com/hashicorp/terraform/issues/23384) for more information.

## The loopback interface for API LB cannot be up until K3s is fully installed in the extra control plane nodes

Otherwise they will try to join themselves... that's why there is a curl to the K3s API that waits for the first master to be up before trying to install K3s and also why the bird configuration happens after K3s is up and running in the other nodes.

## ServiceLB disabled

`--disable servicelb` is required for metallb to work
