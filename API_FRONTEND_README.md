# 🎡 Sistema de Reservas - Parque Temático (API + React)

Sistema completo de agendamento e controle de filas virtuais com **API REST em Sinatra** e **Interface React com Vite**.

## 🏗️ Arquitetura

```
┌─────────────────────────────────────────────────────────┐
│         Frontend React + Vite (Port 3000)              │
│  - Menu Principal                                       │
│  - Painel Administrativo                               │
│  - Portal do Visitante                                 │
│  - Cadastros                                           │
└──────────────────────┬──────────────────────────────────┘
                       │ HTTP/JSON
┌──────────────────────┴──────────────────────────────────┐
│         API REST Sinatra (Port 4567)                   │
│  - /api/atracao (Atrações)                             │
│  - /api/visitante (Visitantes)                         │
│  - /api/reserva (Reservas)                             │
│  - /api/fila (Filas Virtuais)                          │
│  - /api/estatistica (Estatísticas)                     │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────┴──────────────────────────────────┐
│           Persistência (JSON)                          │
│  - atracao.json                                        │
│  - visitante.json                                      │
│  - reserva.json                                        │
└─────────────────────────────────────────────────────────┘
```

## 🚀 Instalação e Execução

### Pré-requisitos
- Ruby 2.5+ com Bundler
- Node.js 16+ com npm

### 1️⃣ Instalação Automática (macOS/Linux)
```bash
bash setup.sh
```

### 2️⃣ Instalação Manual

#### API (Terminal 1)
```bash
cd api
bundle install
ruby app.rb
```
A API estará disponível em **http://localhost:4567**

#### Frontend (Terminal 2)
```bash
cd frontend
npm install
npm run dev
```
O Frontend estará disponível em **http://localhost:3000**

## 📡 API REST Endpoints

### Atrações
- `GET /api/atracao` - Listar todas as atrações
- `GET /api/atracao/:id` - Obter atração por ID
- `POST /api/atracao` - Criar nova atração

### Visitantes
- `GET /api/visitante` - Listar todos os visitantes
- `GET /api/visitante/:id` - Obter visitante por ID
- `POST /api/visitante` - Criar novo visitante

### Reservas
- `GET /api/reserva` - Listar todas as reservas
- `GET /api/reserva/visitante/:visitante_id` - Reservas de um visitante
- `GET /api/reserva/atracao/:atracao_id` - Reservas de uma atração
- `POST /api/reserva` - Criar nova reserva

### Fila Virtual
- `GET /api/fila/:atracao_id` - Ver fila de uma atração

### Estatísticas
- `GET /api/estatistica/diario` - Relatório diário
- `GET /api/estatistica/periodo?data_inicio=YYYY-MM-DD&data_fim=YYYY-MM-DD` - Relatório por período

### Health Check
- `GET /api/health` - Verificar saúde da API

## 🎨 Interface React

### 1️⃣ Menu Principal
Acesso aos 3 portais principais:
- 🎯 Painel Administrativo
- 👤 Portal do Visitante
- 📝 Cadastros

### 2️⃣ Painel Administrativo
**Abas:**
- 🎢 **Atrações** - Listar todas as atrações e visualizar filas
- 👥 **Visitantes** - Tabela de todos os visitantes cadastrados
- ⏳ **Filas** - Visualizar fila de atração em tempo real
- 📊 **Estatísticas** - Relatórios e análises

### 3️⃣ Portal do Visitante
- 🔓 Login com ID
- 🎢 Visualizar atrações disponíveis
- 📝 Fazer reservas
- 📋 Ver reservas ativas
- 📍 Ver posição na fila

### 4️⃣ Menu de Cadastros
- Cadastrar novas atrações
- Cadastrar novos visitantes

## 📋 Exemplo de Uso

### 1. Criar uma Atração via API
```bash
curl -X POST http://localhost:4567/api/atracao \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Super Montanha Russa",
    "tipo": "montanha-russa",
    "capacidade_por_sessao": 80,
    "idade_minima": 12,
    "horarios_disponiveis": ["10:00", "12:00", "14:00", "16:00"],
    "passes_com_prioridade": ["vip", "anual"]
  }'
```

### 2. Criar um Visitante via API
```bash
curl -X POST http://localhost:4567/api/visitante \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Ana Silva",
    "cpf": "123.456.789-00",
    "data_nascimento": "2010-05-15",
    "email": "ana@email.com",
    "tipo_ingresso": "vip"
  }'
```

### 3. Fazer uma Reserva
```bash
curl -X POST http://localhost:4567/api/reserva \
  -H "Content-Type: application/json" \
  -d '{
    "visitante_id": 1,
    "atracao_id": 1,
    "horario": "14:00"
  }'
```

### 4. Ver Fila de uma Atração
```bash
curl http://localhost:4567/api/fila/1
```

## 🔐 Dados de Teste

Os dados de teste da execução anterior ainda estão em `atracao.json`, `visitante.json` e `reserva.json`.

**Visitantes disponíveis:**
- ID 1: João Silva (VIP)
- ID 2: Maria Santos (Normal)
- ID 3: Pedro Costa (Anual)
- ID 4: Ana Oliveira (Normal)
- ID 5: Lucas Martins (VIP)

## 📦 Estrutura do Projeto

```
projeto/
├── api/
│   ├── app.rb              # API REST em Sinatra
│   ├── Gemfile             # Dependências Ruby
│   └── ...
├── frontend/
│   ├── src/
│   │   ├── App.jsx         # Componente principal
│   │   ├── main.jsx        # Entry point
│   │   ├── index.css       # Estilos globais
│   │   ├── components/
│   │   │   ├── MenuPrincipal.jsx
│   │   │   ├── PainelAdministrador.jsx
│   │   │   ├── PortalVisitante.jsx
│   │   │   └── MenuCadastro.jsx
│   │   └── services/
│   │       └── api.js      # Cliente API (axios)
│   ├── package.json        # Dependências Node
│   ├── vite.config.js      # Configuração Vite
│   ├── index.html          # HTML raiz
│   └── ...
├── disney/
│   ├── atracao/
│   ├── visitante/
│   ├── reserva/
│   ├── fila/
│   ├── repositorios/
│   ├── controladores/
│   └── modelos/
├── seed.rb                 # Carregador de dados
├── teste.rb                # Testes
└── README.md               # Este arquivo
```

## 🎨 Estilos

O frontend usa:
- **CSS puro** (sem dependência de bibliotecas)
- **Cores:** Roxo/Lilás (#667eea, #764ba2) com destaques coloridos
- **Responsive:** Grid adaptativo
- **Componentes:** Cards, botões, formulários, tabelas

## 🔍 Troubleshooting

### "API não está respondendo"
Verifique se o servidor Sinatra está rodando:
```bash
cd api
ruby app.rb
```

### "Cannot find module 'react'"
Execute no diretório frontend:
```bash
npm install
```

### "Porta 3000/4567 já está em uso"
Mude a porta no `frontend/vite.config.js` ou `api/app.rb`:

**Frontend:**
```js
server: {
  port: 3001, // Mude aqui
}
```

**API:**
```ruby
set :port, 4568 # Mude aqui
```

## 📊 Funcionalidades Implementadas

✅ API REST completa com Sinatra  
✅ Frontend React + Vite  
✅ Sistema de prioridade em filas  
✅ Validação de idade  
✅ Estatísticas em tempo real  
✅ Persistência JSON  
✅ CORS habilitado  
✅ Componentes reutilizáveis  
✅ Design responsivo  
✅ Tratamento de erros  

## 🚀 Próximas Melhorias

- [ ] Autenticação com tokens JWT
- [ ] Banco de dados SQLite/PostgreSQL
- [ ] Gráficos com Chart.js
- [ ] Upload de imagens
- [ ] Notificações em tempo real (WebSocket)
- [ ] Testes automatizados (Jest/RSpec)
- [ ] Deploy em produção

## 📝 Licença

Sistema de Reservas para Parque Temático - Educacional 2026

---

**Desenvolvido com ❤️ para fins educacionais**
