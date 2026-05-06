# Sistema de Reservas para Atracoes de Parque Tematico

Aplicacao full stack para cadastro de atracoes, cadastro de visitantes, reservas, filas virtuais com prioridade e painel administrativo de um parque tematico.

O projeto usa:

- Backend: Ruby + Sinatra
- Banco de dados: PostgreSQL
- Frontend: React + Vite + Axios
- Infra local: Docker Compose

## O Que o Sistema Faz

- Cadastra atracoes com nome, tipo, capacidade, horarios, idade minima e passes prioritarios.
- Cadastra visitantes com nome, CPF, data de nascimento, e-mail e tipo de ingresso.
- Permite login de visitante por e-mail e senha.
- Permite que visitantes entrem em filas/reservem horarios para atracoes.
- Calcula prioridade na fila para visitantes VIP e passe anual.
- Mostra a posicao do visitante na fila.
- Permite ao administrador atender o proximo visitante da fila.
- Mantem historico de reservas concluidas.
- Mostra metricas do dia, como total de reservas, atracao mais disputada e visitante mais ativo.
- Persiste tudo no PostgreSQL.

## Como Rodar com Docker

Recomendado para todo mundo que for testar o projeto.

### 1. Subir a aplicacao

Na raiz do projeto:

```bash
docker-compose up -d --build
```

Esse comando sobe:

- `postgres`: banco de dados PostgreSQL
- `api`: API Ruby/Sinatra
- `frontend`: aplicacao React

### 2. Acessar no navegador

Frontend:

```text
http://localhost:3000
```

API:

```text
http://localhost:4567/api
```

Health check da API:

```text
http://localhost:4567/api/health
```

### 3. Ver se tudo esta rodando

```bash
docker-compose ps
```

O esperado e que os tres containers estejam `healthy`:

- `parque-db`
- `parque-api`
- `parque-frontend`

### 4. Ver logs

```bash
docker-compose logs -f
```

Logs apenas da API:

```bash
docker-compose logs -f api
```

### 5. Parar a aplicacao

```bash
docker-compose down
```

### 6. Apagar tambem os dados do banco

Use somente quando quiser limpar tudo e recriar o banco do zero:

```bash
docker-compose down -v
```

Depois suba novamente:

```bash
docker-compose up -d --build
```

## Seed do Banco

Ao subir a API, o projeto executa automaticamente o `seed.rb`.

O seed:

- cria as tabelas se elas ainda nao existirem;
- insere/atualiza atracoes iniciais;
- insere/atualiza visitantes iniciais;
- preserva reservas existentes.

As tabelas principais ficam em:

- `atracoes`
- `visitantes`
- `reservas`

Os dados nao sao mais salvos em JSON. A persistencia correta e PostgreSQL.

## Visitantes de Teste

Use estes e-mails no Portal do Visitante. A senha padrao dos usuarios do seed e `1234`.

| E-mail | Senha | Nome | Tipo de ingresso |
| --- | --- | --- | --- |
| joao@email.com | 1234 | Joao Silva | VIP |
| maria@email.com | 1234 | Maria Santos | Normal |
| pedro@email.com | 1234 | Pedro Costa | Anual |
| ana@email.com | 1234 | Ana Oliveira | Normal |
| lucas@email.com | 1234 | Lucas Martins | VIP |

## Fluxo de Uso

### Visitante

1. Acesse `http://localhost:3000`.
2. Entre em `Portal do Visitante`.
3. Informe e-mail e senha, por exemplo `joao@email.com` e `1234`.
4. Veja as atracoes disponiveis.
5. Escolha uma atracao e um horario.
6. Confirme a reserva.
7. Abra a aba `Na Fila` para ver a posicao.
8. Depois que o administrador atender a fila, a reserva aparece no historico.

### Administrador

1. Acesse `Painel de Controle`.
2. Veja atracoes, visitantes, filas e estatisticas.
3. Em uma atracao, clique em `Ver Fila`.
4. Clique em `Atender proximo visitante` para avancar a fila.
5. A reserva atendida muda de `aguardando` para `concluida`.

### Cadastro

1. Acesse `Cadastros`.
2. Escolha cadastrar atracao ou visitante.
3. Preencha o formulario.
4. Os dados sao salvos no PostgreSQL.

## Principais Regras de Negocio

### Prioridade da Fila

- Visitantes `vip` e `anual` recebem prioridade.
- Visitantes `normal` entram depois dos prioritarios.
- Dentro do mesmo nivel de prioridade, vale a ordem de criacao da reserva.

### Idade Minima

Antes de criar uma reserva, a API verifica se o visitante tem idade suficiente para a atracao.

Se nao tiver, a reserva e recusada.

### Historico

Reservas com status `aguardando` aparecem na fila.

Quando o administrador atende o proximo visitante, a reserva vira `concluida` e passa a aparecer no historico do visitante.

## Endpoints da API

Base URL:

```text
http://localhost:4567/api
```

### Atracoes

```text
GET    /atracao
GET    /atracao/:id
POST   /atracao
```

### Visitantes

```text
GET    /visitante
GET    /visitante/:id
POST   /visitante
POST   /visitante/login
```

### Reservas

```text
GET    /reserva
GET    /reserva/visitante/:visitante_id
GET    /reserva/atracao/:atracao_id
POST   /reserva
```

### Filas

```text
GET    /fila/:atracao_id
POST   /fila/:atracao_id/avancar
```

### Estatisticas

```text
GET    /estatistica/diario
GET    /estatistica/periodo?data_inicio=YYYY-MM-DD&data_fim=YYYY-MM-DD
```

### Health

```text
GET    /health
```

## Exemplo de Requisicao

Criar uma reserva:

```bash
curl -X POST http://localhost:4567/api/reserva \
  -H "Content-Type: application/json" \
  -d "{\"visitante_id\":1,\"atracao_id\":1,\"horario\":\"09:00\"}"
```

Ver fila de uma atracao:

```bash
curl http://localhost:4567/api/fila/1
```

Avancar fila:

```bash
curl -X POST http://localhost:4567/api/fila/1/avancar \
  -H "Content-Type: application/json" \
  -d "{\"quantidade\":1}"
```

## Estrutura do Projeto

```text
projeto/
├── api/
│   ├── app.rb
│   └── Gemfile
├── disney/
│   ├── atracao/
│   │   └── atracaoModel.rb
│   ├── visitante/
│   │   └── visitanteModel.rb
│   ├── reserva/
│   │   └── reservaModel.rb
│   ├── fila/
│   │   └── filaVirtual.rb
│   ├── modelos/
│   │   └── estatistica.rb
│   └── repositorios/
│       ├── database.rb
│       ├── repositorioAtracao.rb
│       ├── repositorioVisitante.rb
│       └── repositorioReserva.rb
├── frontend/
│   ├── src/
│   │   ├── components/
│   │   └── services/
│   ├── package.json
│   └── Dockerfile
├── docker-compose.yml
├── Dockerfile
├── seed.rb
├── REVIEW.md
└── README.md
```

## Arquivos Importantes

- `api/app.rb`: rotas da API.
- `disney/repositorios/database.rb`: conexao e criacao das tabelas no PostgreSQL.
- `disney/repositorios/repositorioAtracao.rb`: persistencia de atracoes.
- `disney/repositorios/repositorioVisitante.rb`: persistencia de visitantes.
- `disney/repositorios/repositorioReserva.rb`: persistencia de reservas e fila ativa.
- `seed.rb`: dados iniciais.
- `frontend/src/components/PortalVisitante.jsx`: tela do visitante.
- `frontend/src/components/PainelAdministrador.jsx`: painel do parque.
- `frontend/src/components/MenuCadastro.jsx`: cadastro de atracoes e visitantes.
- `REVIEW.md`: mapeamento dos requisitos para o codigo.

## Rodando Sem Docker

O uso sem Docker exige PostgreSQL instalado localmente e configurado.

Configure a variavel:

```bash
DATABASE_URL=postgresql://disney_user:disney_pass_2026@localhost:5432/disney_db
```

Backend:

```bash
cd api
bundle install
ruby ../seed.rb
ruby app.rb -o 0.0.0.0
```

Frontend:

```bash
cd frontend
npm install
npm run dev
```

Para a maioria das pessoas, use Docker.

## Problemas Comuns

### Frontend abre, mas nao carrega atracoes

Verifique se a API esta rodando:

```bash
curl http://localhost:4567/api/atracao
```

Se a API nao responder:

```bash
docker-compose logs api
```

### Banco nao esta com dados

Recrie tudo:

```bash
docker-compose down -v
docker-compose up -d --build
```

### Alterei o codigo mas nao apareceu no navegador

Rebuild:

```bash
docker-compose up -d --build
```

Depois use `Ctrl + F5` no navegador para limpar cache.

## Documentacao de Conformidade

Para ver onde cada requisito do trabalho foi implementado, abra:

```text
REVIEW.md
```

Esse arquivo mostra os requisitos e os arquivos/linhas correspondentes no codigo.
