# Module Database (instance unique avec configuration intégrée)
module "database" {
  source = "../../modules/database"
  count  = var.database_enabled ? 1 : 0

  instance_key = "db"
  flavor_name  = var.database_flavor
  network_name = var.network_name
}

# Instances Backend API avec connexion database
module "backend" {
  source   = "../../modules/backend"
  for_each = var.backend_instances

  instance_key  = each.key
  flavor_name   = var.backend_flavor
  network_name  = var.network_name
  database_host = var.database_enabled ? module.database[0].instance_ip : ""

  depends_on = [module.database]
}

# Attendre que les backends soient prêts
resource "time_sleep" "wait_for_backends" {
  depends_on = [module.backend]
  
  create_duration = "30s"
}

# Instances Web avec proxy vers backends
module "web" {
  source   = "../../modules/web"
  for_each = var.web_instances

  instance_key = each.key
  flavor_name  = var.web_flavor
  network_name = var.network_name
  backend_ips  = length(var.backend_instances) > 0 ? [for backend in module.backend : backend.instance_ip] : []

  depends_on = [time_sleep.wait_for_backends]
}

# Attendre que toutes les instances web soient prêtes
resource "time_sleep" "wait_for_web_instances" {
  depends_on = [module.web]
  
  create_duration = "10s"
}

# Instance HAProxy (Load Balancer)
module "haproxy" {
  count  = var.haproxy.enabled ? 1 : 0
  source = "../../modules/haproxy"

  instance_name = "HAProxy Load Balancer"
  backend_ips = [
    for instance_key in var.haproxy.backend_instances : 
    module.web[instance_key].instance_ip
  ]
  flavor_name  = var.haproxy.flavor
  network_name = var.network_name

  depends_on = [time_sleep.wait_for_web_instances]
}