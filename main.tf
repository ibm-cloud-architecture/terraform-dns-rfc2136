provider "dns" {
  update {
    server = "${var.dns_server}"
    key_name = "${var.key_name}"
    key_algorithm = "${var.key_algorithm}"
    key_secret = "${var.key_secret}"
  }
}

resource "null_resource" "dependency" {
  triggers = {
    all_dependencies = "${join(",", var.dependson)}"
  }
}

resource "dns_a_record_set" "node_a_record" {
  count = "${var.node_count}"

  depends_on = [
    "null_resource.dependency"
  ]

  zone = "${var.zone_name}"
  
  # in case the caller passes fqdn, drop the zone name as we don't need it
  name = "${replace(element(var.node_hostnames, count.index), replace(".${var.zone_name}", "/\\.$/", ""), "")}"

  addresses = ["${element(var.node_ips, count.index)}"]
  ttl = "${var.record_ttl}"
}

resource "dns_ptr_record" "node_ptr_record" {
  count = "${var.create_node_ptr_records ? var.node_count : 0}"

  depends_on = [
    "null_resource.dependency"
  ]

  zone = "${format("%s.in-addr.arpa.", join(".", reverse(slice(split(".", element(var.node_ips, count.index)), 0, 3))))}"
  name = "${element(split(".", element(var.node_ips, count.index)), 3)}"
  ptr = "${element(var.node_hostnames, count.index)}.${var.zone_name}"

  ttl = "${var.record_ttl}"
}

resource "dns_a_record_set" "other_a_record" {
  count = "${var.a_record_count}"

  depends_on = [
    "null_resource.dependency"
  ]

  zone = "${var.zone_name}"
  name = "${replace(element(keys(var.a_records), count.index), replace(".${var.zone_name}", "/\\.$/", ""), "")}"

  addresses = ["${element(values(var.a_records), count.index)}"]
  ttl = "${var.record_ttl}"
}

resource "dns_srv_record_set" "srv_record" {
  count = "${var.srv_record_count}"

  depends_on = [
    "null_resource.dependency"
  ]

  zone = "${var.zone_name}"

  # in case the caller passes fqdn, drop the zone name as we don't need it
  name = "${replace(element(var.srv_records, count.index), replace(".${var.zone_name}", "/\\.$/", ""), "")}"

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

resource "dns_cname_record" "cname_record" {
  count = "${var.cname_record_count}"

  depends_on = [
    "null_resource.dependency"
  ]

  zone = "${var.zone_name}"

  # in case the caller passes fqdn, drop the zone name as we don't need it
  name = "${replace(element(keys(var.cname_records), count.index), replace(".${var.zone_name}", "/\\.$/", ""), "")}"

  # in case the cname passed in is not fully qualified (ends with dot), add a dot
  cname = "${replace(element(values(var.cname_records), count.index), "/([^.])$/", "$1.")}"
  ttl = "${var.record_ttl}"
}