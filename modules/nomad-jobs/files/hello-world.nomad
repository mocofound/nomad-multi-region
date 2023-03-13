job "hello-world" {
  region = "global"
  datacenters = ["us-west-2","us-east-2"]

  group "app" {
    count = 1

    task "hello" {
      driver = "raw_exec"

      config {
        command = "/bin/sh"
        args    = ["-c", "echo Hello, World!"]
      }

      resources {
        cpu    = 100 # 100 MHz
        memory = 16  # 16 MB
      }
    }
  }
}