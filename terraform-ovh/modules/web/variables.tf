# Aucune variable nécessaire - tout est défini en local

variable "instance_key" {
  description = "Clé unique de l'instance (ex: web1, web2)"
  type        = string
}

variable "flavor_name" {
  description = "Type d'instance"
  type        = string
}

variable "network_name" {
  description = "Nom du réseau"
  type        = string
}

variable "backend_ips" {
  description = "Liste des IPs des serveurs backend"
  type        = list(string)
  default     = []
}
