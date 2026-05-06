class ControladorVisitante
  def initialize(repositorio)
    @repositorio = repositorio
    @proximo_id = 1
  end

  def cadastrar_visitante(nome, cpf, data_nascimento, email, tipo_ingresso)
    if nome.nil? || nome.empty?
      puts "❌ Erro: Nome é obrigatório"
      return nil
    end

    if cpf.nil? || cpf.empty?
      puts "❌ Erro: CPF é obrigatório"
      return nil
    end

    # Verifica se CPF já existe
    visitante_existente = @repositorio.obter_por_cpf(cpf)
    if visitante_existente
      puts "❌ Erro: Já existe um visitante com este CPF"
      return nil
    end

    visitante = VisitanteModel.new(@proximo_id, nome, cpf, data_nascimento, email, tipo_ingresso)
    
    @repositorio.salvar(visitante)
    @proximo_id += 1
    
    puts "✅ Visitante '#{nome}' cadastrado com sucesso!"
    visitante
  end

  def obter_visitante(visitante_id)
    visitante = @repositorio.obter_por_id(visitante_id)
    
    if visitante
      puts "\n👤 Dados do Visitante:"
      puts "ID: #{visitante.id}"
      puts "Nome: #{visitante.nome}"
      puts "CPF: #{visitante.cpf}"
      puts "Data de Nascimento: #{visitante.data_nascimento}"
      puts "Idade: #{visitante.get_idade} anos"
      puts "E-mail: #{visitante.email}"
      puts "Tipo de Ingresso: #{visitante.tipo_ingresso}"
      puts "Total de Reservas: #{visitante.reservas.length}"
    else
      puts "❌ Visitante não encontrado"
    end
  end

  def listar_todos_visitantes
    visitantes = @repositorio.obter_todos
    
    if visitantes.empty?
      puts "❌ Nenhum visitante cadastrado"
      return
    end
    
    puts "\n👥 LISTA DE VISITANTES"
    puts "=" * 100
    printf("%-5s %-25s %-15s %-10s %-20s %-15s\n", "ID", "Nome", "CPF", "Idade", "Email", "Tipo Ingresso")
    puts "-" * 100
    
    visitantes.each do |visitante|
      printf("%-5s %-25s %-15s %-10s %-20s %-15s\n", 
        visitante.id, 
        visitante.nome[0..22], 
        visitante.cpf, 
        visitante.get_idade,
        visitante.email[0..18],
        visitante.tipo_ingresso
      )
    end
  end

  def atualizar_visitante(visitante_id, dados)
    visitante = @repositorio.obter_por_id(visitante_id)
    
    if visitante
      visitante.nome = dados[:nome] if dados[:nome]
      visitante.email = dados[:email] if dados[:email]
      visitante.tipo_ingresso = dados[:tipo_ingresso] if dados[:tipo_ingresso]
      
      @repositorio.salvar(visitante)
      puts "✅ Dados do visitante atualizados"
    else
      puts "❌ Visitante não encontrado"
    end
  end

  def deletar_visitante(visitante_id)
    visitante = @repositorio.obter_por_id(visitante_id)
    
    if visitante
      @repositorio.deletar(visitante_id)
      puts "✅ Visitante deletado com sucesso"
    else
      puts "❌ Visitante não encontrado"
    end
  end

  def validar_idade_atracao(visitante, atracao)
    idade = visitante.get_idade
    if idade >= atracao.idade_minima
      true
    else
      puts "❌ #{visitante.nome} tem #{idade} anos e não pode acessar #{atracao.nome} (mínimo #{atracao.idade_minima} anos)"
      false
    end
  end
end
