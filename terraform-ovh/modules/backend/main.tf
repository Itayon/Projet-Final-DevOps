data "external" "latest_image" {
  program = ["bash", "-c", <<-EOF
    latest_version=$(ls -t ~/infra-ovh/vm-images/backend-*/terraform-vars.json 2>/dev/null | head -n1)
    if [ -z "$latest_version" ]; then
      echo '{"image_name":"backend-1.0"}'
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

resource "openstack_compute_instance_v2" "backend" {
  name        = local.instance_name
  image_id    = data.openstack_images_image_v2.image.id
  flavor_name = local.flavor_name

  network {
    name = local.network_name
  }
}

# Attendre que l'instance soit prête
resource "time_sleep" "wait_for_backend" {
  depends_on = [openstack_compute_instance_v2.backend]
  
  create_duration = "30s"
}

resource "null_resource" "configure_backend_db" {
  depends_on = [time_sleep.wait_for_backend]

  triggers = {
    database_host = var.database_host
    instance_id   = openstack_compute_instance_v2.backend.id
    has_database  = var.database_host != "" ? "yes" : "no"
  }

  connection {
    type        = "ssh"
    user        = "debian"
    private_key = file("~/.ssh/id_rsa")
    host        = openstack_compute_instance_v2.backend.access_ip_v4
    timeout     = "5m"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Configuration de la connexion database...'",
      "echo 'DATABASE_HOST=${var.database_host}' | sudo tee /opt/backend-api/.env",
      "echo 'DATABASE_PORT=5432' | sudo tee -a /opt/backend-api/.env",
      "echo 'DATABASE_NAME=appdb' | sudo tee -a /opt/backend-api/.env",
      "echo 'DATABASE_USER=appuser' | sudo tee -a /opt/backend-api/.env",
      "echo 'DATABASE_PASSWORD=changeme123' | sudo tee -a /opt/backend-api/.env",
      "sudo chown debian:debian /opt/backend-api/.env",
      "sudo systemctl restart backend-api",
      "echo 'Backend configuré avec la database!'"
    ]
  }
}
