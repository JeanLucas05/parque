# -*- coding: utf-8 -*-

require 'sinatra'
require 'sinatra/cross_origin'
require 'json'
require 'date'
require 'digest'

register Sinatra::CrossOrigin
enable :cross_origin

# Carregar modelos e repositórios (CORRIGIDO)
require_relative 'disney/atracao/atracaoModel'
require_relative 'disney/visitante/visitanteModel'
require_relative 'disney/reserva/reservaModel'
require_relative 'disney/estruturas/no'
require_relative 'disney/estruturas/lista_encadeada'
require_relative 'disney/fila/filaVirtual'

require_relative 'disney/repositorios/repositorioAtracao'
require_relative 'disney/repositorios/repositorioVisitante'
require_relative 'disney/repositorios/repositorioReserva'

require_relative 'disney/controladores/controladorAtracao'
require_relative 'disney/controladores/controladorVisitante'
require_relative 'disney/controladores/controladorReserva'

require_relative 'disney/modelos/estatistica'

# Configurar CORS
set :allow_origin, '*'
set :allow_methods, [:get, :head, :post, :put, :delete, :options]
set :allow_headers, ['Content-Type', 'Authorization']

options '*' do
  response.headers['Allow'] = 'GET, HEAD, POST, PUT, DELETE, OPTIONS'
  200
end


# Inicializar repositórios
REPOSITORIO_ATRACAO = RepositorioAtracao.new
REPOSITORIO_VISITANTE = RepositorioVisitante.new
REPOSITORIO_RESERVA = RepositorioReserva.new

# Inicializar controladores
CONTROLADOR_ATRACAO = ControladorAtracao.new(REPOSITORIO_ATRACAO)
CONTROLADOR_VISITANTE = ControladorVisitante.new(REPOSITORIO_VISITANTE)
CONTROLADOR_RESERVA = ControladorReserva.new(
  REPOSITORIO_RESERVA,
  REPOSITORIO_ATRACAO,
  REPOSITORIO_VISITANTE
)

ESTATISTICA = Estatistica.new(REPOSITORIO_RESERVA)

def fila_ativa(atracao_id)
  REPOSITORIO_RESERVA.obter_fila_ativa_por_atracao(atracao_id)
end

def construir_fila_virtual(atracao_id)
  reservas = fila_ativa(atracao_id)
  fila = FilaVirtual.new(atracao_id)
  indice = 0

  while indice < reservas.length
    fila.adicionar_reserva(reservas[indice])
    indice += 1
  end

  fila
end

def posicao_na_fila(reserva)
  return nil unless reserva.status == 'aguardando'

  construir_fila_virtual(reserva.atracao_id).obter_posicao(reserva.id)
end

def reserva_para_json(reserva)
  visitante = REPOSITORIO_VISITANTE.obter_por_id(reserva.visitante_id)
  atracao = REPOSITORIO_ATRACAO.obter_por_id(reserva.atracao_id)

  {
    id: reserva.id,
    visitante_id: reserva.visitante_id,
    visitante_nome: visitante&.nome,
    atracao_id: reserva.atracao_id,
    atracao_nome: atracao&.nome,
    horario: reserva.horario,
    status: reserva.status,
    posicao_na_fila: posicao_na_fila(reserva),
    prioridade: reserva.prioridade,
    data_reserva: reserva.data_reserva.to_s
  }
end

def visitante_para_json(visitante)
  {
    id: visitante.id,
    nome: visitante.nome,
    cpf: visitante.cpf,
    data_nascimento: visitante.data_nascimento.to_s,
    idade: visitante.get_idade,
    email: visitante.email,
    tipo_ingresso: visitante.tipo_ingresso
  }
end

def hash_senha(senha)
  Digest::SHA256.hexdigest(senha.to_s)
end

# ======== ATRAÇÕES ========

get '/api/atracao' do
  content_type :json
  atracacoes = REPOSITORIO_ATRACAO.obter_todas
  atracacoes.map do |a|
    {
      id: a.id,
      nome: a.nome,
      tipo: a.tipo,
      capacidade_por_sessao: a.capacidade_por_sessao,
      idade_minima: a.idade_minima,
      horarios_disponiveis: a.horarios_disponiveis,
      passes_com_prioridade: a.passes_com_prioridade
    }
  end.to_json
end

get '/api/atracao/:id' do
  content_type :json
  id = params[:id].to_i
  atracao = REPOSITORIO_ATRACAO.obter_por_id(id)
  
  if atracao
    {
      id: atracao.id,
      nome: atracao.nome,
      tipo: atracao.tipo,
      capacidade_por_sessao: atracao.capacidade_por_sessao,
      idade_minima: atracao.idade_minima,
      horarios_disponiveis: atracao.horarios_disponiveis,
      passes_com_prioridade: atracao.passes_com_prioridade
    }.to_json
  else
    status 404
    { erro: 'Atração não encontrada' }.to_json
  end
end

post '/api/atracao' do
  content_type :json
  data = JSON.parse(request.body.read)
  
  atracao = AtracaoModel.new(
    (REPOSITORIO_ATRACAO.obter_todas.map(&:id).max || 0) + 1,
    data['nome'],
    data['tipo'],
    data['capacidade_por_sessao'],
    data['idade_minima']
  )
  atracao.horarios_disponiveis = data['horarios_disponiveis'] || []
  atracao.passes_com_prioridade = data['passes_com_prioridade'] || []
  
  REPOSITORIO_ATRACAO.salvar(atracao)
  
  status 201
  {
    id: atracao.id,
    nome: atracao.nome,
    mensagem: 'Atração criada com sucesso'
  }.to_json
end

# ======== VISITANTES ========

get '/api/visitante' do
  content_type :json
  visitantes = REPOSITORIO_VISITANTE.obter_todos
  visitantes.map { |v| visitante_para_json(v) }.to_json
end

get '/api/visitante/:id' do
  content_type :json
  id = params[:id].to_i
  visitante = REPOSITORIO_VISITANTE.obter_por_id(id)
  
  if visitante
    visitante_para_json(visitante).to_json
  else
    status 404
    { erro: 'Visitante não encontrado' }.to_json
  end
end

post '/api/visitante' do
  content_type :json
  data = JSON.parse(request.body.read)
  
  data_nascimento = Date.parse(data['data_nascimento'])
  senha = data['senha'].to_s

  if senha.length < 4
    status 400
    return { erro: 'Senha deve ter pelo menos 4 caracteres' }.to_json
  end
  
  visitante = VisitanteModel.new(
    (REPOSITORIO_VISITANTE.obter_todos.map(&:id).max || 0) + 1,
    data['nome'],
    data['cpf'],
    data_nascimento,
    data['email'],
    data['tipo_ingresso'].to_sym,
    hash_senha(senha)
  )
  
  REPOSITORIO_VISITANTE.salvar(visitante)
  
  status 201
  {
    id: visitante.id,
    nome: visitante.nome,
    mensagem: 'Visitante criado com sucesso'
  }.to_json
end

# ======== RESERVAS ========

get '/api/reserva' do
  content_type :json
  reservas = REPOSITORIO_RESERVA.obter_todas
  reservas.map { |r| reserva_para_json(r) }.to_json
end

post '/api/visitante/login' do
  content_type :json
  data = JSON.parse(request.body.read)
  email = data['email'].to_s.strip
  senha = data['senha'].to_s

  visitante = REPOSITORIO_VISITANTE.obter_por_email(email)

  unless visitante && visitante.senha_hash == hash_senha(senha)
    status 401
    return { erro: 'E-mail ou senha invalidos' }.to_json
  end

  visitante_para_json(visitante).to_json
end

get '/api/reserva/visitante/:visitante_id' do
  content_type :json
  visitante_id = params[:visitante_id].to_i
  
  reservas = REPOSITORIO_RESERVA.obter_por_visitante(visitante_id)
  reservas.map { |r| reserva_para_json(r) }.to_json
end

get '/api/reserva/atracao/:atracao_id' do
  content_type :json
  atracao_id = params[:atracao_id].to_i
  
  reservas = REPOSITORIO_RESERVA.obter_por_atracao(atracao_id)
  reservas.map { |r| reserva_para_json(r) }.to_json
end

post '/api/reserva' do
  content_type :json
  data = JSON.parse(request.body.read)
  
  visitante_id = data['visitante_id']
  atracao_id = data['atracao_id']
  horario = data['horario']
  
  visitante = REPOSITORIO_VISITANTE.obter_por_id(visitante_id)
  atracao = REPOSITORIO_ATRACAO.obter_por_id(atracao_id)
  
  unless visitante && atracao
    status 404
    return { erro: 'Visitante ou Atração não encontrada' }.to_json
  end
  
  if visitante.get_idade < atracao.idade_minima
    status 400
    return { 
      erro: "Visitante com #{visitante.get_idade} anos não pode acessar (mínimo #{atracao.idade_minima} anos)" 
    }.to_json
  end
  
  reserva = ReservaModel.new(
    (REPOSITORIO_RESERVA.obter_todas.map(&:id).max || 0) + 1,
    visitante,
    atracao,
    horario,
    'aguardando',
    nil,
    nil
  )
  
  REPOSITORIO_RESERVA.salvar(reserva)
  reserva = REPOSITORIO_RESERVA.obter_por_id(reserva.id)
  
  status 201
  reserva_para_json(reserva).merge(mensagem: 'Reserva criada com sucesso').to_json
end

# ======== FILA VIRTUAL ========

get '/api/fila/:atracao_id' do
  content_type :json
  atracao_id = params[:atracao_id].to_i
  atracao = REPOSITORIO_ATRACAO.obter_por_id(atracao_id)

  unless atracao
    status 404
    return { erro: 'AtraÃ§Ã£o nÃ£o encontrada' }.to_json
  end

  fila_virtual = construir_fila_virtual(atracao_id)
  fila = []
  atual = fila_virtual.fila.inicio
  posicao = 1

  while atual
    reserva = atual.dados
    visitante = REPOSITORIO_VISITANTE.obter_por_id(reserva.visitante_id)
    fila[fila.length] = {
      posicao: posicao,
      reserva_id: reserva.id,
      visitante_id: reserva.visitante_id,
      visitante_nome: visitante&.nome || "Visitante #{reserva.visitante_id}",
      tipo_ingresso: visitante&.tipo_ingresso&.to_s || 'normal',
      horario: reserva.horario,
      prioridade: reserva.prioridade
    }

    atual = atual.proximo
    posicao += 1
  end

  {
    atracao_id: atracao.id,
    atracao_nome: atracao.nome,
    total_na_fila: fila.length,
    fila: fila
  }.to_json
end

post '/api/fila/:atracao_id/avancar' do
  content_type :json
  atracao_id = params[:atracao_id].to_i
  atracao = REPOSITORIO_ATRACAO.obter_por_id(atracao_id)

  unless atracao
    status 404
    return { erro: 'Atracao nao encontrada' }.to_json
  end

  data = request.body.read
  quantidade = data.empty? ? 1 : (JSON.parse(data)['quantidade'] || 1).to_i
  quantidade = 1 if quantidade < 1

  fila = construir_fila_virtual(atracao_id)
  atendidas = []
  contador = 0

  while contador < quantidade
    reserva = fila.remover_primeira_reserva
    break unless reserva

    reserva_atualizada = REPOSITORIO_RESERVA.atualizar_status(reserva.id, 'concluida')
    atendidas[atendidas.length] = reserva_atualizada if reserva_atualizada
    contador += 1
  end

  reservas_atendidas = []
  indice = 0
  while indice < atendidas.length
    reservas_atendidas[reservas_atendidas.length] = reserva_para_json(atendidas[indice])
    indice += 1
  end

  {
    atracao_id: atracao.id,
    atracao_nome: atracao.nome,
    quantidade_atendida: atendidas.length,
    reservas_atendidas: reservas_atendidas,
    total_restante_na_fila: fila_ativa(atracao_id).length
  }.to_json
rescue JSON::ParserError
  status 400
  { erro: 'JSON invalido' }.to_json
end

# ======== ESTATISTICAS ========

get '/api/estatistica/diario' do
  content_type :json
  data = params[:data] ? Date.parse(params[:data]) : Date.today
  ESTATISTICA.gerar_relatorio_diario(data).to_json
rescue ArgumentError
  status 400
  { erro: 'Data invalida' }.to_json
end

get '/api/estatistica/periodo' do
  content_type :json
  data_inicio = Date.parse(params[:data_inicio])
  data_fim = Date.parse(params[:data_fim])
  ESTATISTICA.gerar_relatorio_por_periodo(data_inicio, data_fim).to_json
rescue ArgumentError, TypeError
  status 400
  { erro: 'Periodo invalido' }.to_json
end

# ======== HEALTH ========

get '/api/health' do
  content_type :json
  { status: 'API está funcionando!' }.to_json
end

# ROOT

get '/' do
  content_type :json
  { mensagem: 'API rodando' }.to_json
end

# ERROS

error do
  content_type :json
  { erro: 'Erro na requisição' }.to_json
end

not_found do
  content_type :json
  { erro: 'Endpoint não encontrado' }.to_json
end
