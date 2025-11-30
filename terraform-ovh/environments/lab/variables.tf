variable "ovh_application_key" {
  description = "OVH Application Key"
  type        = string
  sensitive   = true
}

variable "ovh_application_secret" {
  description = "OVH Application Secret"
  type        = string
  sensitive   = true
}

variable "ovh_consumer_key" {
  description = "OVH Consumer Key"
  type        = string
  sensitive   = true
}

variable "web_instances" {
  description = "Liste des instances web à créer"
  type        = set(string)
}

variable "web_flavor" {
  description = "Type d'instance pour les serveurs web"
  type        = string
}

variable "network_name" {
  description = "Nom du réseau"
  type        = string
}

variable "haproxy_flavor" {
  description = "Type d'instance pour HAProxy"
  type        = string
  default     = "b2-7"
}

variable "haproxy" {
  description = "Configuration du load balancer HAProxy"
  type = object({
    enabled           = bool
    flavor            = string
    backend_instances = list(string)
  })
  default = {
    enabled           = false
    flavor            = "b2-7"
    backend_instances = []
  }
}

variable "backend_instances" {
  description = "Liste des instances backend à créer"
  type        = set(string)
  default     = []
}

variable "backend_flavor" {
  description = "Type d'instance pour les serveurs backend"
  type        = string
  default     = "b2-7"
}

variable "database_enabled" {
  description = "Activer le serveur de base de données"
  type        = bool
  default     = false
}

variable "database_flavor" {
  description = "Type d'instance pour le serveur database"
  type        = string
  default     = "b2-7"
}