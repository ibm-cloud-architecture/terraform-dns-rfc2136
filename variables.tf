variable "node_count" {
  default = 0
}

variable "node_ips" {
  type = "list"
  default = []
}

variable "node_hostnames" {
  type = "list"
  default = []
}

variable "a_record_count" {
  default = 0
}

variable "a_records" {
  type = "map"
  default = {}
}

variable "cname_record_count" {
  default = 0
}

variable "cname_records" {
  type = "map"
  default = {}
}

variable "srv_record_count" {
  default = 0
}

variable "srv_records" {
  type = "list"
  default = []
}

variable "srv_record_targets" {
  type = "map"
  default = {}
}

variable "create_node_ptr_records" {
  default = false
}

variable "dns_server" {}
variable "key_name" {}
variable "key_algorithm" {}
variable "key_secret" {}
variable "zone_name" {
  description = "name of zone, must in in a period"
}

variable "record_ttl" {}

