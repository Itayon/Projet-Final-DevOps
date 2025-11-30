locals {
  instance_name = "Database ${var.is_master ? "Master" : "Slave"} ${var.instance_key}"
  flavor_name   = var.flavor_name
  network_name  = var.network_name
}
