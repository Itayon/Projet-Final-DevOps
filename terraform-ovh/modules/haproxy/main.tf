data "external" "latest_image" {
  program = ["bash", "-c", <<-EOF
    latest_version=$(ls -t ~/infra-ovh/vm-images/haproxy-*/terraform-vars.json 2>/dev/null | head -n1)
    if [ -z "$latest_version" ]; then
      echo '{"image_name":"haproxy-1.0","server":"haproxy"}'
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

resource "openstack_compute_instance_v2" "haproxy" {
  name        = local.instance_name
  image_id    = data.openstack_images_image_v2.image.id
  flavor_name = local.flavor_name

  network {
    name = local.network_name
  }

  user_data = templatefile("${path.module}/scripts/configure-haproxy.sh", {
    backend_ips = var.backend_ips
  })
}

# Attendre que HAProxy soit prêt
resource "time_sleep" "wait_for_haproxy" {
  depends_on = [openstack_compute_instance_v2.haproxy]
  
  create_duration = "60s"
}

# Reconfigurer HAProxy après le déploiement
resource "null_resource" "reconfigure_haproxy" {
  depends_on = [time_sleep.wait_for_haproxy]

  triggers = {
    backend_ips = join(",", var.backend_ips)
    instance_id = openstack_compute_instance_v2.haproxy.id
  }

  connection {
    type        = "ssh"
    user        = "debian"
    private_key = file("~/.ssh/id_rsa")
    host        = openstack_compute_instance_v2.haproxy.access_ip_v4
    timeout     = "5m"
  }

  # Exécuter le script de reconfiguration déjà présent dans l'image
  provisioner "remote-exec" {
    inline = [
      "echo 'Déclenchement de la reconfiguration HAProxy...'",
      "sudo /usr/local/bin/reconfigure-haproxy.sh",
      "echo 'HAProxy reconfiguré avec succès'"
    ]
  }
}
