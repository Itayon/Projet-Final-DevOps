output "instance_id" {
  description = "ID de l'instance HAProxy"
  value       = openstack_compute_instance_v2.haproxy.id
}

output "instance_ip" {
  description = "Adresse IP publique du load balancer"
  value       = openstack_compute_instance_v2.haproxy.access_ip_v4
}

output "instance_name" {
  description = "Nom de l'instance HAProxy"
  value       = openstack_compute_instance_v2.haproxy.name
}

output "ssh_command" {
  description = "Commande SSH pour HAProxy"
  value       = "ssh -i ~/.ssh/id_rsa debian@${openstack_compute_instance_v2.haproxy.access_ip_v4}"
}

output "lb_url" {
  description = "URL du load balancer"
  value       = "http://${openstack_compute_instance_v2.haproxy.access_ip_v4}"
}
