# 🐳 Guia Docker - Sistema de Reservas Parque Temático

## 📋 Índice
1. [Pré-requisitos](#pré-requisitos)
2. [Instalação](#instalação)
3. [Como Executar](#como-executar)
4. [Comandos Úteis](#comandos-úteis)
5. [Troubleshooting](#troubleshooting)
6. [Estrutura](#estrutura)

## 📦 Pré-requisitos

- ✅ **Docker** 20.10+
- ✅ **Docker Compose** 1.29+

### Instalar Docker

#### Windows
- Baixe [Docker Desktop](https://www.docker.com/products/docker-desktop)
- Instale e reinicie o computador

#### macOS
```bash
brew install docker docker-compose
# Ou instale Docker Desktop
```

#### Linux (Ubuntu/Debian)
```bash
sudo apt update
sudo apt install docker.io docker-compose
sudo usermod -aG docker $USER
```

**Validar instalação:**
```bash
docker --version
docker-compose --version
```

## 🚀 Como Executar

### Opção 1: Docker Compose (Recomendado - Tudo de uma vez)

```bash
# Na raiz do projeto
docker-compose up -d

# Aguarde 30-60 segundos para as dependências instalarem
```

**Acessar:**
- Frontend: http://localhost:3000
- API: http://localhost:4567/api

### Opção 2: Build e Run Separados

```bash
# Build das imagens
docker-compose build

# Executar em background
docker-compose up -d

# Ou em foreground (ver logs)
docker-compose up
```

### Opção 3: Desenvolvimento com Hot Reload

Para o frontend com HMR (Hot Module Reload):

```bash
# Modificar docker-compose.yml temporariamente para:
# frontend command: npm run dev

# Ou:
cd frontend
npm install
npm run dev
```

## 📊 Verificar Status

### Ver containers rodando
```bash
docker-compose ps
```

Deve aparecer:
```
NAME                 STATUS
parque-api           Up 2 minutes (healthy)
parque-frontend      Up 1 minute (healthy)
```

### Ver logs
```bash
# Todos os logs
docker-compose logs -f

# Apenas API
docker-compose logs -f api

# Apenas Frontend
docker-compose logs -f frontend

# Últimas 100 linhas
docker-compose logs --tail=100
```

## 🎮 Comandos Úteis

### Iniciar/Parar

```bash
# Iniciar
docker-compose up -d

# Parar
docker-compose stop

# Parar e remover containers
docker-compose down

# Remover tudo (incluindo volumes)
docker-compose down -v

# Reiniciar
docker-compose restart

# Reiniciar um serviço específico
docker-compose restart api
docker-compose restart frontend
```

### Build e Imagens

```bash
# Build das imagens
docker-compose build

# Build com cache desabilitado
docker-compose build --no-cache

# Ver imagens
docker images

# Remover imagem
docker rmi <image-id>
```

### Exec e Shell

```bash
# Executar comando na API
docker-compose exec api ruby seed.rb

# Acessar shell da API
docker-compose exec api sh

# Acessar shell do Frontend
docker-compose exec frontend sh

# Ver estrutura de arquivos
docker-compose exec api ls -la
```

### Dados e Volumes

```bash
# Ver volumes
docker volume ls

# Inspecionar volume
docker volume inspect <volume-name>

# Remover volumes não utilizados
docker volume prune
```

## 🔍 Healthcheck

Os serviços têm verificações de saúde automáticas:

```bash
# API (verifica endpoint)
curl http://localhost:4567/api/atracao

# Frontend
curl http://localhost:3000
```

Se algum falhar, o container reiniciará automaticamente.

## 🧪 Testes

### Testar API

```bash
# Listar atrações
curl http://localhost:4567/api/atracao

# Listar visitantes
curl http://localhost:4567/api/visitante

# Listar reservas
curl http://localhost:4567/api/reserva

# Criar visitante
curl -X POST http://localhost:4567/api/visitante \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Docker Test",
    "cpf": "999.999.999-99",
    "data_nascimento": "2000-01-01",
    "email": "docker@test.com",
    "tipo_ingresso": "normal"
  }'
```

### Carregar dados de teste

```bash
# Dentro do container API
docker-compose exec api ruby seed.rb
```

## 📝 Arquivos de Configuração

### Dockerfile (API)
- Baseado em: ruby:2.7-slim
- Instala: gems (bundle)
- Expõe: porta 4567
- Comando: `ruby app.rb -o 0.0.0.0`

### frontend/Dockerfile
- Build multi-stage
- Stage 1: Build com node:18-alpine
- Stage 2: Serve com node:18-alpine
- Expõe: porta 3000
- Comando: `serve -s dist -l 3000`

### docker-compose.yml
- **Rede**: parque-network (bridge)
- **Health checks**: Ambos os serviços
- **Dependência**: Frontend aguarda API estar saudável
- **Volumes**: Dados persistentes
- **Portas**: 3000 (frontend), 4567 (api)

### .dockerignore
- Exclui: node_modules, .git, dist, etc.
- Reduz tamanho das imagens

## 🏗️ Estrutura Docker

```
┌─────────────────────────────────┐
│      Docker Compose (v3.8)      │
├─────────────────────────────────┤
│      parque-network             │
│  ┌──────────────┐ ┌──────────┐  │
│  │   API        │ │ Frontend │  │
│  │   (ruby)     │ │ (node)   │  │
│  │   4567:4567  │ │ 3000:3000│  │
│  └──────────────┘ └──────────┘  │
│       ↓              ↓            │
│   health  ←──────  depends_on    │
└─────────────────────────────────┘
```

## ⚙️ Variáveis de Ambiente

### API
```
RACK_ENV=development
```

### Frontend
```
VITE_API_URL=http://api:4567
```

Para produção, modifique em docker-compose.yml:
```yaml
environment:
  - RACK_ENV=production
  - VITE_API_URL=https://api.seu-dominio.com
```

## 🔒 Segurança

### Para Produção

1. **Remova volumes do compose:**
   ```yaml
   volumes:
     # Remover volumes de desenvolvimento
   ```

2. **Use .env para secrets:**
   ```bash
   # .env
   DB_PASSWORD=seu-senha-segura
   API_KEY=sua-chave-secreta
   ```

3. **Atualize Dockerfile:**
   ```dockerfile
   # API
   RUN bundle install --without development test
   ```

4. **Use registry privado:**
   ```bash
   docker tag parque-api seu-registry/parque-api:1.0.0
   docker push seu-registry/parque-api:1.0.0
   ```

## 🆘 Troubleshooting

### Erro: "Cannot connect to Docker daemon"
```bash
# Inicie o Docker
# Windows: Abra Docker Desktop
# Linux: sudo systemctl start docker
```

### Erro: "Port 3000 already in use"
```bash
# Altere em docker-compose.yml
ports:
  - "3001:3000"  # ou outra porta
```

### Erro: "Health check failing"
```bash
# Verifique logs
docker-compose logs api

# Espere um pouco mais (primeira vez é lenta)
sleep 60
docker-compose ps
```

### Erro: "Cannot find module"
```bash
# Reconstrua sem cache
docker-compose build --no-cache
docker-compose down -v
docker-compose up -d
```

### Remover tudo e começar do zero
```bash
# Para e remove tudo
docker-compose down -v

# Remove imagens
docker-compose down -v --rmi all

# Reconstrói
docker-compose build
docker-compose up -d
```

## 📊 Performance

### Verificar uso de recursos
```bash
docker stats
```

### Otimizar imagens

```bash
# API - Use alpine baseimage (já está)
# Frontend - Multi-stage já otimizado

# Ver tamanho das imagens
docker images --format "table {{.Repository}}\t{{.Size}}"
```

## 🚀 Deploy

### Para AWS ECS
```bash
# Push para ECR
aws ecr get-login-password | docker login --username AWS --password-stdin <account>.dkr.ecr.<region>.amazonaws.com

docker tag parque-api:latest <account>.dkr.ecr.<region>.amazonaws.com/parque-api:latest
docker push <account>.dkr.ecr.<region>.amazonaws.com/parque-api:latest
```

### Para Docker Hub
```bash
docker login
docker tag parque-api:latest seu-usuario/parque-api:1.0.0
docker push seu-usuario/parque-api:1.0.0
```

### Para Kubernetes
```bash
# Gerar manifests a partir do compose
kompose convert -f docker-compose.yml -o k8s/

# Deploy
kubectl apply -f k8s/
```

## 📚 Recursos

- [Docker Docs](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [Best Practices](https://docs.docker.com/develop/dev-best-practices/)

---

**Versão**: 1.0.0
**Última atualização**: Maio 2026
