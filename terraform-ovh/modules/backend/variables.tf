variable "instance_key" {
  description = "Clé unique de l'instance (ex: api1, api2)"
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

variable "database_hosts" {
  description = "Liste des IPs des serveurs database séparées par des virgules"
  type        = string
  default     = ""
}

# Garder database_host pour la compatibilité (sera déprécié)
variable "database_host" {
  description = "Adresse IP du serveur database (déprécié - utiliser database_hosts)"
  type        = string
  default     = ""
}
