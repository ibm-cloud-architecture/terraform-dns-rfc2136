variable "node_ips" {
  type = "list"
  default = []
}

variable "node_hostnames" {
  type = "list"
  default = []
}

variable "dns_server" {}
variable "key_name" {}
variable "key_algorithm" {}
variable "key_secret" {}
variable "zone_name" {}
variable "record_ttl" {}

