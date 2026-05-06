require 'json'
require 'date'

class Estatistica
  attr_accessor :reservas_por_dia, :atracao_mais_disputada, :visitante_mais_ativo

  def initialize(repositorio_reserva)
    @repositorio_reserva = repositorio_reserva
    @reservas_por_dia = {}
    @atracao_mais_disputada = nil
    @visitante_mais_ativo = nil
  end

  def gerar_relatorio_diario(data = Date.today)
    reservas_do_dia = @repositorio_reserva.obter_por_data(data)
    
    relatorio = {
      data: data.to_s,
      total_reservas: reservas_do_dia.length,
      atracao_mais_disputada: obter_atracao_mais_disputada(reservas_do_dia),
      visitante_mais_ativo: obter_visitante_mais_ativo(reservas_do_dia),
      reservas_por_status: contar_por_status(reservas_do_dia),
      reservas_por_tipo_ingresso: contar_por_tipo_ingresso(reservas_do_dia)
    }
    
    relatorio
  end

  def gerar_relatorio_por_periodo(data_inicio, data_fim)
    relatorio = {
      periodo: "#{data_inicio} a #{data_fim}",
      total_reservas: 0,
      media_diaria: 0,
      atracao_mais_disputada: nil,
      tipo_ingresso_mais_usado: nil
    }
    
    todas_reservas = @repositorio_reserva.obter_todas
    reservas_filtradas = todas_reservas.select do |r|
      data_r = Date.parse(r.data_reserva.to_s)
      data_r >= data_inicio && data_r <= data_fim
    end
    
    relatorio[:total_reservas] = reservas_filtradas.length
    dias = (data_fim - data_inicio).to_i + 1
    relatorio[:media_diaria] = (relatorio[:total_reservas] / dias).round(2)
    
    relatorio[:atracao_mais_disputada] = obter_atracao_mais_disputada(reservas_filtradas)
    
    relatorio
  end

  private

  def obter_atracao_mais_disputada(reservas)
    return nil if reservas.empty?
    
    atracao_contagem = Hash.new(0)
    reservas.each do |r|
      atracao_contagem[r.atracao_id] += 1
    end
    
    atracao_mais_popular = atracao_contagem.max_by { |_, count| count }
    { atracao_id: atracao_mais_popular[0], quantidade_reservas: atracao_mais_popular[1] }
  end

  def obter_visitante_mais_ativo(reservas)
    return nil if reservas.empty?
    
    visitante_contagem = Hash.new(0)
    reservas.each do |r|
      visitante_contagem[r.visitante_id] += 1
    end
    
    visitante_mais_ativo = visitante_contagem.max_by { |_, count| count }
    { visitante_id: visitante_mais_ativo[0], quantidade_reservas: visitante_mais_ativo[1] }
  end

  def contar_por_status(reservas)
    contagem = Hash.new(0)
    reservas.each do |r|
      contagem[r.status] += 1
    end
    contagem
  end

  def contar_por_tipo_ingresso(reservas)
    contagem = Hash.new(0)
    # Nota: não temos tipo_ingresso diretamente na reserva, precisaremos carregar visitante
    contagem
  end
end
