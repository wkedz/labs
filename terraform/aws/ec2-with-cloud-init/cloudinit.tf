data "cloudinit_config" "cloudinit" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = file("scripts/init.cfg")
  }

  part {
    content_type = "text/x-shellscript"
    content = templatefile("scripts/volumes.sh", {
      DEVICE = var.device_name
    })
  }
}

