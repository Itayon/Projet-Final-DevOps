output "instance_id" {
  description = "ID de l'instance database"
  value       = openstack_compute_instance_v2.database.id
}

output "instance_ip" {
  description = "Adresse IP de l'instance database"
  value       = openstack_compute_instance_v2.database.access_ip_v4
}

output "instance_name" {
  description = "Nom de l'instance database"
  value       = openstack_compute_instance_v2.database.name
}

output "ssh_command" {
  description = "Commande SSH pour cette instance"
  value       = "ssh -i ~/.ssh/id_rsa debian@${openstack_compute_instance_v2.database.access_ip_v4}"
}

output "connection_string" {
  description = "Connection string PostgreSQL"
  value       = "postgresql://appuser:changeme123@${openstack_compute_instance_v2.database.access_ip_v4}:5432/appdb"
  sensitive   = true
}
