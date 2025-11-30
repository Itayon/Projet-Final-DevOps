variable "instance_key" {
  description = "Clé unique de l'instance (ex: db-master, db-slave)"
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

variable "is_master" {
  description = "Si c'est le serveur master"
  type        = bool
  default     = false
}

variable "master_ip" {
  description = "IP du serveur master (pour les slaves)"
  type        = string
  default     = ""
}

variable "slave_ips" {
  description = "Liste des IPs des slaves (pour le master)"
  type        = list(string)
  default     = []
}
