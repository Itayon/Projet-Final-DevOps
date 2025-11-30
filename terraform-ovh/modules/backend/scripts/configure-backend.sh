#!/bin/bash
cat > /tmp/database-config.txt << 'EOF'
DATABASE_HOST=${database_host}
DATABASE_PORT=5432
DATABASE_NAME=appdb
DATABASE_USER=appuser
DATABASE_PASSWORD=changeme123
EOF
echo "Configuration database préparée"
