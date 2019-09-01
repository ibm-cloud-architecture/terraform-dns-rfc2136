# terraform-dns-rfc2136

Terraform Module that creates a bunch of DNS records using dynamic DNS updates.  This module can be combined with other infrastructure modules as part of a stack, for example, to install Openshift, which requires each node to have A records, PTR records, as well as CNAME records, SRV records, etc.

Here is example usage from our [openshift installation](https://github.com/ibm-cloud-architecture/terraform-openshift4-vmware-example):

```terraform
module "dns" {
    source                  = "github.com/ibm-cloud-architecture/terraform-dns-rfc2136"

    zone_name               = "example.com."
    dns_server              = "<dns server ip>"

    key_name = "rndc-key."
    key_algorithm = "hmac-md5"
    key_secret = "<my secret>"
    record_ttl = 300

    node_count = 3
    node_ips = ["<ip1>", "<ip2>", "<ip3>"]
    node_hostnames = ["<hostname1>", "<hostname2>", "<hostname3>"]

    # set this to true if you also want to generate PTR records for each node and you have a reverse domain set up in the DNS server
    create_node_ptr_records = true

    a_record_count = 1
    a_records = {
        "<additionat a record>" = "<ip4>"
    }

    srv_record_count = 1
    srv_records = [ "<srv_record>" ]
    srv_record_targets = {
        "<ip1>:<port>" = "<srv_record>",
        "<ip2>:<port>" = "<srv_record>"
        "<ip3>:<port>" = "<srv_record>"
    }

    cname_record_count = 1
    cname_records = {
        "<my_alias>" = "<my_cname>"
    }
    
}
```