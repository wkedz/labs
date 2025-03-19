datacenter = "dc1"
data_dir = "/opt/consul"

bind_addr = IP_BIND
client_addr = IP_CLIENT
advertise_addr = IP_ADVERTISE
#advertise_addr = "{{ GetInterfaceIP `enp0s8` }}"
 
bootstrap_expect = 3

server = true

retry_join = [
  IP_CONSUL_SERVERS
]

ui_config{
 enabled = true
}

connect {
  enabled = true
}

ports {
  grpc = 8502
}

telemetry {
  prometheus_retention_time = "480h"
  disable_hostname = true
}

# https://discuss.hashicorp.com/t/your-ip-is-issuing-too-many-concurrent-connections-please-rate-limit-your-calls/20711/2
limits {
  http_max_conns_per_client = 4000
}
