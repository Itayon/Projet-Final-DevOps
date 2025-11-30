#!/bin/bash
cat > /tmp/backend-ips.txt << 'EOF'
%{ for ip in backend_ips ~}
${ip}
%{ endfor ~}
EOF
echo "Fichier /tmp/backend-ips.txt créé avec les backends"
