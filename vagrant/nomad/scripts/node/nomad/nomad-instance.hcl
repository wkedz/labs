# Full configuration options can be found at https://www.nomadproject.io/docs/configuration
datacenter = "dc1"
data_dir   = "/opt/nomad/data"
bind_addr  = "192.168.100.111" 

server {
  enabled          = true
  bootstrap_expect = 3
  server_join {
    retry_join = [ "192.168.100.112", "192.168.100.113" ]
    retry_max = 3
    retry_interval = "15s"
  }

}

client {
  enabled = true
  servers = ["127.0.0.1:4646"]

  network_interface = "enp0s8"

  host_volume "grafana" {
    path = "/opt/nomad-volumes/grafana"
  }

  host_volume "databases" {
    path = "/opt/nomad-volumes/databases"
    read_only = false
  }

}

consul {
  address = "192.168.100.111:8500"
}

plugin "docker" {
  config {
    volumes {
      enabled = true
    }

    gc {
      image = false
      
    }
    allow_caps = [
      "CHOWN", "DAC_OVERRIDE", "FSETID", "FOWNER", "MKNOD",
      "SETGID", "SETUID", "SETFCAP", "SETPCAP", "NET_BIND_SERVICE",
      "SYS_CHROOT", "KILL", "AUDIT_WRITE", "NET_RAW",
    ]
  }
}

telemetry {
  publish_allocation_metrics = true
  publish_node_metrics       = true
  prometheus_metrics         = true
}

