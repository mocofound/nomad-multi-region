# output "lb_address_consul_nomad_1" {
#   value = module.nomad_cluster_region_1.lb_address_consul_nomad
# }



output "consul_bootstrap_token_secret" {
  value = module.nomad_cluster_region_1.consul_bootstrap_token_secret
}

# output "IP_Addresses_1" {
# value = module.nomad_cluster_region_1.IP_Addresses
# }

output "consul_ui_region_2" {
  value = "${module.nomad_cluster_region_2.lb_address_consul_nomad}:8500"
}

output "nomad_ui_region_2" {
  value = "${module.nomad_cluster_region_2.lb_address_consul_nomad}:4646"
}

output "consul_ui_region_1" {
  value = "${module.nomad_cluster_region_1.lb_address_consul_nomad}:8500"
}

output "nomad_ui_region_1" {
  value = "${module.nomad_cluster_region_1.lb_address_consul_nomad}:4646"
}

output "vpc_id_region_1" {
  value = "${module.nomad_cluster_region_1.vpc_id}"
}

output "vpc_id_region_2" {
  value = "${module.nomad_cluster_region_2.vpc_id}"
}
