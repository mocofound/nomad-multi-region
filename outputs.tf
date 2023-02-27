output "consul_bootstrap_token_secret" {
  value = module.nomad_cluster_region_1.consul_bootstrap_token_secret
}

output "region_1_consul_ui" {
  value = "http://${module.nomad_cluster_region_1.lb_address_consul_nomad}:8500"
}

output "region_1_nomad_ui" {
  value = "http://${module.nomad_cluster_region_1.lb_address_consul_nomad}:4646"
}

output "region_1_vpc_id" {
  value = "${module.nomad_cluster_region_1.vpc_id}"
}

output "region_2_vpc_id" {
  value = "${module.nomad_cluster_region_2.vpc_id}"
}
output "region_2_consul_ui" {
  value = "http://${module.nomad_cluster_region_2.lb_address_consul_nomad}:8500"
}

output "region_2_nomad_ui" {
  value = "http://${module.nomad_cluster_region_2.lb_address_consul_nomad}:4646"
}

output "region_1_server_ip" {
  value = "${module.nomad_cluster_region_1.lb_address_consul_nomad}"
}

output "region_2_server_ip" {
  value = "${module.nomad_cluster_region_2.lb_address_consul_nomad}"
}


