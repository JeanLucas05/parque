class ControladorAtracao
  def initialize(repositorio)
    @repositorio = repositorio
    @proximo_id = 1
  end

  def cadastrar_atracao(nome, tipo, capacidade, idade_minima, horarios = [], passes_prioridade = [])
    if nome.nil? || nome.empty?
      puts "❌ Erro: Nome da atração é obrigatório"
      return nil
    end

    atracao = AtracaoModel.new(@proximo_id, nome, tipo, capacidade, idade_minima)
    atracao.horarios_disponiveis = horarios
    atracao.passes_com_prioridade = passes_prioridade
    
    @repositorio.salvar(atracao)
    @proximo_id += 1
    
    puts "✅ Atração '#{nome}' cadastrada com sucesso!"
    atracao
  end

  def listar_atracao(atracao_id)
    atracao = @repositorio.obter_por_id(atracao_id)
    
    if atracao
      puts "\n📌 Detalhes da Atração:"
      puts "ID: #{atracao.id}"
      puts "Nome: #{atracao.nome}"
      puts "Tipo: #{atracao.tipo}"
      puts "Capacidade: #{atracao.capacidade_por_sessao} pessoas por sessão"
      puts "Idade Mínima: #{atracao.idade_minima} anos"
      puts "Horários: #{atracao.horarios_disponiveis.join(', ')}"
      puts "Passes com Prioridade: #{atracao.passes_com_prioridade.join(', ')}"
    else
      puts "❌ Atração não encontrada"
    end
  end

  def listar_todas_atracao
    atracacoes = @repositorio.obter_todas
    
    if atracacoes.empty?
      puts "❌ Nenhuma atração cadastrada"
      return
    end
    
    puts "\n🎢 LISTA DE ATRAÇÕES"
    puts "=" * 80
    
    atracacoes.each do |atracao|
      puts "\n#{atracao.id}. #{atracao.nome}"
      puts "   Tipo: #{atracao.tipo} | Capacidade: #{atracao.capacidade_por_sessao} | Idade Mínima: #{atracao.idade_minima}+"
      puts "   Horários: #{atracao.horarios_disponiveis.join(', ')}"
    end
  end

  def atualizar_horarios(atracao_id, novos_horarios)
    atracao = @repositorio.obter_por_id(atracao_id)
    
    if atracao
      atracao.horarios_disponiveis = novos_horarios
      @repositorio.salvar(atracao)
      puts "✅ Horários atualizados para #{atracao.nome}"
    else
      puts "❌ Atração não encontrada"
    end
  end

  def atualizar_passes_prioridade(atracao_id, novos_passes)
    atracao = @repositorio.obter_por_id(atracao_id)
    
    if atracao
      atracao.passes_com_prioridade = novos_passes
      @repositorio.salvar(atracao)
      puts "✅ Passes de prioridade atualizados para #{atracao.nome}"
    else
      puts "❌ Atração não encontrada"
    end
  end

  def deletar_atracao(atracao_id)
    atracao = @repositorio.obter_por_id(atracao_id)
    
    if atracao
      @repositorio.deletar(atracao_id)
      puts "✅ Atração deletada com sucesso"
    else
      puts "❌ Atração não encontrada"
    end
  end
end
