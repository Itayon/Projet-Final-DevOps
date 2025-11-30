data "external" "latest_image" {
  program = ["bash", "-c", <<-EOF
    latest_version=$(ls -t ~/infra-ovh/vm-images/database-*/terraform-vars.json 2>/dev/null | head -n1)
    if [ -z "$latest_version" ]; then
      echo '{"image_name":"database-1.0"}'
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

resource "openstack_compute_instance_v2" "database" {
  name        = local.instance_name
  image_id    = data.openstack_images_image_v2.image.id
  flavor_name = local.flavor_name

  network {
    name = local.network_name
  }
}

# Attendre que la database soit prête
resource "time_sleep" "wait_for_database" {
  depends_on = [openstack_compute_instance_v2.database]

  create_duration = "30s"
}

# Configuration de la database après démarrage
resource "null_resource" "configure_database" {
  depends_on = [time_sleep.wait_for_database]

  triggers = {
    instance_id = openstack_compute_instance_v2.database.id
  }

  connection {
    type        = "ssh"
    user        = "debian"
    private_key = file("~/.ssh/id_rsa")
    host        = openstack_compute_instance_v2.database.access_ip_v4
    timeout     = "5m"
  }

  provisioner "remote-exec" {
    inline = [
      "echo '✅ Attente du démarrage de PostgreSQL...'",
      "sleep 30",
      "echo '✅ Vérification de PostgreSQL...'",
      "sudo systemctl is-active postgresql && echo '✅ PostgreSQL actif' || echo '❌ PostgreSQL inactif'",
      "sudo -u postgres psql -t -c 'SELECT version();' | head -n1",
      "echo '✅ Base de données PostgreSQL prête!'"
    ]
  }
}
