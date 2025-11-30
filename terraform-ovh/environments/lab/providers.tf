# Définir les providers et fixer les versions
terraform {
  required_version = ">= 0.14.0" # Prend en compte les versions de terraform à partir de la 0.14.0
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = ">= 3.0.0"
    }

    ovh = {
      source  = "ovh/ovh"
      version = ">= 2.1.0"
    }

    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.0"
    }
  }
}

# Configure le fournisseur OpenStack hébergé par OVHcloud
provider "openstack" {
  auth_url    = "https://auth.cloud.ovh.net/v3/" # URL d'authentification
  domain_name = "default"                        # Nom de domaine - Toujours à "default" pour OVHcloud
  alias       = "ovh"                            # Un alias
}

provider "ovh" {
  endpoint           = "ovh-eu"
  application_key    = var.ovh_application_key
  application_secret = var.ovh_application_secret
  consumer_key       = var.ovh_consumer_key
}