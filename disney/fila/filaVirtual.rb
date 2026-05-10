require 'date'
require_relative '../estruturas/lista_encadeada'

class FilaVirtual
  attr_accessor :fila, :atracao_id

  def initialize(atracao_id = nil)
    @fila = ListaEncadeada.new
    @atracao_id = atracao_id
  end

  def adicionar_reserva(reserva)
    @fila.inserir(reserva)
    ordenar_fila
  end

  def remover_primeira_reserva
    @fila.remover_primeiro
  end

  def obter_posicao(reserva_id)
    @fila.obter_posicao(reserva_id)
  end

  def obter_proximas_reservas(quantidade)
    @fila.obter_primeiros(quantidade)
  end

  def tamanho_fila
    @fila.obter_tamanho
  end

  def limpar_fila
    @fila = ListaEncadeada.new
  end

  private

  def ordenar_fila
    @fila.ordenar_por_prioridade
  end
end
