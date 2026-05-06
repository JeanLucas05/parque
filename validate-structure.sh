#!/bin/bash

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🔍 Validando Estrutura do Projeto...${NC}\n"

# Verificar arquivos principais
files=(
  "README.md"
  "frontend/package.json"
  "frontend/vite.config.js"
  "frontend/src/App.jsx"
  "frontend/src/main.jsx"
  "frontend/src/index.css"
  "frontend/src/components/MenuPrincipal.jsx"
  "frontend/src/components/PortalVisitante.jsx"
  "frontend/src/components/PainelAdministrador.jsx"
  "frontend/src/components/MenuCadastro.jsx"
  "frontend/src/services/api.js"
  "frontend/index.html"
  "api/app.rb"
  "api/Gemfile"
)

missing=0

for file in "${files[@]}"; do
  if [ -f "$file" ]; then
    echo -e "${GREEN}✅${NC} $file"
  else
    echo -e "${RED}❌${NC} $file"
    ((missing++))
  fi
done

echo ""

# Verificar diretórios
dirs=(
  "frontend/src/components"
  "frontend/src/services"
  "api"
)

for dir in "${dirs[@]}"; do
  if [ -d "$dir" ]; then
    echo -e "${GREEN}✅${NC} Diretório: $dir"
  else
    echo -e "${RED}❌${NC} Diretório: $dir"
    ((missing++))
  fi
done

echo ""
echo "=========================================="

if [ $missing -eq 0 ]; then
  echo -e "${GREEN}✅ Todas as estruturas estão corretas!${NC}"
  echo ""
  echo -e "${YELLOW}📦 Próximos passos:${NC}"
  echo "  1. cd api && bundle install"
  echo "  2. cd ../frontend && npm install"
  echo "  3. Em terminal 1: cd api && ruby app.rb"
  echo "  4. Em terminal 2: cd frontend && npm run dev"
  echo "  5. Acesse: http://localhost:3000"
else
  echo -e "${RED}❌ Faltam $missing arquivo(s)/diretório(s)${NC}"
  exit 1
fi
