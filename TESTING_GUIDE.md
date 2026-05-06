# 🧪 Guia de Testes - Sistema de Reservas

## ✅ Checklist de Funcionalidades

### Frontend - Componentes

- [ ] MenuPrincipal carrega corretamente
- [ ] Botões navegam para os componentes certos
- [ ] Design é responsivo (mobile/tablet/desktop)
- [ ] Cores e estilos são consistentes

### Frontend - Portal Visitante

- [ ] Login funciona com ID válido (1-5)
- [ ] Erro aparece com ID inválido
- [ ] Listagem de atrações carrega
- [ ] Valida idade mínima corretamente
- [ ] Pode fazer uma reserva
- [ ] Reserva aparece em "Minhas Reservas"
- [ ] Logout funciona
- [ ] Pode fazer novo login

### Frontend - Painel Administrador

- [ ] Aba "Atrações" lista todas
- [ ] Aba "Visitantes" mostra tabela
- [ ] Aba "Filas" mostra fila por atração
- [ ] Aba "Estatísticas" mostra dados
- [ ] Botão "Atualizar" recarrega dados
- [ ] Todas as abas navegam corretamente

### Frontend - Cadastros

- [ ] Formulário de Atração carrega
- [ ] Pode criar nova atração
- [ ] Validação de campos obrigatórios
- [ ] Mensagem de sucesso aparece
- [ ] Formulário de Visitante carrega
- [ ] Pode criar novo visitante
- [ ] Dados aparecem na administração

### API - Atrações

- [ ] GET /api/atracao retorna lista
- [ ] GET /api/atracao/:id retorna atração
- [ ] POST /api/atracao cria nova atração
- [ ] Resposta tem structure correto

### API - Visitantes

- [ ] GET /api/visitante retorna lista
- [ ] GET /api/visitante/:id retorna visitante
- [ ] POST /api/visitante cria novo visitante
- [ ] Cálculo de idade funciona

### API - Reservas

- [ ] GET /api/reserva retorna lista
- [ ] GET /api/reserva/visitante/:id retorna suas reservas
- [ ] GET /api/reserva/atracao/:id retorna reservas da atração
- [ ] POST /api/reserva cria nova reserva
- [ ] Validação de idade mínima funciona
- [ ] Prioridade por ingresso funciona

### API - Fila Virtual

- [ ] GET /api/fila/:id retorna fila
- [ ] Posição é calculada corretamente
- [ ] Ordenação por tipo de ingresso funciona

### API - Estatísticas

- [ ] GET /api/estatistica/diario retorna stats
- [ ] GET /api/estatistica/periodo funciona

## 🚀 Procedimento de Testes Manuais

### Setup Inicial

```bash
# Terminal 1 - Na raiz do projeto
./setup.sh

# Aguarde instalação completar
# Se der erro, instale manualmente:

# Terminal 1 - API
cd api
bundle install
ruby app.rb

# Terminal 2 - Frontend
cd frontend
npm install
npm run dev
```

### Teste 1: Menu Principal
1. Acesse http://localhost:3000
2. ✅ Verifique se carrega a página
3. ✅ Clique em cada botão
4. ✅ Volte ao menu cada vez

### Teste 2: Login como Visitante
1. Clique "Portal do Visitante"
2. Digite ID: **1**
3. ✅ Deve mostrar "Bem-vindo, Maria Silva!"
4. ✅ Veja as atrações listadas
5. Tente ID: **999**
6. ✅ Deve mostrar erro "Visitante não encontrado"

### Teste 3: Fazer Reserva
1. Logado como visitante (ID 1)
2. Clique em "Reservar" em uma atração
3. Selecione um horário
4. Clique "Confirmar Reserva"
5. ✅ Veja mensagem de sucesso
6. Clique em "Minhas Reservas"
7. ✅ Veja sua reserva lá

### Teste 4: Validação de Idade
1. Logado como visitante (ID 1 - 25 anos)
2. Procure atração com idade_minima > 25
3. ✅ Botão deve estar desabilitado
4. ✅ Ícone ❌ deve aparecer

### Teste 5: Painel Administrador
1. Clique "Menu Administrador"
2. Aba "Atrações":
   - ✅ Lista todas as atrações
   - ✅ Clique "Ver Fila" em uma
   - ✅ Veja a ordem de espera
3. Aba "Visitantes":
   - ✅ Tabela com todos
   - ✅ Mostra tipos de ingresso em cores
4. Aba "Filas":
   - ✅ Mostra fila ordenada
5. Aba "Estatísticas":
   - ✅ Mostra total de reservas
   - ✅ Atração mais disputada
   - ✅ Visitante mais ativo

### Teste 6: Cadastros
1. Clique "Cadastros"
2. Aba "Cadastrar Atração":
   - Nome: "Test Mountain"
   - Tipo: "Montanha-russa"
   - Capacidade: 40
   - Idade Mínima: 8
   - Horários: "15:00,16:00,17:00"
   - Passes: "vip"
   - ✅ Clique "Criar Atração"
   - ✅ Veja mensagem de sucesso
3. Aba "Cadastrar Visitante":
   - Nome: "João Teste"
   - CPF: "123.456.789-00"
   - Data: 2000-01-01
   - Email: "teste@email.com"
   - Tipo: "VIP"
   - ✅ Clique "Criar Visitante"
   - ✅ Veja mensagem de sucesso

### Teste 7: Testes com cURL (API)

```bash
# Listar atrações
curl http://localhost:4567/api/atracao

# Obter atração específica
curl http://localhost:4567/api/atracao/1

# Listar visitantes
curl http://localhost:4567/api/visitante

# Obter visitante específico
curl http://localhost:4567/api/visitante/1

# Listar reservas
curl http://localhost:4567/api/reserva

# Fila de uma atração
curl http://localhost:4567/api/fila/1

# Estatísticas
curl http://localhost:4567/api/estatistica/diario

# Criar visitante
curl -X POST http://localhost:4567/api/visitante \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Teste User",
    "cpf": "987.654.321-00",
    "data_nascimento": "2000-05-15",
    "email": "teste@test.com",
    "tipo_ingresso": "normal"
  }'
```

## 🐛 Teste de Performance

1. Abra DevTools (F12)
2. Vá para "Performance"
3. Clique em "Record"
4. Navegar por todos os componentes
5. Pause a gravação
6. ✅ Verifique se há muitos red frames
7. ✅ FPS deve estar acima de 30

## 📊 Teste de Responsividade

1. Abra DevTools (F12)
2. Clique no ícone de celular/tablet
3. Teste os dispositivos:
   - iPhone SE (375px)
   - iPad (768px)
   - Desktop (1920px)
4. ✅ Componentes devem se adaptar
5. ✅ Nada deve ficar truncado

## 🔍 Teste de Acessibilidade

1. Todos os botões têm labels?
2. Contraste de cores é suficiente?
3. Formulários têm labels?
4. Mensagens de erro são claras?
5. Pode navegar com Tab?

---

**Total de Testes**: 40+ cenários
**Tempo Estimado**: 30-45 minutos
