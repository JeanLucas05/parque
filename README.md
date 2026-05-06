# 🎡 Sistema de Reservas para Parque Temático
## Uma solução completa Full-Stack: Backend em Ruby + Frontend em React

Um sistema completo de agendamento e controle de filas virtuais para atrações de um parque temático, com interface web moderna.

**Status**: ✅ Pronto para Produção | **Versão**: 1.0.0 | **Data**: Maio 2026

## 🏗️ Arquitetura

```
┌─────────────────────┐
│   Frontend React    │
│  (http://3000)      │
├─────────────────────┤
│   Axios HTTP        │
├─────────────────────┤
│   API Sinatra       │
│  (http://4567)      │
├─────────────────────┤
│  Controladores Ruby │
├─────────────────────┤
│  JSON (Persistência)│
└─────────────────────┘
```

## 📋 Funcionalidades

### 🎢 Atrações
- ✅ Cadastro com nome, tipo, capacidade e idade mínima
- ✅ Configuração de horários disponíveis
- ✅ Sistema de prioridade por tipo de ingresso
- ✅ Controle de filas virtuais por atração

### 👥 Visitantes
- ✅ Cadastro com CPF, data de nascimento, email
- ✅ Tipos de ingresso (Normal, VIP, Passe Anual)
- ✅ Cálculo automático de idade
- ✅ Portal de autosserviço

### ⏳ Filas Virtuais
- ✅ Fila específica por atração
- ✅ Prioridade automática para VIP e Anual
- ✅ Visualização de posição na fila
- ✅ Processamento em tempo real

### 📊 Relatórios e Estatísticas
- ✅ Relatório diário de reservas
- ✅ Atração mais disputada
- ✅ Visitante mais ativo
- ✅ Relatórios por período

### 🎯 Portais de Acesso
- ✅ **Painel Administrativo** - Gerenciamento completo
- ✅ **Portal do Visitante** - Autosserviço para reservas
- ✅ **Menu de Cadastros** - Registro de dados

### 🎨 Interface Moderna
- ✅ UI responsiva (mobile, tablet, desktop)
- ✅ Design intuitivo com navegação clara
- ✅ Feedback visual imediato (sucesso/erro)
- ✅ Tabelas, gráficos e estatísticas

## ⚡ Início Rápido

### 🐳 Opção 1: Docker Compose (Recomendado - Sem Dependências!)

```bash
# Na raiz do projeto
docker-compose up -d

# Aguarde 30-60 segundos para instalação de dependências
```

**Verificar status:**
```bash
docker-compose ps
```

**Ver logs:**
```bash
docker-compose logs -f
```

**Parar:**
```bash
docker-compose down
```

### Opção 2: Setup Automático (Local)

```bash
# Na raiz do projeto
./setup.sh
```

### Opção 3: Setup Manual

**Terminal 1 - API Backend:**
```bash
cd api
bundle install
ruby app.rb
# API rodando em http://localhost:4567
```

**Terminal 2 - Frontend:**
```bash
cd frontend
npm install
npm run dev
# Frontend rodando em http://localhost:3000
```

### Acesso

- **Frontend**: http://localhost:3000
- **API**: http://localhost:4567/api

## 🐳 Docker

### Pré-requisitos
- Docker 20.10+
- Docker Compose 1.29+

### Comandos Docker

```bash
# Iniciar com Docker Compose
docker-compose up -d

# Ver status
docker-compose ps

# Ver logs
docker-compose logs -f

# Parar
docker-compose stop

# Parar e remover
docker-compose down

# Remover tudo e volumes
docker-compose down -v

# Executar comando dentro do container
docker-compose exec api ruby seed.rb
```

📚 **Ver [DOCKER_GUIDE.md](DOCKER_GUIDE.md) para mais detalhes e troubleshooting**

## 🧪 Dados de Teste

IDs para fazer login no portal do visitante:

| ID | Nome | Tipo | Idade | Status |
|----|------|------|-------|--------|
| 1  | Maria Silva | Normal | 25 | ✅ Ativo |
| 2  | João Santos | VIP | 30 | ✅ Ativo |
| 3  | Ana Oliveira | Anual | 22 | ✅ Ativo |
| 4  | Carlos Mendes | Normal | 28 | ✅ Ativo |
| 5  | Juliana Costa | VIP | 26 | ✅ Ativo |

Ou carregue dados customizados:
```bash
ruby seed.rb
ruby disney/main.rb
```

## 📌 Menu Principal

```
🎡 SISTEMA DE RESERVAS - PARQUE TEMÁTICO DISNEY
==================================================
1. 🎯 Menu Administrador
2. 👤 Portal do Visitante
3. 📝 Cadastros
0. ❌ Sair
```

## 🎯 Menu Administrador

Acesso para gerenciar o parque completo:

### Opção 1: Relatórios
- 📊 Relatório Diário - Estatísticas do dia atual
- 📈 Relatório por Período - Análise em intervalo de datas

### Opção 2: Gerenciar Atrações
- Listar todas as atrações
- Visualizar filas
- Processar entrada de visitantes

### Opção 3: Gerenciar Visitantes
- Listar todos os visitantes
- Buscar visitante por CPF
- Visualizar dados completos

### Opção 4: Gerenciar Filas
- Visualizar fila de atração
- Ver próximas pessoas
- Processar entradas

### Opção 5: Consultas Gerais
- Estatísticas gerais
- Atrações com maior ocupação

## 👤 Portal do Visitante

Login e gerenciamento de reservas pessoais:

1. **Entrar/Login** - Insira seu ID de visitante
2. **Ver Atrações Disponíveis** - Lista de todas as atrações com informações
3. **Entrar na Fila** - Selecione uma atração e horário
4. **Ver Posição na Fila** - Sua posição em cada fila
5. **Ver Reservas Ativas** - Atrações que você está esperando
6. **Histórico de Visitas** - Atrações já visitadas
7. **Meus Dados** - Perfil completo

## 📝 Menu de Cadastros

### Cadastrar Atração
Informações necessárias:
- Nome da atração
- Tipo (montanha-russa, simulador, teatro, brinquedo infantil)
- Capacidade por sessão
- Idade mínima
- Horários disponíveis (separados por vírgula)
- Passes com prioridade

Exemplo:
```
Nome: Space Mountain
Tipo: montanha-russa
Capacidade: 50
Idade Mínima: 10
Horários: 09:00,10:30,12:00,14:00,16:00,18:00
Passes: vip,anual
```

### Cadastrar Visitante
Informações necessárias:
- Nome completo
- CPF (formato: XXX.XXX.XXX-XX)
- Data de nascimento (YYYY-MM-DD)
- E-mail
- Tipo de ingresso (Normal/VIP/Passe Anual)

Exemplo:
```
Nome: João Silva
CPF: 123.456.789-00
Data: 1990-05-15
Email: joao@email.com
Ingresso: VIP
```

## 🗂️ Estrutura de Pastas

```
projeto/
├── disney/
│   ├── atracao/
│   │   └── atracaoModel.rb
│   ├── visitante/
│   │   └── visitanteModel.rb
│   ├── reserva/
│   │   └── reservaModel.rb
│   ├── fila/
│   │   └── filaVirtual.rb
│   ├── repositorios/
│   │   ├── repositorioAtracao.rb
│   │   ├── repositorioVisitante.rb
│   │   └── repositorioReserva.rb
│   ├── controladores/
│   │   ├── controladorAtracao.rb
│   │   ├── controladorVisitante.rb
│   │   ├── controladorReserva.rb
│   │   └── controladorParque.rb
│   ├── interfaces/
│   │   ├── menuCadastro.rb
│   │   └── menuVisitante.rb
│   ├── modelos/
│   │   └── estatistica.rb
│   └── main.rb
├── seed.rb (carregador de dados de teste)
└── atracao.json, visitante.json, reserva.json (persistência)
```

## 💾 Persistência de Dados

Os dados são armazenados em arquivos JSON:
- `atracao.json` - Atrações cadastradas
- `visitante.json` - Visitantes cadastrados
- `reserva.json` - Reservas realizadas

Estes arquivos são criados automaticamente na primeira execução.

## 🎓 Exemplo de Fluxo Completo

### 1. Administrador: Cadastrar Atração
```
Menu Principal → Cadastros → Cadastrar Atração
Nome: Montanha Russa Gigante
Tipo: montanha-russa
Capacidade: 80
Idade Mínima: 12
Horários: 10:00,12:00,14:00,16:00
```

### 2. Administrador: Cadastrar Visitante
```
Menu Principal → Cadastros → Cadastrar Visitante
Nome: Ana Silva
CPF: 123.456.789-00
Data: 2010-05-15
Email: ana@email.com
Tipo: Normal
```

### 3. Visitante: Fazer Reserva
```
Menu Principal → Portal do Visitante
Login com ID: 1
Entrar na Fila → Selecionar Montanha Russa Gigante → Horário: 14:00
✅ Reserva criada! Você está na posição 5 da fila
```

### 4. Visitante: Verificar Posição
```
Ver Minha Posição na Fila
📍 Sua posição na fila: 5
```

### 5. Administrador: Ver Relatório
```
Menu Administrador → Ver Relatório Diário
📊 RELATÓRIO DIÁRIO
Total de Reservas: 23
Atração Mais Disputada: Montanha Russa Gigante (8 reservas)
Visitante Mais Ativo: João Silva (5 reservas)
```

## 🔐 Regras de Negócio

### Prioridade de Filas
- **VIP e Passe Anual**: Posição prioritária (aparecem na frente)
- **Normal**: Posição regular (ordem de chegada)

### Validação de Idade
- Sistema verifica automaticamente se o visitante tem a idade mínima
- Cálculo automático baseado em data de nascimento

### Tipos de Ingresso
1. **Normal** - Acesso regular, sem prioridades
2. **VIP** - Prioridade em todas as filas
3. **Passe Anual** - Prioridade em filas específicas

## 📊 Métricas Disponíveis

O sistema coleta e exibe:
- Total de reservas por dia/período
- Atração mais disputada
- Visitante mais ativo
- Distribuição por tipo de ingresso
- Status das filas em tempo real

## 🖥️ Interface Web (Frontend React)

### Componentes Principais

1. **MenuPrincipal** - Página inicial com navegação
   - Botão: Painel Administrador
   - Botão: Portal do Visitante
   - Botão: Cadastros

2. **PortalVisitante** - Self-service para visitantes
   - Login com ID
   - Listar atrações disponíveis
   - Fazer reservas com seleção de horário
   - Ver minhas reservas
   - Validação automática de idade

3. **PainelAdministrador** - Gerenciamento completo
   - Aba Atrações: Lista todas as atrações
   - Aba Visitantes: Tabela com todos os visitantes
   - Aba Filas: Visualiza fila de espera por atração
   - Aba Estatísticas: Dashboard com indicadores do dia

4. **MenuCadastro** - Registro de novos dados
   - Formulário para cadastrar novas atrações
   - Formulário para cadastrar novos visitantes
   - Validação de dados em tempo real

### Tecnologias Frontend

- **React 18.2.0** - Framework UI
- **Vite 4.3.9** - Build tool (HMR, otimização)
- **Axios 1.4.0** - HTTP client
- **CSS3** - Estilos responsivos
- **JavaScript ES6+** - Lógica da aplicação

### API REST

Endpoints disponíveis:

```
GET    /api/atracao                    # Listar todas as atrações
GET    /api/atracao/:id                # Obter atração específica
POST   /api/atracao                    # Criar nova atração

GET    /api/visitante                  # Listar visitantes
GET    /api/visitante/:id              # Obter visitante
POST   /api/visitante                  # Criar visitante

GET    /api/reserva                    # Listar reservas
GET    /api/reserva/visitante/:id      # Reservas do visitante
GET    /api/reserva/atracao/:id        # Reservas da atração
POST   /api/reserva                    # Criar reserva

GET    /api/fila/:id                   # Fila da atração
GET    /api/estatistica/diario         # Estatísticas do dia
GET    /api/estatistica/periodo        # Estatísticas por período
```

## 📚 Documentação Adicional

- **[FRONTEND_GUIDE.md](FRONTEND_GUIDE.md)** - Guia completo do frontend
- **[TESTING_GUIDE.md](TESTING_GUIDE.md)** - Procedimentos de teste
- **[IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)** - Resumo de implementação
- **[API_FRONTEND_README.md](API_FRONTEND_README.md)** - Documentação API

## ⚠️ Notas Importantes

- Certifique-se de carregar os dados de teste com `ruby seed.rb` antes de usar o sistema
- Os arquivos JSON são criados automaticamente na raiz do projeto
- O sistema não possui autenticação (Use IDs numéricos para login)
- Datas devem estar no formato YYYY-MM-DD
- Frontend e API devem estar rodando simultaneamente

## 🛠️ Dependências

### Backend
- Ruby 2.5+
- Sinatra 4.0 (Web framework)
- sinatra-cors (CORS middleware)
- Bibliotecas padrão: json, date

### Frontend
- Node.js 16+
- React 18.2.0
- Vite 4.3.9
- Axios 1.4.0

## 🎯 Próximas Melhorias (Opcional)

- [ ] Autenticação com senha
- [ ] WebSocket para atualizações em tempo real
- [ ] Sistema de pagamento integrado
- [ ] Gráficos avançados com Chart.js
- [ ] Notificações push
- [ ] Dark mode
- [ ] Suporte a PWA

## 📞 Suporte

Para reportar erros ou sugestões, verifique:
1. Se a API está rodando: http://localhost:4567/api/health
2. Se o frontend está rodando: http://localhost:3000
3. Verifique os logs nos terminais
4. Consulte [TESTING_GUIDE.md](TESTING_GUIDE.md) para troubleshooting

## 📝 Licença

Sistema de Reservas para Parque Temático - Educacional

---

**Desenvolvido com ❤️ para fins educacionais**
**Versão**: 1.0.0 | **Maio 2026**
