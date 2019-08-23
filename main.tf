provider "dns" {
  update {
    server = "${var.dns_server}"
    key_name = "${var.key_name}"
    key_algorithm = "${var.key_algorithm}"
    key_secret = "${var.key_secret}"
  }
}


resource "dns_a_record_set" "node_a_record" {
  count = "${length(var.node_ips)}"

  zone = "${var.zone_name}"
  name = "${element(var.node_hostnames, count.index)}"

  addresses = ["${element(var.node_ips, count.index)}"]
  ttl = "${var.record_ttl}"
}

resource "dns_ptr_record" "node_ptr_record" {
  count = "${var.create_node_ptr_records ? length(var.node_ips) : 0}"

  zone = "${format("%s.in-addr.arpa.", join(".", reverse(slice(split(".", element(var.node_ips, count.index)), 0, 3))))}"
  name = "${element(split(".", element(var.node_ips, count.index)), 3)}"
  ptr = "${element(var.node_hostnames, count.index)}.${var.zone_name}"

  ttl = "${var.record_ttl}"
}

resource "dns_a_record_set" "other_a_record" {
  count = "${length(var.a_records)}"

  zone = "${var.zone_name}"
  name = "${element(keys(var.a_records), count.index)}"

  addresses = ["${element(values(var.a_records), count.index)}"]
  ttl = "${var.record_ttl}"
}

resource "dns_srv_record_set" "srv_records" {
  count = "${length(var.srv_records)}"

  zone = "${var.zone_name}"
  name = "${element(var.srv_records, count.index)}"

  dynamic "srv" {
    for_each = matchkeys(
      keys(var.srv_record_targets), 
      values(var.srv_record_targets), 
      list(element(var.srv_records, count.index)))

    content {
      priority = 0
      weight = 10
      target = "${format("%s.", element(split(":", srv.value), 0))}"
      port = "${element(split(":", srv.value), 1)}"
    }
  }
    

}