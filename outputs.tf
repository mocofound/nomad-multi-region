output "consul_bootstrap_token_secret" {
  value = module.nomad_cluster_region_1[0].consul_bootstrap_token_secret
}

output "region_1_consul_ui" {
  value = "http://${module.nomad_cluster_region_1[0].lb_address_consul_nomad}:8500"
}

output "region_1_nomad_ui" {
  value = "http://${module.nomad_cluster_region_1[0].lb_address_consul_nomad}:4646"
}

output "region_1_vpc_id" {
  value = "${module.nomad_cluster_region_1[0].vpc_id}"
}

output "region_2_vpc_id" {
  value = "${module.nomad_cluster_region_2[0].vpc_id}"
}
output "region_2_consul_ui" {
  value = "http://${module.nomad_cluster_region_2[0].lb_address_consul_nomad}:8500"
}

output "region_2_nomad_ui" {
  value = "http://${module.nomad_cluster_region_2[0].lb_address_consul_nomad}:4646"
}

output "region_1_server_ip" {
  value = "${module.nomad_cluster_region_1[0].lb_address_consul_nomad}"
}

output "region_2_server_ip" {
  value = "${module.nomad_cluster_region_2[0].lb_address_consul_nomad}"
}

output "region_1_java_jar_nomad_job" {
  value = "http://${module.nomad_cluster_region_1[0].nlb_dns}:9292"
}

output "region_2_java_jar_nomad_job" {
  value = "http://${module.nomad_cluster_region_2[0].nlb_dns}:9292"
}

output "lb_dns_region_1" {
  value = "${module.route53.*.lb_dns_region_1}"
}

output "lb_dns_region_2" {
  value = "${module.route53.*.lb_dns_region_2}"
}