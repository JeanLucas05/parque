# 🎡 Guia do Frontend - Sistema de Reservas de Parque Temático

## 📋 Índice
1. [Estrutura do Projeto](#estrutura-do-projeto)
2. [Componentes](#componentes)
3. [Funcionalidades](#funcionalidades)
4. [Como Usar](#como-usar)
5. [Customização](#customização)
6. [Troubleshooting](#troubleshooting)

## 🏗️ Estrutura do Projeto

```
frontend/
├── src/
│   ├── App.jsx              # Componente principal com roteamento
│   ├── index.css            # Estilos globais
│   ├── main.jsx             # Ponto de entrada
│   ├── components/
│   │   ├── MenuPrincipal.jsx        # Menu inicial
│   │   ├── PortalVisitante.jsx      # Portal do visitante
│   │   ├── PainelAdministrador.jsx  # Painel de administrador
│   │   └── MenuCadastro.jsx         # Cadastro de atrações e visitantes
│   └── services/
│       └── api.js           # Integração com a API
├── package.json
├── vite.config.js
└── index.html
```

## 🧩 Componentes

### MenuPrincipal
- **Função**: Apresenta as 3 opções principais do sistema
- **Navegação**: Admin, Visitante, Cadastros
- **Estilo**: Card grid responsivo

### PortalVisitante
- **Função**: Gerenciar reservas do visitante
- **Fluxo**:
  1. Login com ID do visitante
  2. Visualizar atrações disponíveis
  3. Fazer/visualizar reservas
- **Validações**: Idade mínima, horários disponíveis

### PainelAdministrador
- **Função**: Gerenciar sistema
- **Abas**:
  - 🎢 Atrações: lista de todas as atrações
  - 👥 Visitantes: tabela com visitantes
  - ⏳ Filas: fila virtual por atração
  - 📊 Estatísticas: dados do dia

### MenuCadastro
- **Função**: Cadastrar novos dados
- **Abas**:
  - Cadastro de Atrações
  - Cadastro de Visitantes
- **Validações**: Campos obrigatórios, formatos

## 🎯 Funcionalidades

### 1. **Gestão de Atrações**
- Listar todas as atrações
- Visualizar informações detalhadas
- Criar novas atrações
- Ver fila por atração

### 2. **Gestão de Visitantes**
- Cadastrar visitantes
- Login automático
- Tipos de ingresso: Normal, VIP, Anual
- Consulta de dados pessoais

### 3. **Sistema de Reservas**
- Reservar atração com horário
- Visualizar minhas reservas
- Validação de idade mínima
- Prioridade por tipo de ingresso

### 4. **Fila Virtual**
- Posição na fila
- Ordenação por tipo de ingresso
- Visualização do total na fila

### 5. **Estatísticas**
- Total de reservas do dia
- Atração mais disputada
- Visitante mais ativo

## 🚀 Como Usar

### Instalação e Setup

```bash
# Na raiz do projeto
./setup.sh

# Ou manualmente:

# API
cd api
bundle install
ruby app.rb

# Em outro terminal - Frontend
cd frontend
npm install
npm run dev
```

### Acesso

- **URL**: http://localhost:3000
- **API**: http://localhost:4567/api

### Fluxo de Uso

#### 👤 Como Visitante:
1. Clique em "Portal do Visitante"
2. Digite seu ID (teste com: 1, 2, 3, 4, 5)
3. Visualize as atrações disponíveis
4. Clique em "Reservar" para uma atração
5. Selecione o horário e confirme
6. Veja suas reservas ativas na aba "Minhas Reservas"

#### 🎯 Como Administrador:
1. Clique em "Menu Administrador"
2. **Atrações**: veja todas e clique "Ver Fila"
3. **Visitantes**: tabela com todos os cadastrados
4. **Filas**: visualize ordem de espera
5. **Estatísticas**: indicadores do dia
6. Clique "Atualizar" para recarregar os dados

#### 📝 Cadastros:
1. Clique em "Cadastros"
2. Escolha entre Atração ou Visitante
3. Preencha o formulário
4. Clique em "Criar"
5. Confirmação de sucesso aparecerá

## 🎨 Customização

### Cores
Edite [src/index.css](src/index.css):
```css
body {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

button.primary {
  background: #667eea;
}
```

### Endpoints da API
Edite [src/services/api.js](src/services/api.js):
```javascript
const API_BASE = 'http://localhost:4567/api'
```

### Dados de Teste
IDs de visitantes para teste:
- 1: Maria Silva (Normal)
- 2: João Santos (VIP)
- 3: Ana Oliveira (Anual)
- 4: Carlos Mendes (Normal)
- 5: Juliana Costa (VIP)

## 🔧 Troubleshooting

### "Erro ao conectar com a API"
1. Verifique se a API está rodando: `ruby app.rb`
2. Verifique a URL em [src/services/api.js](src/services/api.js)
3. Verifique CORS no backend

### "Visitante não encontrado"
1. Use um ID válido (1-5 para dados de teste)
2. Execute `ruby seed.rb` para popular os dados

### "Componente não renderiza"
1. Abra DevTools (F12)
2. Verifique console para erros
3. Verifique se todos os imports estão corretos

### Porta 3000 já em uso
```bash
npm run dev -- --port 3001
```

### Porta 4567 já em uso (API)
```bash
ruby app.rb -p 5000
# E atualize API_BASE em api.js
```

## 📦 Dependências

- **React**: 18.2.0 (UI)
- **Vite**: 4.3.9 (Build tool)
- **Axios**: 1.4.0 (HTTP client)

## 📚 Recursos Úteis

- [React Documentation](https://react.dev)
- [Vite Guide](https://vitejs.dev)
- [Axios Guide](https://axios-http.com)

---

**Última atualização**: Maio 2026
**Status**: ✅ Produção
