#!/bin/bash -l
set -euo pipefail

source /usr/local/rvm/scripts/rvm

echo ">> Sincronizando fuentes desde /source a /app..."
rsync -a \
  --exclude='.git/' \
  --exclude='log/' \
  --exclude='tmp/' \
  --exclude='spec/' \
  --exclude='docs/' \
  --exclude='storage/' \
  --exclude='node_modules/' \
  --exclude='vendor/bundle/' \
  --exclude='public/assets/' \
  --exclude='public/system/' \
  --exclude='config/database.yml' \
  --exclude='config/secrets.yml' \
  --exclude='bin/*.php' \
  --exclude='bin/*.PHP' \
  --exclude='docker-build/' \
  /source/ /app/

echo ">> Compilando gemas nativas (vendor/bundle)..."
bundle config set --local deployment 'true'
bundle config set --local path 'vendor/bundle'
bundle install

echo ">> Creando database.yml stub para assets:precompile..."
cat > config/database.yml << 'EOF'
production:
  adapter: postgresql
  database: placeholder
EOF

echo ">> Instalando dependencias JS (node_modules)..."
npm install --prefer-offline 2>&1

echo ">> Precompilando assets JS/CSS..."
RAILS_ENV=production SECRET_KEY_BASE=placeholder bundle exec rake assets:precompile

echo ">> Hecho. Sube vendor/bundle y public/assets a SVN manualmente."
