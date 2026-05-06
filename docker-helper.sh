#!/bin/bash

# Docker Helper Script para Sistema de Reservas Parque Temático
# Uso: ./docker-helper.sh [comando]

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_menu() {
  echo -e "${BLUE}═════════════════════════════════════════${NC}"
  echo -e "${BLUE}🐳 Docker Helper - Parque Temático${NC}"
  echo -e "${BLUE}═════════════════════════════════════════${NC}"
  echo ""
  echo "Comandos disponíveis:"
  echo ""
  echo "  $(tput bold)Básico:$(tput sgr0)"
  echo "    up              Inicia todos os containers"
  echo "    down            Para todos os containers"
  echo "    restart         Reinicia todos os containers"
  echo "    logs            Mostra logs em tempo real"
  echo "    status          Mostra status dos containers"
  echo ""
  echo "  $(tput bold)Build:$(tput sgr0)"
  echo "    build           Reconstrói as imagens"
  echo "    rebuild         Rebuild sem cache"
  echo ""
  echo "  $(tput bold)Limpeza:$(tput sgr0)"
  echo "    clean           Remove containers e volumes"
  echo "    reset           Remove tudo e reconstrói"
  echo "    prune           Remove containers não usados"
  echo ""
  echo "  $(tput bold)Shell:$(tput sgr0)"
  echo "    shell-api       Acessa shell da API"
  echo "    shell-front     Acessa shell do Frontend"
  echo ""
  echo "  $(tput bold)Dados:$(tput sgr0)"
  echo "    seed            Carrega dados de teste"
  echo "    test            Testa endpoints da API"
  echo ""
  echo "  $(tput bold)Info:$(tput sgr0)"
  echo "    version         Mostra versão do Docker"
  echo "    info            Mostra informações"
  echo "    help            Mostra este menu"
  echo ""
}

case "$1" in
  up)
    echo -e "${GREEN}▶ Iniciando containers...${NC}"
    docker-compose up -d
    sleep 3
    echo -e "${GREEN}✅ Containers iniciados!${NC}"
    docker-compose ps
    echo ""
    echo -e "${GREEN}Acesse:${NC}"
    echo "  Frontend: http://localhost:3000"
    echo "  API: http://localhost:4567/api"
    ;;

  down)
    echo -e "${YELLOW}⏹ Parando containers...${NC}"
    docker-compose down
    echo -e "${GREEN}✅ Containers parados!${NC}"
    ;;

  restart)
    echo -e "${YELLOW}🔄 Reiniciando containers...${NC}"
    docker-compose restart
    sleep 2
    echo -e "${GREEN}✅ Containers reiniciados!${NC}"
    docker-compose ps
    ;;

  logs)
    echo -e "${BLUE}📋 Logs em tempo real (Ctrl+C para sair)${NC}"
    docker-compose logs -f --tail=50
    ;;

  status|ps)
    echo -e "${BLUE}📊 Status dos containers:${NC}"
    docker-compose ps
    ;;

  build)
    echo -e "${YELLOW}🔨 Construindo imagens...${NC}"
    docker-compose build
    echo -e "${GREEN}✅ Build concluído!${NC}"
    ;;

  rebuild)
    echo -e "${YELLOW}🔨 Reconstruindo imagens (sem cache)...${NC}"
    docker-compose build --no-cache
    echo -e "${GREEN}✅ Rebuild concluído!${NC}"
    ;;

  clean)
    echo -e "${YELLOW}🧹 Removendo containers e volumes...${NC}"
    docker-compose down -v
    echo -e "${GREEN}✅ Limpeza concluída!${NC}"
    ;;

  reset)
    echo -e "${RED}⚠️  AVISO: Isso removerá tudo! (Ctrl+C para cancelar)${NC}"
    read -p "Digite 'sim' para confirmar: " confirm
    if [ "$confirm" = "sim" ]; then
      echo -e "${YELLOW}🔄 Resetando tudo...${NC}"
      docker-compose down -v --rmi all
      docker-compose build --no-cache
      docker-compose up -d
      echo -e "${GREEN}✅ Reset concluído!${NC}"
      docker-compose ps
    else
      echo "Cancelado"
    fi
    ;;

  prune)
    echo -e "${YELLOW}🧹 Removendo recursos não utilizados...${NC}"
    docker system prune -f
    echo -e "${GREEN}✅ Prune concluído!${NC}"
    ;;

  shell-api)
    echo -e "${BLUE}🐚 Acessando shell da API...${NC}"
    docker-compose exec api sh
    ;;

  shell-front)
    echo -e "${BLUE}🐚 Acessando shell do Frontend...${NC}"
    docker-compose exec frontend sh
    ;;

  seed)
    echo -e "${YELLOW}📊 Carregando dados de teste...${NC}"
    docker-compose exec api ruby seed.rb
    echo -e "${GREEN}✅ Dados carregados!${NC}"
    ;;

  test)
    echo -e "${BLUE}🧪 Testando API...${NC}"
    echo ""
    echo "Atrações:"
    curl -s http://localhost:4567/api/atracao | head -c 100
    echo -e "\n"
    echo "Visitantes:"
    curl -s http://localhost:4567/api/visitante | head -c 100
    echo -e "\n\n${GREEN}✅ API respondendo!${NC}"
    ;;

  version)
    echo -e "${BLUE}Docker:${NC}"
    docker --version
    echo -e "${BLUE}Docker Compose:${NC}"
    docker-compose --version
    ;;

  info)
    echo -e "${BLUE}═════════════════════════════════════════${NC}"
    echo -e "${BLUE}ℹ️  Informações do Sistema${NC}"
    echo -e "${BLUE}═════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}🐳 Docker:${NC}"
    docker --version
    docker-compose --version
    echo ""
    echo -e "${YELLOW}📊 Status:${NC}"
    docker-compose ps
    echo ""
    echo -e "${YELLOW}📈 Uso de Recursos:${NC}"
    docker stats --no-stream --format "table {{.Container}}\t{{.MemUsage}}\t{{.CPUPerc}}" 2>/dev/null || echo "N/A"
    echo ""
    echo -e "${YELLOW}🖼️  Imagens:${NC}"
    docker images --format "table {{.Repository}}\t{{.Size}}" | grep parque || echo "Nenhuma imagem parque encontrada"
    ;;

  help|--help|-h|"")
    show_menu
    ;;

  *)
    echo -e "${RED}❌ Comando desconhecido: $1${NC}"
    echo ""
    show_menu
    exit 1
    ;;
esac
