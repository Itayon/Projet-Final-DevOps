output "instance_id" {
  description = "ID de l'instance backend"
  value       = openstack_compute_instance_v2.backend.id
}

output "instance_ip" {
  description = "Adresse IP de l'instance backend"
  value       = openstack_compute_instance_v2.backend.access_ip_v4
}

output "instance_name" {
  description = "Nom de l'instance backend"
  value       = openstack_compute_instance_v2.backend.name
}

output "ssh_command" {
  description = "Commande SSH pour cette instance"
  value       = "ssh -i ~/.ssh/id_rsa debian@${openstack_compute_instance_v2.backend.access_ip_v4}"
}

output "api_url" {
  description = "URL de l'API backend"
  value       = "http://${openstack_compute_instance_v2.backend.access_ip_v4}:3000"
}
