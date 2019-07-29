provider "dns" {
  update {
    server = "${var.dns_server}"
    key_name = "${var.key_name}"
    key_algorithm = "${var.key_algorithm}"
    key_secret = "${var.key_secret}"
  }
}

resource "dns_a_record_set" "a_record" {
  count = "${length(var.node_ips)}"

  zone = "${var.zone_name}"
  name = "${element(var.node_hostnames, count.index)}"

  addresses = ["${element(var.node_ips, count.index)}"]
  ttl = "${var.record_ttl}"
}