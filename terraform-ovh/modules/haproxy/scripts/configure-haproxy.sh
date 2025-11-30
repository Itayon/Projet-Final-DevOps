#!/bin/bash
# Script exécuté par cloud-init au boot pour créer le fichier de backends

cat > /tmp/haproxy-backends.txt << 'EOF'
%{ for idx, ip in backend_ips ~}
${ip}
%{ endfor ~}
EOF

echo "Fichier /tmp/haproxy-backends.txt créé avec les backends"
