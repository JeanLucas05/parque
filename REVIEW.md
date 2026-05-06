# Relatorio de Conformidade - Sistema de Reservas para Atracoes

Este documento mapeia os requisitos do projeto para os pontos do codigo onde cada funcionalidade foi implementada.

## Stack Identificada

- Backend: Ruby, Sinatra, PostgreSQL via `pg`
- Frontend: React, Vite, Axios
- Infra: Docker Compose com servicos `postgres`, `api` e `frontend`

## Persistencia e Seed

| Requisito | Onde esta implementado | Como atende |
| --- | --- | --- |
| Persistir dados em PostgreSQL | `docker-compose.yml:5-24`, `docker-compose.yml:36-45`, `disney/repositorios/database.rb:1-62` | O Compose sobe PostgreSQL com volume persistente e a API recebe `DATABASE_URL`. O modulo `Database` abre conexao via `pg` e cria as tabelas. |
| Tabelas para atracoes, visitantes e reservas | `disney/repositorios/database.rb:23-58` | Define `atracoes`, `visitantes` e `reservas`, incluindo campos de horario, prioridade, status e data da reserva. |
| Seeder automatico ao subir a API | `Dockerfile:24-39`, `seed.rb:14-68` | O container aguarda o PostgreSQL, executa `ruby seed.rb` e depois inicia a API. O seed insere/atualiza atracoes e visitantes iniciais. |
| Seed sem duplicar dados | `disney/repositorios/repositorioAtracao.rb:13-25`, `disney/repositorios/repositorioVisitante.rb:14-25`, `disney/repositorios/repositorioReserva.rb:16-29` | Os repositorios usam `ON CONFLICT` para atualizar registros existentes em vez de duplicar. |

## Atracoes

| Requisito | Onde esta implementado | Como atende |
| --- | --- | --- |
| Nome, tipo, capacidade, horarios, idade minima e prioridade por passe | `disney/repositorios/database.rb:23-33`, `api/app.rb:84-98`, `api/app.rb:121-143`, `frontend/src/components/MenuCadastro.jsx:11-18`, `frontend/src/components/MenuCadastro.jsx:141-210` | A tabela armazena todos os campos exigidos; a API lista/cria atracoes; o formulario permite cadastrar esses dados. |
| Persistencia das atracoes no banco | `disney/repositorios/repositorioAtracao.rb:9-38`, `disney/repositorios/repositorioAtracao.rb:48-51`, `disney/repositorios/repositorioAtracao.rb:62-72` | O repositorio salva e consulta atracoes no PostgreSQL, serializando horarios e passes como JSONB. |

## Visitantes

| Requisito | Onde esta implementado | Como atende |
| --- | --- | --- |
| Nome, CPF, data de nascimento, e-mail e tipo de ingresso | `disney/repositorios/database.rb:35-45`, `api/app.rb:147-161`, `api/app.rb:184-207`, `frontend/src/components/MenuCadastro.jsx:20-27`, `frontend/src/components/MenuCadastro.jsx:213-271` | A tabela, API e formulario cobrem os campos obrigatorios do visitante. |
| Calculo de idade para regra de faixa etaria | `api/app.rb:249-253`, `disney/visitante/visitanteModel.rb` | A API impede reserva quando o visitante nao atinge a idade minima da atracao. |
| Dados de cartao de credito | Nao implementado | O requisito diz "se for usado"; o sistema atual nao usa pagamento, portanto o campo foi tratado como opcional. |

## Reservas e Portal do Visitante

| Requisito | Onde esta implementado | Como atende |
| --- | --- | --- |
| Visitante visualizar atracoes disponiveis | `frontend/src/components/PortalVisitante.jsx:16-27`, `frontend/src/components/PortalVisitante.jsx:187-209` | O portal carrega e exibe as atracoes disponiveis ao visitante. |
| Entrar na fila/reservar uma atracao | `frontend/src/components/PortalVisitante.jsx:55-83`, `api/app.rb:233-271`, `disney/repositorios/repositorioReserva.rb:9-43` | O visitante seleciona atracao e horario; a API cria uma reserva com status `aguardando`; o repositorio persiste no PostgreSQL. |
| Ver atracoes em que esta aguardando | `frontend/src/components/PortalVisitante.jsx:173-184`, `frontend/src/components/PortalVisitante.jsx:249-269`, `api/app.rb:217-223` | O portal mostra a aba `Na Fila`, filtrando reservas com status `aguardando`. |
| Ver posicao em cada fila | `api/app.rb:58-62`, `api/app.rb:64-80`, `frontend/src/components/PortalVisitante.jsx:252-259` | A API calcula a posicao atual pela fila ativa ordenada por prioridade; o portal exibe `posicao_na_fila`. |
| Ver historico de visitas/reservas | `frontend/src/components/PortalVisitante.jsx:179-184`, `frontend/src/components/PortalVisitante.jsx:270-290`, `api/app.rb:308-337` | Quando a fila avanca, reservas mudam para `concluida`; o portal mostra reservas que nao estao mais aguardando na aba Historico. |

## Filas Virtuais

| Requisito | Onde esta implementado | Como atende |
| --- | --- | --- |
| Cada atracao ter sua propria fila | `api/app.rb:54-56`, `api/app.rb:275-306`, `disney/repositorios/repositorioReserva.rb:71-82` | A fila ativa e filtrada por `atracao_id`, com endpoint proprio para cada atracao. |
| Prioridade para VIP/passe anual | `disney/reserva/reservaModel.rb`, `disney/repositorios/repositorioReserva.rb:71-82`, `api/app.rb:285-297` | A reserva recebe prioridade conforme o tipo de ingresso; a fila ativa e ordenada por prioridade e id. |
| Avancar fila conforme visitantes entram na atracao | `api/app.rb:308-337`, `disney/repositorios/repositorioReserva.rb:105-119`, `frontend/src/components/PainelAdministrador.jsx:50-60`, `frontend/src/components/PainelAdministrador.jsx:141-166` | O painel do parque aciona o endpoint de avancar fila; a API marca a proxima reserva como `concluida`, removendo-a da fila ativa e mantendo historico. |
| Situacao de cada fila e proximos atendimentos | `frontend/src/components/PainelAdministrador.jsx:137-166`, `api/app.rb:287-305` | O painel mostra total da fila e os proximos visitantes em ordem. |

## Painel de Controle do Parque

| Requisito | Onde esta implementado | Como atende |
| --- | --- | --- |
| Quantidade de visitantes por atracao | `frontend/src/components/PainelAdministrador.jsx:62-68`, `frontend/src/components/PainelAdministrador.jsx:77-95` | O painel calcula reservas e visitantes aguardando por atracao. |
| Situacao de cada fila | `frontend/src/components/PainelAdministrador.jsx:40-48`, `frontend/src/components/PainelAdministrador.jsx:137-166` | A tela de filas busca a fila por atracao e lista tamanho e proximos visitantes. |
| Atender proximo visitante | `frontend/src/components/PainelAdministrador.jsx:50-60`, `frontend/src/components/PainelAdministrador.jsx:145-152` | O botao `Atender proximo visitante` chama a API de avancar fila. |

## Estatisticas e Metricas

| Requisito | Onde esta implementado | Como atende |
| --- | --- | --- |
| Quantidade total de reservas por dia | `disney/modelos/estatistica.rb:14-27`, `api/app.rb:341-348`, `frontend/src/components/PainelAdministrador.jsx:173-184` | O modulo analitico conta reservas do dia e o painel exibe o total. |
| Atracao mais disputada do dia | `disney/modelos/estatistica.rb:55-65`, `frontend/src/components/PainelAdministrador.jsx:186-194` | O relatorio conta reservas por atracao e retorna a mais disputada. |
| Visitante que mais usou o sistema no dia | `disney/modelos/estatistica.rb:67-77`, `frontend/src/components/PainelAdministrador.jsx:196-204` | O relatorio conta reservas por visitante e retorna o mais ativo. |

## Interfaces do Sistema

| Interface | Onde esta implementada | Observacao |
| --- | --- | --- |
| Cadastro de atracoes | `frontend/src/components/MenuCadastro.jsx:141-210` | Inclui nome, tipo, capacidade, idade minima, horarios e passes prioritarios. |
| Cadastro de visitantes | `frontend/src/components/MenuCadastro.jsx:213-271` | Inclui nome, CPF, nascimento, e-mail e tipo de ingresso. |
| Portal do visitante | `frontend/src/components/PortalVisitante.jsx:85-294` | Permite login por ID, visualizar atracoes, reservar, ver fila e historico. |
| Painel de controle | `frontend/src/components/PainelAdministrador.jsx:15-275` | Exibe dados administrativos, filas e estatisticas. |

## Pontos de Melhoria

- Criar autenticacao real para visitantes e administradores. Hoje o portal usa login por ID.
- Implementar validacao de CPF e e-mail no backend.
- Evitar duplicidade de reservas iguais para o mesmo visitante, atracao e horario.
- Evoluir `posicao_na_fila` para ser sempre calculada dinamicamente, como ja ocorre na API, e remover a coluna fisica se ela nao for usada.
- Corrigir textos acentuados que aparecem com codificacao quebrada em alguns componentes.
- Se pagamento/cartao passar a fazer parte do escopo, criar tabela propria e nunca armazenar dados sensiveis de cartao em texto puro.
