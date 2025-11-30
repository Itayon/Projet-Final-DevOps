#!/bin/bash
set -e

VERSION=${1:-1.1}

echo "==> Construction de l'image HAProxy v${VERSION}..."

if ! command -v openstack &> /dev/null; then
    echo "⚠️  Warning: OpenStack CLI non trouvé. L'image ne sera pas uploadée automatiquement."
fi

# Nettoyer les anciennes tentatives
rm -rf ~/infra-ovh/vm-images/haproxy-${VERSION} 2>/dev/null || true

# Définir les variables d'environnement Packer
export PACKER_LOG=1
export PACKER_LOG_PATH="packer-haproxy-${VERSION}.log"

echo "📝 Les logs détaillés sont dans: ${PACKER_LOG_PATH}"

packer build \
  -var "version=${VERSION}" \
  -on-error=abort \
  debian-haproxy.pkr.hcl

echo "==> ✅ Image HAProxy v${VERSION} construite avec succès!"
echo "📄 Voir les logs: ${PACKER_LOG_PATH}"
