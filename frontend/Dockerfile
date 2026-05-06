# Frontend - Sistema de Reservas Parque Temático
FROM node:18-alpine as builder

WORKDIR /app

ARG VITE_API_URL=http://localhost:4567
ENV VITE_API_URL=$VITE_API_URL

# Copiar package files
COPY package.json package-lock.json ./

# Instalar dependências
RUN npm ci

# Copiar código
COPY . .

# Build
RUN npm run build

# Serve - multi-stage
FROM node:18-alpine

WORKDIR /app

# Instalar serve para servir a aplicação
RUN npm install -g serve

# Copiar build do stage anterior
COPY --from=builder /app/dist ./dist

# Expor porta
EXPOSE 3000

# Comando para servir
CMD ["serve", "-s", "dist", "-l", "3000"]
