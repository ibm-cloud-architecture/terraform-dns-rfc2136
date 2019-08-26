# terraform-dns-rfc2136

Terraform Module that creates a bunch of DNS records using DDNS and RFC2136.  This module can be combined with other infrastructure modules as part of a stack, for example, to install Openshift, which requires each node to have A records, PTR records, SRV records, etc.

Here is example usage from our [openshift installation](https://github.com/ibm-cloud-architecture/terraform-openshift4-vmware-example):

```
module "dns" {
    source                  = "github.com/ibm-cloud-architecture/terraform-dns-rfc2136"

    node_ips = "${compact(concat(
        var.control_plane_ip_addresses,
        var.worker_ip_addresses,
    ))}"

    node_hostnames = "${compact(concat(
        data.template_file.control_plane_hostname_a.*.rendered,
        data.template_file.worker_hostname_a.*.rendered,
    ))}"

    a_records = "${zipmap(
      concat(
        list("api.${lower(var.name)}"),
        list("api-int.${lower(var.name)}"),
        list("*.apps.${lower(var.name)}"),
        data.template_file.etcd_hostname.*.rendered
      ),
      concat(
        list(module.control_plane_lb.node_ip),
        list(module.control_plane_lb.node_ip),
        list(module.app_lb.node_ip),
        var.control_plane_ip_addresses)
    )}"

    srv_records = "${list("_etcd-server-ssl._tcp.${lower(var.name)}")}"
    srv_record_targets = "${zipmap(
        data.template_file.etcd_srv_hostname.*.rendered, 
        data.template_file.etcd_srv_target.*.rendered)}"
    
    zone_name               = "${var.domain}."
    dns_server              = "${element(var.dns_servers, 0)}"
    create_node_ptr_records = true

    key_name = "${var.dns_key_name}"
    key_algorithm = "${var.dns_key_algorithm}"
    key_secret = "${var.dns_key_secret}"
    record_ttl = "${var.dns_record_ttl}" 
}
```