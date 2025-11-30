#  Infrastructure OVH - Terraform, Packer & Ansible

Infrastructure as Code pour déployer une infrastructure web évolutive sur OVH Cloud avec Terraform, Packer et Ansible.

## Table des matières

- [Vue d'ensemble](#-vue-densemble)
- [Architecture](#-architecture)
- [Prérequis](#-prérequis)
- [Configuration](#-configuration)
- [Images Packer](#-images-packer)
- [Modules Terraform](#-modules-terraform)
- [Déploiement](#-déploiement)
- [Gestion](#-gestion-de-linfrastructure)
- [Dépannage](#-dépannage)

## Vue d'ensemble

Déployez une infrastructure web complète comprenant :
- **Serveurs Web Nginx** : Serveurs frontaux avec proxy vers les backends
- **Load Balancer HAProxy** : Répartition de charge entre les serveurs web
- **Serveurs Backend** : API Node.js Express avec connexion à la base de données
- **Base de données PostgreSQL** : Serveur de base de données unique

## Architecture

```
        Internet
           |
     [HAProxy LB] ... # Autant que l'on souhaite
        /  |  \
       /   |   \
  [Web1] [Web2] ... # Autant que l'on souhaite
       \   |   /
        \  |  /
   [API1] [API2] ...  # Autant que l'on souhaite
        \  |  /
         \ | /
      [Database]
```

##  Prérequis

- Terraform >= 1.0. 0
- Packer >= 1.8.0
- Ansible >= 2.9
- Compte OVH Cloud avec credentials API
- Fichier `openrc.sh` depuis l'interface OVH

## Configuration

### 1. Configuration OpenStack

```bash
source openrc.sh
```

### 2. Configuration Terraform

Créez `terraform-ovh/environments/lab/terraform.tfvars` :

```hcl
# Credentials OVH
ovh_application_key    = "votre_application_key"
ovh_application_secret = "votre_application_secret"
ovh_consumer_key       = "votre_consumer_key"

# Instances Web
web_instances = ["web1", "web2"]
web_flavor    = "b2-7"

# Load Balancer HAProxy
haproxy = {
  enabled           = true
  flavor            = "b2-7"
  backend_instances = ["web1", "web2"]
}

# Instances Backend
backend_instances = ["api1", "api2"]
backend_flavor    = "b2-7"

# Base de données
database_enabled = true
database_flavor  = "b2-7"

# Réseau
network_name = "Ext-Net"
```

## Images Packer

### Construire les images

```bash
cd packer/

# Image Nginx
./build-nginx. sh
# Entrer : 1 (numéro serveur), puis 1.0 (version)

# Image HAProxy
./build-haproxy. sh 1.0

# Image Backend
./build-backend.sh 1.0

# Image Database
./build-database. sh 1.0
```

Les images sont créées dans `~/infra-ovh/vm-images/`

## Déploiement

```bash
cd terraform-ovh/environments/lab/

# Initialiser
terraform init

# Prévisualiser
terraform plan

# Déployer
terraform apply

# Afficher les outputs
terraform output

# Détruire
terraform destroy
```

## Gestion de l'Infrastructure

### Ajouter une instance web

```hcl
web_instances = ["web1", "web2", "web3"]
```

```bash
terraform apply
```

### Ajouter un backend

```hcl
backend_instances = ["api1", "api2", "api3"]
```

```bash
terraform apply
```

### Activer/Désactiver HAProxy

```hcl
haproxy = {
  enabled           = true  # ou false
  flavor            = "b2-7"
  backend_instances = ["web1", "web2"]
}
```

### Activer/Désactiver la Database

```hcl
database_enabled = true  # ou false
```

## Connexion

```bash
# Afficher les outputs
terraform output

# Se connecter en SSH (exemple)
ssh -i ~/.ssh/id_rsa debian@<instance_ip>

# Tester le load balancer
curl http://<haproxy_ip>
```

## Structure du Projet

```
infra-ovh/
├── README.md
├── openrc.sh                    # Config OpenStack
├── packer/
│   ├── debian-nginx.pkr.hcl
│   ├── debian-haproxy.pkr.hcl
│   ├── debian-backend.pkr.hcl
│   ├── debian-database.pkr.hcl
│   └── http/preseed.cfg
├── ansible/
│   ├── playbooks/
│   │   ├── web.yml
│   │   ├── haproxy.yml
│   │   ├── backend.yml
│   │   └── database.yml
│   └── templates/
│       ├── index.html.j2
│       ├── nginx-proxy.conf.j2
│       └── backend-api.js.j2
├── terraform-ovh/
│   ├── modules/
│   │   ├── database/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   ├── outputs.tf
│   │   │   └── locals.tf
│   │   ├── backend/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   ├── outputs.tf
│   │   │   └── locals.tf
│   │   ├── web/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   ├── outputs.tf
│   │   │   └── locals.tf
│   │   └── haproxy/
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       ├── outputs.tf
│   │       └── locals.tf
│   └── environments/
│       └── lab/
│           ├── main.tf
│           ├── variables.tf
│           ├── outputs.tf
│           └── terraform.tfvars
└── vm-images/                   # Généré par Packer
    ├── web-1.0/
    ├── haproxy-1.0/
    ├── backend-1.0/
    └── database-1.0/
```

##  Sécurité

/!\ **Ne jamais commite** :
- `openrc.sh`
- `terraform.tfvars`
- `*.tfstate`
- Clés SSH privées

##  Dépannage

### Erreur "External Program Execution Failed"

```bash
# Vérifier les images
ls ~/infra-ovh/vm-images/

# Reconstruire si nécessaire
cd packer/
./build-nginx.sh
```

### Erreur d'authentification

```bash
# Re-sourcer OpenStack
source openrc.sh

# Vérifier les credentials dans terraform.tfvars
```

### Quota dépassé

- Vérifier votre quota OVH
- Détruire les ressources inutilisées : `terraform destroy`

### Flavor non trouvé

```bash
# Lister les flavors disponibles
openstack flavor list

# Utiliser un flavor valide : b2-7, b2-15, b2-30, etc.
```

## Ressources

- [Documentation Terraform OVH](https://registry.terraform.io/providers/ovh/ovh/latest/docs)
- [Documentation OpenStack Provider](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs)
- [Documentation Packer](https://www.packer.io/docs)
- [Documentation Ansible](https://docs.ansible.com/)
