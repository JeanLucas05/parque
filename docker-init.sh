#!/bin/bash

# 🐳 Docker Setup - Sistema de Reservas Parque Temático

echo "🐳 Verificando Docker..."
echo ""

# Verificar Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker não está instalado!"
    echo ""
    echo "Para instalar Docker:"
    echo "  Windows/Mac: https://www.docker.com/products/docker-desktop"
    echo "  Linux: sudo apt install docker.io docker-compose"
    exit 1
fi

# Verificar Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose não está instalado!"
    echo ""
    echo "Para instalar Docker Compose:"
    echo "  Windows/Mac: Já vem com Docker Desktop"
    echo "  Linux: sudo apt install docker-compose"
    exit 1
fi

echo "✅ Docker: $(docker --version)"
echo "✅ Docker Compose: $(docker-compose --version)"
echo ""

echo "🔨 Construindo imagens..."
docker-compose build

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build concluído com sucesso!"
    echo ""
    echo "📋 Próximos passos:"
    echo ""
    echo "  1. Iniciar os containers:"
    echo "     docker-compose up -d"
    echo ""
    echo "  2. Verificar status:"
    echo "     docker-compose ps"
    echo ""
    echo "  3. Ver logs:"
    echo "     docker-compose logs -f"
    echo ""
    echo "  4. Carregar dados de teste:"
    echo "     docker-compose exec api ruby seed.rb"
    echo ""
    echo "  5. Acessar:"
    echo "     Frontend: http://localhost:3000"
    echo "     API: http://localhost:4567/api"
    echo ""
    echo "  6. Parar:"
    echo "     docker-compose down"
    echo ""
else
    echo "❌ Erro durante o build!"
    exit 1
fi
