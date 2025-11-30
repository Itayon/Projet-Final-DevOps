#!/bin/bash
# filepath: /home/skinoz/infra-ovh/packer/build.sh

set -e

VERSION=${1:-1.0}

echo "==> Construction de l'image Web Server v${VERSION}..."

if ! command -v openstack &> /dev/null; then
    echo "⚠️  Warning: OpenStack CLI non trouvé. L'image ne sera pas uploadée automatiquement."
fi

packer build \
  -var "version=${VERSION}" \
  debian-nginx.pkr.hcl

echo "==> ✅ Image Web Server v${VERSION} construite avec succès!"
