resource "null_resource" "generate_ansible_inventory" {
  provisioner "local-exec" {
    command = <<EOT
#!/bin/bash
cat > ./ansible/inventory.yml <<EOF
all:
  hosts:
%{for name, instance in module.ec2_public_instances}
    ${name}:
      ansible_host: ${instance.public_ip}
%{endfor}
  vars:
    ansible_user: ubuntu
    ansible_ssh_private_key_file: ./ec2-keys
EOF
EOT
  }

  depends_on = [module.ec2_public_instances]
}
