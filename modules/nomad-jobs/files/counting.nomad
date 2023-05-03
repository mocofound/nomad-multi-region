#https://www.nomadproject.io/docs/integrations/consul-connect
job "counting-dashboard-backend" {
  #datacenters = ["dc1"]
  region="global"
  datacenters = ["us-west-2","us-east-2"]

  group "api" {
    network {
      mode = "bridge"
    }

    service {
      name = "count-api"
      port = "9001"
      #token = "8f966e72-d76a-2f4d-5b97-e7c99ced128d"

      connect {
        sidecar_service {}
        sidecar_task {
                resources {
                    #cpu = 500
                    #memory = 1024
                }

                env {
                CONSUL_HTTP_TOKEN = "8f966e72-d76a-2f4d-5b97-e7c99ced128d"
                }

                shutdown_delay = "5s"
            }
      }
    }

    task "web" {
      driver = "docker"
      
      env {
            CONSUL_HTTP_TOKEN = "8f966e72-d76a-2f4d-5b97-e7c99ced128d"
        }

      config {
        image = "hashicorpdev/counter-api:v3"
      }
    }
  }
}
