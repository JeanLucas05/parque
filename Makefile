.PHONY: help up down restart logs build clean seed test shell-api shell-front version info

help:
	@echo "🐳 Docker Commands - Parque Temático"
	@echo "===================================="
	@echo ""
	@echo "Iniciação:"
	@echo "  make up              - Inicia todos os containers"
	@echo "  make down            - Para todos os containers"
	@echo "  make restart         - Reinicia containers"
	@echo "  make logs            - Mostra logs em tempo real"
	@echo ""
	@echo "Build:"
	@echo "  make build           - Reconstrói as imagens"
	@echo "  make rebuild         - Rebuild sem cache"
	@echo ""
	@echo "Limpeza:"
	@echo "  make clean           - Remove containers e volumes"
	@echo "  make clean-all       - Remove tudo e reconstrói"
	@echo "  make prune           - Remove recursos não utilizados"
	@echo ""
	@echo "Utilitários:"
	@echo "  make seed            - Carrega dados de teste"
	@echo "  make test            - Testa endpoints da API"
	@echo "  make shell-api       - Shell da API"
	@echo "  make shell-front     - Shell do Frontend"
	@echo "  make version         - Versão do Docker"
	@echo "  make info            - Informações do sistema"
	@echo ""

# Iniciação
up:
	@echo "▶ Iniciando containers..."
	docker-compose up -d
	@sleep 3
	@docker-compose ps
	@echo ""
	@echo "✅ Containers iniciados!"
	@echo "   Frontend: http://localhost:3000"
	@echo "   API: http://localhost:4567/api"

down:
	@echo "⏹ Parando containers..."
	docker-compose down
	@echo "✅ Containers parados!"

restart:
	@echo "🔄 Reiniciando containers..."
	docker-compose restart
	@sleep 2
	@docker-compose ps

logs:
	@echo "📋 Logs em tempo real (Ctrl+C para sair)"
	docker-compose logs -f --tail=50

# Build
build:
	@echo "🔨 Construindo imagens..."
	docker-compose build
	@echo "✅ Build concluído!"

rebuild:
	@echo "🔨 Reconstruindo imagens (sem cache)..."
	docker-compose build --no-cache
	@echo "✅ Rebuild concluído!"

# Limpeza
clean:
	@echo "🧹 Removendo containers e volumes..."
	docker-compose down -v
	@echo "✅ Limpeza concluída!"

clean-all:
	@echo "⚠️  Removendo TUDO!"
	docker-compose down -v --rmi all
	@echo "🔨 Reconstruindo..."
	docker-compose build --no-cache
	@echo "▶ Iniciando..."
	docker-compose up -d
	@echo "✅ Sistema reiniciado!"

prune:
	@echo "🧹 Removendo recursos não utilizados..."
	docker system prune -f
	@echo "✅ Prune concluído!"

# Utilitários
seed:
	@echo "📊 Carregando dados de teste..."
	docker-compose exec api ruby seed.rb
	@echo "✅ Dados carregados!"

test:
	@echo "🧪 Testando API..."
	@echo ""
	@echo "Atrações:"
	@curl -s http://localhost:4567/api/atracao | head -c 100
	@echo ""
	@echo ""
	@echo "Visitantes:"
	@curl -s http://localhost:4567/api/visitante | head -c 100
	@echo ""
	@echo ""
	@echo "✅ API respondendo!"

shell-api:
	@echo "🐚 Acessando shell da API..."
	docker-compose exec api sh

shell-front:
	@echo "🐚 Acessando shell do Frontend..."
	docker-compose exec frontend sh

# Informações
version:
	@echo "Docker:"
	@docker --version
	@echo "Docker Compose:"
	@docker-compose --version

info:
	@echo "═════════════════════════════════════════"
	@echo "ℹ️  Informações do Sistema"
	@echo "═════════════════════════════════════════"
	@echo ""
	@echo "🐳 Docker:"
	@docker --version
	@docker-compose --version
	@echo ""
	@echo "📊 Status:"
	@docker-compose ps
	@echo ""
	@echo "🖼️  Imagens:"
	@docker images --format "table {{.Repository}}\t{{.Size}}" | grep parque || echo "Nenhuma imagem parque encontrada"

# Alias
status:
	@docker-compose ps

ps:
	@docker-compose ps

dev:
	@make up

prod:
	@echo "▶ Iniciando em modo produção..."
	docker-compose -f docker-compose.prod.yml up -d
	@sleep 3
	@docker-compose -f docker-compose.prod.yml ps

prod-down:
	@echo "⏹ Parando produção..."
	docker-compose -f docker-compose.prod.yml down

prod-logs:
	docker-compose -f docker-compose.prod.yml logs -f

.DEFAULT_GOAL := help
