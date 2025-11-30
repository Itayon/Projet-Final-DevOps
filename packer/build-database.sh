#!/bin/bash
set -e

VERSION=${1:-1.1}

echo "==> Construction de l'image Database v${VERSION} avec Multi-Master..."

if ! command -v openstack &> /dev/null; then
    echo "⚠️  Warning: OpenStack CLI non trouvé. L'image ne sera pas uploadée automatiquement."
fi

# Nettoyer les anciennes tentatives
rm -rf ~/infra-ovh/vm-images/database-${VERSION} 2>/dev/null || true

# Définir les variables d'environnement Packer
export PACKER_LOG=1
export PACKER_LOG_PATH="packer-database-${VERSION}.log"

echo "📝 Les logs détaillés sont dans: ${PACKER_LOG_PATH}"

packer build \
  -var "version=${VERSION}" \
  -on-error=abort \
  debian-database.pkr.hcl

echo "==> ✅ Image Database v${VERSION} construite avec succès!"
echo "📄 Voir les logs: ${PACKER_LOG_PATH}"
