# -*- coding: utf-8 -*-

require 'date'
require_relative '../fila/filaVirtual'
require_relative '../estruturas/lista_encadeada'

class ControladorReserva
  def initialize(repositorio_reserva, repositorio_atracao, repositorio_visitante)
    @repositorio_reserva = repositorio_reserva
    @repositorio_atracao = repositorio_atracao
    @repositorio_visitante = repositorio_visitante
    @proximo_id = 1
    @filas = ListaEncadeada.new
  end

  def criar_reserva(visitante_id, atracao_id, horario)
    visitante = @repositorio_visitante.obter_por_id(visitante_id)
    atracao = @repositorio_atracao.obter_por_id(atracao_id)

    if !visitante
      puts "Visitante nao encontrado"
      return nil
    end

    if !atracao
      puts "Atracao nao encontrada"
      return nil
    end

    idade = visitante.get_idade
    if idade < atracao.idade_minima
      puts "#{visitante.nome} tem #{idade} anos e nao pode acessar #{atracao.nome} (minimo #{atracao.idade_minima} anos)"
      return nil
    end

    reserva = ReservaModel.new(@proximo_id, visitante, atracao, horario, "aguardando", nil, nil)
    reserva.data_reserva = Date.today

    inicializar_fila_atracao(atracao_id)
    fila = obter_fila_atracao(atracao_id)
    fila.adicionar_reserva(reserva)

    reserva.posicao_na_fila = fila.obter_posicao(reserva.id)

    @repositorio_reserva.salvar(reserva)
    adicionar_reserva_visitante(visitante, reserva.id)
    @repositorio_visitante.salvar(visitante)

    @proximo_id += 1

    puts "Reserva criada! Voce esta na posicao #{reserva.posicao_na_fila} da fila para #{atracao.nome}"
    reserva
  end

  def obter_posicao_fila(reserva_id)
    todas_reservas = @repositorio_reserva.obter_todas
    reserva = buscar_reserva_em_lista(todas_reservas, reserva_id)

    if !reserva
      puts "Reserva nao encontrada"
      return nil
    end

    inicializar_fila_atracao(reserva.atracao_id)
    fila = obter_fila_atracao(reserva.atracao_id)
    posicao = fila.obter_posicao(reserva.id)

    if posicao
      puts "Sua posicao na fila: #{posicao}"
    else
      puts "Voce nao esta mais na fila"
    end

    posicao
  end

  def obter_historico_visitante(visitante_id)
    reservas = @repositorio_reserva.obter_por_visitante(visitante_id)
    visitante = @repositorio_visitante.obter_por_id(visitante_id)

    if !visitante || lista_vazia?(reservas)
      puts "Nenhuma reserva encontrada para este visitante"
      return
    end

    puts "\nHISTORICO DE RESERVAS - #{visitante.nome}"
    puts "=" * 80

    indice = 0
    while indice < reservas.length
      reserva = reservas[indice]
      atracao = @repositorio_atracao.obter_por_id(reserva.atracao_id) if reserva.atracao_id

      if atracao
        puts "\n#{atracao.nome}"
        puts "   Horario: #{reserva.horario}"
        puts "   Status: #{reserva.status}"
        puts "   Posicao na Fila: #{reserva.posicao_na_fila || 'N/A'}"
        puts "   Tipo de Ingresso: #{visitante.tipo_ingresso}"
      end

      indice += 1
    end
  end

  def visualizar_fila_atracao(atracao_id)
    inicializar_fila_atracao(atracao_id)
    atracao = @repositorio_atracao.obter_por_id(atracao_id)

    if !atracao
      puts "Atracao nao encontrada"
      return
    end

    fila = obter_fila_atracao(atracao_id)
    puts "\nFILA VIRTUAL - #{atracao.nome}"
    puts "=" * 80
    puts "Total na fila: #{fila.tamanho_fila} pessoas"
    puts "\nProximas 10 pessoas:"
    puts "-" * 80

    proximas = fila.obter_proximas_reservas(10)

    if lista_vazia?(proximas)
      puts "Fila vazia"
      return
    end

    index = 0
    while index < proximas.length
      reserva = proximas[index]
      visitante = if reserva.visitante.nil?
                    @repositorio_visitante.obter_por_id(reserva.visitante_id)
                  else
                    reserva.visitante
                  end

      if visitante
        tipo_ingresso = visitante.tipo_ingresso
        prioridade_texto = tipo_ingresso == :vip || tipo_ingresso == :anual ? "VIP" : "Normal"
        puts "#{index + 1}. #{visitante.nome} [#{prioridade_texto}]"
      else
        puts "#{index + 1}. Visitante ID: #{reserva.visitante_id}"
      end

      index += 1
    end
  end

  def processar_entrada_atracao(atracao_id, quantidade = 1)
    inicializar_fila_atracao(atracao_id)
    atracao = @repositorio_atracao.obter_por_id(atracao_id)

    if !atracao
      puts "Atracao nao encontrada"
      return
    end

    fila = obter_fila_atracao(atracao_id)
    entrada = ListaEncadeada.new
    contador = 0

    while contador < quantidade
      reserva = fila.remover_primeira_reserva
      break if !reserva

      reserva.status = "em_uso"
      @repositorio_reserva.salvar(reserva)
      entrada.inserir(reserva)
      contador += 1
    end

    total_entrada = entrada.obter_tamanho
    if total_entrada > 0
      puts "#{total_entrada} visitante(s) entraram em #{atracao.nome}"
    else
      puts "Fila vazia"
    end

    entrada.listar_todos
  end

  def listar_reservas_visitante(visitante_id)
    reservas = @repositorio_reserva.obter_por_visitante(visitante_id)
    visitante = @repositorio_visitante.obter_por_id(visitante_id)

    if !visitante || lista_vazia?(reservas)
      puts "Nenhuma reserva ativa encontrada"
      return
    end

    puts "\nRESERVAS ATIVAS - #{visitante.nome}"
    puts "=" * 80

    indice = 0
    while indice < reservas.length
      reserva = reservas[indice]

      if reserva.status == "aguardando"
        atracao = @repositorio_atracao.obter_por_id(reserva.atracao_id)
        if atracao
          puts "\n#{atracao.nome}"
          puts "   Horario: #{reserva.horario}"
          puts "   Posicao: #{reserva.posicao_na_fila} na fila"
        end
      end

      indice += 1
    end
  end

  private

  def inicializar_fila_atracao(atracao_id)
    return if obter_fila_atracao(atracao_id)

    fila = FilaVirtual.new(atracao_id)
    @filas.inserir(fila)

    reservas_existentes = @repositorio_reserva.obter_por_atracao(atracao_id)
    indice = 0

    while indice < reservas_existentes.length
      reserva = reservas_existentes[indice]
      fila.adicionar_reserva(reserva) if reserva.status == "aguardando"
      indice += 1
    end
  end

  def obter_fila_atracao(atracao_id)
    atual = @filas.inicio

    while atual
      return atual.dados if atual.dados.atracao_id == atracao_id

      atual = atual.proximo
    end

    nil
  end

  def buscar_reserva_em_lista(reservas, reserva_id)
    indice = 0

    while indice < reservas.length
      reserva = reservas[indice]
      return reserva if reserva.id == reserva_id

      indice += 1
    end

    nil
  end

  def lista_vazia?(lista)
    lista.nil? || lista.length == 0
  end

  def adicionar_reserva_visitante(visitante, reserva_id)
    visitante.reservas = Array.new if visitante.reservas.nil?
    visitante.reservas[visitante.reservas.length] = reserva_id
  end
end
