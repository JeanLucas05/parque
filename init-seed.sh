#!/bin/bash
set -e

echo "🚀 Iniciando aplicação com Seed Automática..."
echo "================================================"

# Aguardar conexão com banco
echo "⏳ Aguardando PostgreSQL estar pronto..."
max_attempts=30
attempt=1

while ! pg_isready -h postgres -U disney_user -d disney_db &> /dev/null; do
  if [ $attempt -eq $max_attempts ]; then
    echo "❌ PostgreSQL não ficou pronto após $max_attempts tentativas"
    exit 1
  fi
  echo "   Tentativa $attempt/$max_attempts..."
  sleep 2
  ((attempt++))
done

echo "✅ PostgreSQL está pronto!"

# Executar seed.rb
echo ""
echo "🌱 Executando seed de dados..."
ruby seed.rb

echo ""
echo "✅ Seed concluída!"

# Iniciar aplicação
echo ""
echo "🎡 Iniciando Sinatra API..."
echo "================================================"
exec ruby api/app.rb -o 0.0.0.0
