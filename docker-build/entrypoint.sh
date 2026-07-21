#!/bin/bash -l
set -eo pipefail

source /usr/local/rvm/scripts/rvm
rvm use "$RUBY_VERSION" --default

echo ">> Sincronizando fuentes desde /source a /app..."
rsync -a \
  --exclude='.git/' \
  --exclude='.claude/' \
  --exclude='.vscode/' \
  --exclude='.github/' \
  --exclude='.gitlab-ci.yml' \
  --exclude='.gitignore' \
  --exclude='.gitattributes' \
  --exclude='.ruby-gemset' \
  --exclude='.ruby-lsp/' \
  --exclude='.tool-versions' \
  --exclude='.byebug_history' \
  --exclude='.knapsack_pro/' \
  --exclude='.playwright-mcp/' \
  --exclude='CLAUDE.md' \
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
  --exclude='config/deploy-secrets.yml' \
  --exclude='db/schema.rb' \
  --exclude='bin/*.php' \
  --exclude='bin/*.PHP' \
  --exclude='docker-build/' \
  --exclude='.eslintrc' \
  --exclude='.nvmrc' \
  --exclude='public/machine_learning/' \
  --exclude='public/sitemap.xml' \
  --exclude='public/tenants' \
  --exclude='public/system' \
  --exclude='lib/tasks/custom/docker_build.rake' \
  /source/ /app/

echo ">> Eliminando .ruby-version residual (no gestionamos versión Ruby por archivo)..."
rm -f /app/.ruby-version

echo ">> Compilando gemas nativas (vendor/bundle)..."
rm -f .bundle/config
rm -rf vendor/bundle
gem install bundler -v 2.5.22 --no-document
bundle config set --local deployment 'true'
bundle config set --local path 'vendor/bundle'
bundle config set --local without 'development test'
bundle install

echo ">> Corrigiendo shebangs ruby_executable_hooks para servidores sin RVM..."
find vendor/bundle/ruby/3.3.0/bin -type f | \
  xargs grep -l "ruby_executable_hooks" 2>/dev/null | \
  xargs sed -i 's|#!/usr/bin/env ruby_executable_hooks|#!/usr/bin/env ruby|g' 2>/dev/null || true

echo ">> Creando database.yml stub para assets:precompile..."
cat > config/database.yml << 'EOF'
production:
  adapter: postgresql
  database: placeholder
EOF

echo ">> Instalando dependencias JS en contenedor (fuera del SVN)..."
mkdir -p /tmp/npm_build
cp package.json package-lock.json /tmp/npm_build/
cd /tmp/npm_build && npm install 2>&1
cd /app
[ -d node_modules ] && mv node_modules /tmp/node_modules_svn_backup
ln -s /tmp/npm_build/node_modules /app/node_modules

echo ">> Precompilando assets JS/CSS..."
RAILS_ENV=production SECRET_KEY_BASE=placeholder bundle exec rake assets:precompile

echo ">> Limpiando ficheros temporales de compilacion..."
rm -f config/database.yml
svn revert .bundle/config 2>/dev/null || true
unlink /app/node_modules 2>/dev/null || true
[ -d /tmp/node_modules_svn_backup ] && mv /tmp/node_modules_svn_backup /app/node_modules
rm -rf log/ tmp/

echo ">> Hecho. Sube vendor/bundle y public/assets a SVN manualmente."
