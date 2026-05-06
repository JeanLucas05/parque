require 'date'

class AtracaoModel
  attr_accessor :id, :nome, :tipo, :capacidade_por_sessao,
                :idade_minima, :horarios_disponiveis,
                :passes_com_prioridade, :fila_virtual

  def initialize(id, nome, tipo, capacidade_por_sessao, idade_minima)
    @id = id
    @nome = nome
    @tipo = tipo
    @capacidade_por_sessao = capacidade_por_sessao
    @idade_minima = idade_minima
    @horarios_disponiveis = []
    @passes_com_prioridade = []
    @fila_virtual = FilaVirtual.new
  end
end