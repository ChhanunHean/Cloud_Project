#!/bin/bash
# ── KeypKey Backend Bootstrap Script ──────────────────────
# This runs automatically on every new EC2 instance

set -e
exec > /var/log/user-data.log 2>&1

echo "🚀 Starting KeypKey backend setup..."

# Install Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
apt-get install -y nodejs git

# Clone or pull the backend
/home/ubuntu
# We clone the repo into 'app'
git clone https://github.com/ChhanunHean/Cloud_Project.git app || true
cd app
git pull || true

# Enter the backend directory
cd keypkey-backend

# Write .env with RDS credentials injected by Terraform
cat > .env << 'ENVEOF'
PORT=3000
DB_HOST=${db_host}
DB_PORT=${db_port}
DB_USER=${db_username}
DB_PASSWORD=${db_password}
DB_NAME=${db_name}
JWT_SECRET=${jwt_secret}
VAULT_SECRET=${vault_secret}
FRONTEND_URL=${frontend_url}
ENVEOF

echo " .env written with RDS config"

# Install PM2 to keep Node.js running
npm install -g pm2

# Install app dependencies & start
npm install
pm2 delete server || true
pm2 start server.js --name "server"
pm2 startup systemd -u ubuntu --hp /home/ubuntu
pm2 save

echo " KeypKey backend is running on port 3000!"
