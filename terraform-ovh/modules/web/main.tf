data "external" "latest_image" {
  program = ["bash", "-c", <<-EOF
    latest_version=$(ls -t ~/infra-ovh/vm-images/web-*/terraform-vars.json 2>/dev/null | head -n1)
    if [ -z "$latest_version" ]; then
      echo '{"image_name":"web-1.0"}'
    else
      cat "$latest_version"
    fi
  EOF
  ]
}

data "openstack_images_image_v2" "image" {
  name        = data.external.latest_image.result.image_name
  most_recent = true
}

resource "openstack_compute_instance_v2" "web" {
  name        = local.instance_name
  image_id    = data.openstack_images_image_v2.image.id
  flavor_name = local.flavor_name

  network {
    name = local.network_name
  }

  user_data = length(var.backend_ips) > 0 ? templatefile("${path.module}/scripts/configure-nginx.sh", {
    backend_ips = var.backend_ips
  }) : null
}

resource "null_resource" "reconfigure_nginx" {
  count      = length(var.backend_ips) > 0 ? 1 : 0
  depends_on = [openstack_compute_instance_v2.web]

  triggers = {
    backend_ips = join(",", var.backend_ips)
    instance_id = openstack_compute_instance_v2.web.id
  }

  connection {
    type        = "ssh"
    user        = "debian"
    private_key = file("~/.ssh/id_rsa")
    host        = openstack_compute_instance_v2.web.access_ip_v4
    timeout     = "5m"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Attente du démarrage de Nginx...'",
      "sleep 30",
      "echo '${join("\n", var.backend_ips)}' | sudo tee /tmp/backend-ips.txt",
      "sudo /usr/local/bin/reconfigure-nginx.sh",
      "echo 'Nginx reconfiguré avec ${length(var.backend_ips)} backends!'"
    ]
  }
}
