#!/bin/bash

echo "🎡 Iniciando Sistema de Reservas (API + Frontend)"
echo "=================================================="

# Mover para diretório da API
cd api

# Instalar dependências Ruby
echo "📦 Instalando dependências da API..."
bundle install

# Mover para diretório do frontend
cd ../frontend

# Instalar dependências Node
echo "📦 Instalando dependências do Frontend..."
npm install

echo ""
echo "✅ Instalação completa!"
echo ""
echo "Para executar o sistema, abra 2 terminais:"
echo ""
echo "Terminal 1 (API):"
echo "  cd api"
echo "  ruby app.rb"
echo ""
echo "Terminal 2 (Frontend):"
echo "  cd frontend"
echo "  npm run dev"
echo ""
echo "Acesse http://localhost:3000 no navegador"
