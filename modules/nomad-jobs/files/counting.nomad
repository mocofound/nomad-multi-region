#https://www.nomadproject.io/docs/integrations/consul-connect
job "counting-dashboard-backend" {
  datacenters = ["dc1"]
  region="global"
  datacenters = ["us-west-2","us-east-2"]

  group "api" {
    network {
      mode = "bridge"
    }

    service {
      name = "count-api"
      port = "9001"

      connect {
        sidecar_service {}
      }
    }

    task "web" {
      driver = "docker"

      config {
        image = "hashicorpdev/counter-api:v3"
      }
    }
  }
}
