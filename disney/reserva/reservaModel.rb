require 'date'

class ReservaModel 
    attr_accessor :id , :visitante , :atracao , :horario, :status, :posicao_na_fila, :prioridade, :data_reserva, :visitante_id, :atracao_id

    def initialize(id , visitante , atracao , horario , status , posicaoNaFila , prioridade)
        @id = id
        @visitante = visitante
        @atracao = atracao
        @visitante_id = visitante.id if visitante
        @atracao_id = atracao.id if atracao
        @horario = horario
        @status = status || "aguardando"
        @posicao_na_fila = posicaoNaFila
        @prioridade = prioridade || calcular_prioridade
        @data_reserva = Date.today
    end

    def calcular_prioridade
        return 2 unless @visitante
        case @visitante.tipo_ingresso
        when :vip , :anual
            1
        else
            2
        end
    end
end



