output "web_instances" {
  description = "Outputs de toutes les instances web"
  value       = module.web
}

output "haproxy" {
  description = "Outputs du load balancer HAProxy"
  value       = var.haproxy.enabled ? module.haproxy[0] : null
}

output "load_balancer_url" {
  description = "URL du load balancer"
  value       = var.haproxy.enabled ? module.haproxy[0].lb_url : "HAProxy désactivé"
}

output "haproxy_backends" {
  description = "Liste des instances web utilisées comme backends"
  value = var.haproxy.enabled ? {
    for key in var.haproxy.backend_instances : key => module.web[key].instance_ip
  } : {}
}

output "backend_instances" {
  description = "Outputs de toutes les instances backend"
  value       = module.backend
}

output "backend_api_urls" {
  description = "URLs des APIs backend"
  value = {
    for key, backend in module.backend : key => backend.api_url
  }
}

output "database" {
  description = "Informations sur le serveur database"
  value       = var.database_enabled ? module.database[0] : null
  sensitive   = true
}

output "database_connection" {
  description = "Chaîne de connexion PostgreSQL"
  value       = var.database_enabled ? module.database[0].connection_string : "Database désactivée"
  sensitive   = true
}
