# -*- coding: utf-8 -*-

require 'date'
require 'digest'

require_relative 'disney/atracao/atracaoModel'
require_relative 'disney/visitante/visitanteModel'
require_relative 'disney/reserva/reservaModel'
require_relative 'disney/fila/filaVirtual'

require_relative 'disney/repositorios/repositorioAtracao'
require_relative 'disney/repositorios/repositorioVisitante'
require_relative 'disney/repositorios/repositorioReserva'

puts "Carregando seed no PostgreSQL..."

repositorio_atracao = RepositorioAtracao.new
repositorio_visitante = RepositorioVisitante.new
RepositorioReserva.new

puts "Inserindo/atualizando atracoes..."

atracao1 = AtracaoModel.new(1, 'Space Mountain', 'montanha-russa', 50, 10)
atracao1.horarios_disponiveis = ['09:00', '10:30', '12:00', '14:00', '16:00', '18:00']
atracao1.passes_com_prioridade = ['vip', 'anual']
repositorio_atracao.salvar(atracao1)
puts 'OK Space Mountain'

atracao2 = AtracaoModel.new(2, 'Piratas do Caribe', 'simulador', 60, 5)
atracao2.horarios_disponiveis = ['09:30', '11:00', '13:00', '15:00', '17:00']
atracao2.passes_com_prioridade = ['vip', 'anual']
repositorio_atracao.salvar(atracao2)
puts 'OK Piratas do Caribe'

atracao3 = AtracaoModel.new(3, 'Haunted Mansion', 'teatro', 40, 0)
atracao3.horarios_disponiveis = ['10:00', '12:00', '14:30', '16:30', '18:30']
atracao3.passes_com_prioridade = ['vip']
repositorio_atracao.salvar(atracao3)
puts 'OK Haunted Mansion'

atracao4 = AtracaoModel.new(4, 'Carrossel Magico', 'brinquedo infantil', 30, 3)
atracao4.horarios_disponiveis = ['10:00', '11:30', '13:30', '15:30', '17:30']
atracao4.passes_com_prioridade = ['normal', 'vip', 'anual']
repositorio_atracao.salvar(atracao4)
puts 'OK Carrossel Magico'

puts 'Inserindo/atualizando visitantes...'

def senha_hash(senha)
  Digest::SHA256.hexdigest(senha)
end

visitante1 = VisitanteModel.new(1, 'Joao Silva', '123.456.789-00', Date.new(1990, 5, 15), 'joao@email.com', :vip, senha_hash('1234'))
repositorio_visitante.salvar(visitante1)
puts 'OK Joao Silva'

visitante2 = VisitanteModel.new(2, 'Maria Santos', '987.654.321-11', Date.new(2010, 8, 22), 'maria@email.com', :normal, senha_hash('1234'))
repositorio_visitante.salvar(visitante2)
puts 'OK Maria Santos'

visitante3 = VisitanteModel.new(3, 'Pedro Costa', '555.666.777-88', Date.new(1985, 3, 10), 'pedro@email.com', :anual, senha_hash('1234'))
repositorio_visitante.salvar(visitante3)
puts 'OK Pedro Costa'

visitante4 = VisitanteModel.new(4, 'Ana Oliveira', '444.333.222-11', Date.new(2015, 12, 5), 'ana@email.com', :normal, senha_hash('1234'))
repositorio_visitante.salvar(visitante4)
puts 'OK Ana Oliveira'

visitante5 = VisitanteModel.new(5, 'Lucas Martins', '111.222.333-44', Date.new(1995, 7, 18), 'lucas@email.com', :vip, senha_hash('1234'))
repositorio_visitante.salvar(visitante5)
puts 'OK Lucas Martins'

puts 'Seed concluido. As reservas existentes foram preservadas.'
