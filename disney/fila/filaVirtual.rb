require 'date'

class FilaVirtual
  attr_accessor :fila, :atracao_id

  def initialize(atracao_id = nil)
    @fila = []
    @atracao_id = atracao_id
  end

  def adicionar_reserva(reserva)
    @fila << reserva
    ordenar_fila
  end

  def remover_primeira_reserva
    @fila.shift
  end

  def obter_posicao(reserva_id)
    @fila.each_with_index do |reserva, index|
      return index + 1 if reserva.id == reserva_id
    end
    nil
  end

  def obter_proximas_reservas(quantidade)
    @fila.first(quantidade)
  end

  def tamanho_fila
    @fila.length
  end

  def limpar_fila
    @fila = []
  end

  private

  def ordenar_fila
    # Ordena por prioridade (1 = VIP/Anual vem primeiro, 2 = Normal)
    @fila.sort! { |a, b| a.prioridade <=> b.prioridade }
  end
end
