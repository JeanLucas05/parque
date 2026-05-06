class ControladorReserva
  def initialize(repositorio_reserva, repositorio_atracao, repositorio_visitante)
    @repositorio_reserva = repositorio_reserva
    @repositorio_atracao = repositorio_atracao
    @repositorio_visitante = repositorio_visitante
    @proximo_id = 1
    @filas = {} # Hash para manter filas por atração
  end

  def criar_reserva(visitante_id, atracao_id, horario)
    visitante = @repositorio_visitante.obter_por_id(visitante_id)
    atracao = @repositorio_atracao.obter_por_id(atracao_id)

    if !visitante
      puts "❌ Visitante não encontrado"
      return nil
    end

    if !atracao
      puts "❌ Atração não encontrada"
      return nil
    end

    # Valida idade
    idade = visitante.get_idade
    if idade < atracao.idade_minima
      puts "❌ #{visitante.nome} tem #{idade} anos e não pode acessar #{atracao.nome} (mínimo #{atracao.idade_minima} anos)"
      return nil
    end

    # Cria a reserva
    reserva = ReservaModel.new(@proximo_id, visitante, atracao, horario, "aguardando", nil, nil)
    reserva.data_reserva = Date.today
    
    # Adiciona à fila da atração
    inicializar_fila_atracao(atracao_id)
    @filas[atracao_id].adicionar_reserva(reserva)
    
    # Atualiza posição na fila
    reserva.posicao_na_fila = @filas[atracao_id].obter_posicao(reserva.id)
    
    # Salva a reserva
    @repositorio_reserva.salvar(reserva)
    visitante.reservas << reserva.id
    @repositorio_visitante.salvar(visitante)
    
    @proximo_id += 1
    
    puts "✅ Reserva criada! Você está na posição #{reserva.posicao_na_fila} da fila para #{atracao.nome}"
    reserva
  end

  def obter_posicao_fila(reserva_id)
    todas_reservas = @repositorio_reserva.obter_todas
    reserva = todas_reservas.find { |r| r.id == reserva_id }

    if !reserva
      puts "❌ Reserva não encontrada"
      return nil
    end

    inicializar_fila_atracao(reserva.atracao_id)
    posicao = @filas[reserva.atracao_id].obter_posicao(reserva.id)

    if posicao
      puts "📍 Sua posição na fila: #{posicao}"
    else
      puts "❌ Você não está mais na fila"
    end

    posicao
  end

  def obter_historico_visitante(visitante_id)
    reservas = @repositorio_reserva.obter_por_visitante(visitante_id)
    visitante = @repositorio_visitante.obter_por_id(visitante_id)

    if !visitante || reservas.empty?
      puts "❌ Nenhuma reserva encontrada para este visitante"
      return
    end

    puts "\n📋 HISTÓRICO DE RESERVAS - #{visitante.nome}"
    puts "=" * 80
    
    reservas.each do |reserva|
      atracao = @repositorio_atracao.obter_por_id(reserva.atracao_id) if reserva.atracao_id
      if atracao
        puts "\n🎢 #{atracao.nome}"
        puts "   Horário: #{reserva.horario}"
        puts "   Status: #{reserva.status}"
        puts "   Posição na Fila: #{reserva.posicao_na_fila || 'N/A'}"
        puts "   Tipo de Ingresso: #{visitante.tipo_ingresso}"
      end
    end
  end

  def visualizar_fila_atracao(atracao_id)
    inicializar_fila_atracao(atracao_id)
    atracao = @repositorio_atracao.obter_por_id(atracao_id)

    if !atracao
      puts "❌ Atração não encontrada"
      return
    end

    fila = @filas[atracao_id]
    puts "\n🎢 FILA VIRTUAL - #{atracao.nome}"
    puts "=" * 80
    puts "Total na fila: #{fila.tamanho_fila} pessoas"
    puts "\nPróximas 10 pessoas:"
    puts "-" * 80

    proximas = fila.obter_proximas_reservas(10)
    
    if proximas.empty?
      puts "Fila vazia"
      return
    end

    proximas.each_with_index do |reserva, index|
      # Carrega visitante do repositório se não existir
      visitante = if reserva.visitante.nil?
                    @repositorio_visitante.obter_por_id(reserva.visitante_id)
                  else
                    reserva.visitante
                  end
      
      # Se ainda não temos visitante, usa ID
      if visitante
        tipo_ingresso = visitante.tipo_ingresso
        prioridade_texto = tipo_ingresso == :vip || tipo_ingresso == :anual ? "⭐ VIP" : "👤 Normal"
        puts "#{index + 1}. #{visitante.nome} [#{prioridade_texto}]"
      else
        puts "#{index + 1}. Visitante ID: #{reserva.visitante_id}"
      end
    end
  end

  def processar_entrada_atracao(atracao_id, quantidade = 1)
    inicializar_fila_atracao(atracao_id)
    atracao = @repositorio_atracao.obter_por_id(atracao_id)

    if !atracao
      puts "❌ Atração não encontrada"
      return
    end

    fila = @filas[atracao_id]
    entrada = []

    quantidade.times do |i|
      reserva = fila.remover_primeira_reserva
      break if !reserva

      reserva.status = "em_uso"
      @repositorio_reserva.salvar(reserva)
      entrada << reserva
    end

    if entrada.length > 0
      puts "✅ #{entrada.length} visitante(s) entraram em #{atracao.nome}"
    else
      puts "❌ Fila vazia"
    end

    entrada
  end

  def listar_reservas_visitante(visitante_id)
    reservas = @repositorio_reserva.obter_por_visitante(visitante_id)
    visitante = @repositorio_visitante.obter_por_id(visitante_id)

    if !visitante || reservas.empty?
      puts "❌ Nenhuma reserva ativa encontrada"
      return
    end

    puts "\n📋 RESERVAS ATIVAS - #{visitante.nome}"
    puts "=" * 80
    
    reservas.select { |r| r.status == "aguardando" }.each do |reserva|
      atracao = @repositorio_atracao.obter_por_id(reserva.atracao_id)
      if atracao
        puts "\n🎢 #{atracao.nome}"
        puts "   Horário: #{reserva.horario}"
        puts "   Posição: #{reserva.posicao_na_fila} na fila"
      end
    end
  end

  private

  def inicializar_fila_atracao(atracao_id)
    unless @filas[atracao_id]
      @filas[atracao_id] = FilaVirtual.new(atracao_id)
      
      # Carrega reservas existentes para esta atração
      reservas_existentes = @repositorio_reserva.obter_por_atracao(atracao_id)
      reservas_existentes.select { |r| r.status == "aguardando" }.each do |reserva|
        @filas[atracao_id].adicionar_reserva(reserva)
      end
    end
  end
end
