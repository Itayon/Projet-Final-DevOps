output "instance_id" {
  description = "ID de l'instance web"
  value       = openstack_compute_instance_v2.web.id
}

output "instance_ip" {
  description = "Adresse IP de l'instance web"
  value       = openstack_compute_instance_v2.web.access_ip_v4
}

output "instance_name" {
  description = "Nom de l'instance web"
  value       = openstack_compute_instance_v2.web.name
}

output "ssh_command" {
   description = "Commande SSH pour cette instance"
   value       = "ssh -i ~/.ssh/id_rsa debian@${openstack_compute_instance_v2.web.access_ip_v4}"
}