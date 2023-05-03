job "dashboard" {
  region="global"
  datacenters = ["us-west-2","us-east-2"]

    group "counting-dashboard-frontend" {
        network {
        mode = "bridge"

        port "http" {
            static = 9002
            to     = 9002
        }
        }

        service {
        name = "count-dashboard"
        port = "http"
        #token = "8f966e72-d76a-2f4d-5b97-e7c99ced128d"

        connect {
            sidecar_service {
            proxy {
                upstreams {
                destination_name = "count-api"
                local_bind_port  = 8080
                }
                
            }
            }
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

        task "dashboard" {
        driver = "docker"

        env {
            COUNTING_SERVICE_URL = "http://${NOMAD_UPSTREAM_ADDR_count_api}"
            DC      = "Running on datacenter ${node.datacenter}"
            VERSION = "Version ${NOMAD_META_VERSION}"
            CONSUL_HTTP_TOKEN = "8f966e72-d76a-2f4d-5b97-e7c99ced128d"
        }

        config {
            image = "hashicorpdev/counter-dashboard:v3"
        }
        }
    }
}