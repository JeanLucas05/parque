# 🐳 Docker Deployment Guide

## 📋 Sumário
1. [Desenvolvimento](#desenvolvimento)
2. [Produção](#produção)
3. [CI/CD](#cicd)
4. [Troubleshooting](#troubleshooting)

## 🚀 Desenvolvimento

### Iniciação Rápida

```bash
# Com Make
make up
make logs

# Ou com Docker Compose direto
docker-compose up -d
docker-compose logs -f
```

### Parar

```bash
# Com Make
make down

# Ou com Docker Compose
docker-compose down
```

### Acessar Shell

```bash
# API
make shell-api
# ou
docker-compose exec api sh

# Frontend
make shell-front
# ou
docker-compose exec frontend sh
```

### Recarregar Dados de Teste

```bash
make seed
# ou
docker-compose exec api ruby seed.rb
```

## 🏭 Produção

### Build para Produção

```bash
# Build otimizado
docker build -f Dockerfile.prod -t parque-api:1.0.0 .
docker build -f frontend/Dockerfile.prod -t parque-frontend:1.0.0 ./frontend
```

### Executar em Produção

```bash
# Usando docker-compose.prod.yml
docker-compose -f docker-compose.prod.yml up -d

# Ou com Make
make prod
```

### Variáveis de Ambiente

Crie um arquivo `.env`:

```bash
cp .env.example .env
```

Edite conforme necessário:

```
RACK_ENV=production
VITE_API_URL=https://api.seu-dominio.com
```

### Verificar Status

```bash
make prod
make status
make logs
```

### Parar Produção

```bash
make prod-down
```

## 🔄 CI/CD

### GitHub Actions

O workflow está em `.github/workflows/docker.yml`

**Ações automáticas:**
- Build de imagens em cada push
- Push para container registry (GHCR)
- Testes automáticos
- Health checks

### Build Manual

```bash
# Build sem cache (para CI)
docker-compose build --no-cache

# Build com progresso detalhado
docker-compose build --progress=plain
```

### Push para Registry

```bash
# Fazer login
docker login ghcr.io

# Tag
docker tag parque-api:latest ghcr.io/seu-usuario/parque-api:latest

# Push
docker push ghcr.io/seu-usuario/parque-api:latest
```

## 🐳 Estrutura Docker

### Dockerfile (API)
- **Base**: ruby:2.7-slim
- **Tamanho**: ~500MB
- **Versão Prod**: Dockerfile.prod (~300MB com otimizações)

### frontend/Dockerfile
- **Build**: node:18-alpine (multi-stage)
- **Serve**: node:18-alpine
- **Tamanho**: ~100MB (Stage 1), ~50MB (Stage 2)

### docker-compose.yml
- **Dev**: Volumes para hot-reload
- **Health checks**: Ambos os serviços
- **Network**: Bridge interno

### docker-compose.prod.yml
- **Restart**: always
- **Logging**: JSON file (rotação)
- **Health checks**: Mais agressivos
- **Sem volumes** do código

## 🧪 Testes

### Health Checks

```bash
# API
curl http://localhost:4567/api/atracao

# Frontend
curl http://localhost:3000
```

### Com Make

```bash
make test
```

### Logs

```bash
# Todos os logs
docker-compose logs -f

# Apenas API
docker-compose logs -f api

# Últimas 50 linhas
docker-compose logs --tail=50
```

## 📊 Performance

### Otimizações Implementadas

1. **API**
   - Alpine slim image
   - Gems compiladas com bundle
   - Multi-stage compilation

2. **Frontend**
   - Multi-stage build
   - Build production otimizado
   - Serve otimizado

### Monitorar Uso

```bash
docker stats
```

## 🔒 Segurança

### Best Practices

1. **Usuário não-root**
   ```dockerfile
   RUN useradd -m -u 1000 appuser
   USER appuser
   ```

2. **Secrets em .env**
   ```bash
   # .env (não commitar!)
   SECRET_KEY=seu-secret
   ```

3. **Healthchecks**
   ```yaml
   healthcheck:
     test: ["CMD", "curl", "-f", "http://localhost:4567"]
     interval: 10s
   ```

4. **Logging rotacionado**
   ```yaml
   logging:
     options:
       max-size: "10m"
       max-file: "3"
   ```

## 🚀 Deploy em Cloud

### AWS ECS

```bash
# Login no ECR
aws ecr get-login-password | docker login --username AWS --password-stdin <account>.dkr.ecr.<region>.amazonaws.com

# Tag
docker tag parque-api:latest <account>.dkr.ecr.<region>.amazonaws.com/parque-api:latest

# Push
docker push <account>.dkr.ecr.<region>.amazonaws.com/parque-api:latest
```

### Google Cloud Run

```bash
# Tag
docker tag parque-frontend:latest gcr.io/<project>/parque-frontend:latest

# Push
docker push gcr.io/<project>/parque-frontend:latest
```

### Docker Hub

```bash
# Login
docker login

# Tag
docker tag parque-api:latest seu-usuario/parque-api:1.0.0

# Push
docker push seu-usuario/parque-api:1.0.0
```

### Kubernetes

```bash
# Converter para K8s
kompose convert -f docker-compose.prod.yml -o k8s/

# Deploy
kubectl apply -f k8s/
```

## 🆘 Troubleshooting

### Container não inicia

```bash
# Ver logs
docker-compose logs api

# Rebuild sem cache
docker-compose build --no-cache api

# Reiniciar
docker-compose restart api
```

### Health check falhando

```bash
# Aguardar mais tempo
docker-compose up -d --wait

# Verificar manualmente
curl -v http://localhost:4567/api/atracao

# Ver status detalhado
docker inspect --format='{{json .State.Health}}' parque-api | jq
```

### Porta em uso

```bash
# Listar processos na porta
lsof -i :3000
lsof -i :4567

# Ou alterar em docker-compose.yml
ports:
  - "3001:3000"  # Alterar porta local
```

### Volume não sincroniza

```bash
# Remover volumes
docker-compose down -v

# Reconstruir
docker-compose up -d

# Ou verificar permissões
ls -la <diretório>
chmod 755 <diretório>
```

### Memoria insuficiente

```bash
# Limpar cache
docker system prune --all --volumes

# Ver uso
docker stats
```

## 📚 Comandos Completos

```bash
# Build
docker-compose build
docker-compose build --no-cache
docker-compose build --progress=plain

# Up/Down
docker-compose up -d
docker-compose up
docker-compose down
docker-compose down -v
docker-compose down -v --rmi all

# Status
docker-compose ps
docker-compose logs
docker-compose logs -f --tail=50

# Exec
docker-compose exec api sh
docker-compose exec api ruby seed.rb
docker-compose exec frontend npm run build

# Restart
docker-compose restart
docker-compose restart api
docker-compose restart frontend

# Prune
docker system prune -f
docker volume prune -f
docker image prune -f
```

## 🎯 Checklist Deploy

- [ ] `.env` configurado
- [ ] Docker e Docker Compose instalados
- [ ] Portas 3000 e 4567 disponíveis
- [ ] `docker-compose build` bem-sucedido
- [ ] `docker-compose up -d` bem-sucedido
- [ ] Health checks passando
- [ ] Frontend acessível em http://localhost:3000
- [ ] API respondendo em http://localhost:4567/api
- [ ] Dados de teste carregados (`make seed`)
- [ ] Testes manuais passando

---

**Última atualização**: Maio 2026
**Versão**: 1.0.0
