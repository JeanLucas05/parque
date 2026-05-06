FROM ruby:2.7-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    libpq-dev \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Copia todos os arquivos necessários
COPY api/Gemfile ./
COPY api/ ./
COPY seed.rb ./
COPY disney/ ./disney/

# Instala gems
RUN bundle install

EXPOSE 4567

# Script de inicialização: aguarda banco, executa seed e inicia API
CMD sh -c '\
  echo "Aguardando PostgreSQL..."; \
  for i in 1 2 3 4 5 6 7 8 9 10; do \
    if pg_isready -h postgres -U disney_user -d disney_db 2>/dev/null; then \
      echo "PostgreSQL está pronto!"; \
      break; \
    fi; \
    echo "Tentativa $i/10..."; \
    sleep 2; \
  done; \
  echo "Executando seed..."; \
  ruby seed.rb; \
  echo "Iniciando API..."; \
  ruby app.rb -o 0.0.0.0 \
'
