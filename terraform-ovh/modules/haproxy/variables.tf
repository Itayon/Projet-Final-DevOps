variable "instance_name" {
  description = "Nom de l'instance HAProxy"
  type        = string
  default     = "HAProxy Load Balancer"
}

variable "backend_ips" {
  description = "Liste des IPs des serveurs backend"
  type        = list(string)
}

variable "flavor_name" {
  description = "Type d'instance"
  type        = string
}

variable "network_name" {
  description = "Nom du réseau"
  type        = string
}
