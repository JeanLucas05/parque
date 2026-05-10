# -*- coding: utf-8 -*-

require_relative 'no'

class ListaEncadeada
  attr_accessor :inicio

  def initialize
    @inicio = nil
  end

  def inserir(dados)
    novo_no = No.new(dados)

    if @inicio.nil?
      @inicio = novo_no
      return novo_no
    end

    atual = @inicio
    atual = atual.proximo while atual.proximo
    atual.proximo = novo_no
    novo_no
  end

  def inserir_no_inicio(dados)
    novo_no = No.new(dados)
    novo_no.proximo = @inicio
    @inicio = novo_no
    novo_no
  end

  def remover_primeiro
    return nil if @inicio.nil?

    removido = @inicio
    @inicio = @inicio.proximo
    removido.dados
  end

  def remover_por_id(id)
    return nil if @inicio.nil?

    if mesmo_id?(@inicio.dados, id)
      return remover_primeiro
    end

    atual = @inicio
    while atual.proximo
      if mesmo_id?(atual.proximo.dados, id)
        removido = atual.proximo
        atual.proximo = atual.proximo.proximo
        return removido.dados
      end

      atual = atual.proximo
    end

    nil
  end

  def buscar_por_id(id)
    atual = @inicio

    while atual
      return atual.dados if mesmo_id?(atual.dados, id)

      atual = atual.proximo
    end

    nil
  end

  def obter_posicao(id)
    atual = @inicio
    posicao = 1

    while atual
      return posicao if mesmo_id?(atual.dados, id)

      atual = atual.proximo
      posicao += 1
    end

    nil
  end

  def obter_tamanho
    tamanho = 0
    atual = @inicio

    while atual
      tamanho += 1
      atual = atual.proximo
    end

    tamanho
  end

  def obter_primeiros(n)
    resultado = []
    atual = @inicio
    contador = 0

    while atual && contador < n
      resultado[contador] = atual.dados
      atual = atual.proximo
      contador += 1
    end

    resultado
  end

  def listar_todos
    resultado = []
    atual = @inicio
    contador = 0

    while atual
      resultado[contador] = atual.dados
      atual = atual.proximo
      contador += 1
    end

    resultado
  end

  def vazia?
    @inicio.nil?
  end

  def ordenar_por_prioridade
    return if @inicio.nil? || @inicio.proximo.nil?

    mudou = true
    while mudou
      mudou = false
      atual = @inicio

      while atual && atual.proximo
        prioridade_atual = prioridade(atual.dados)
        prioridade_proximo = prioridade(atual.proximo.dados)

        if prioridade_atual > prioridade_proximo
          temporario = atual.dados
          atual.dados = atual.proximo.dados
          atual.proximo.dados = temporario
          mudou = true
        end

        atual = atual.proximo
      end
    end
  end

  private

  def mesmo_id?(dados, id)
    return dados.id == id if dados.respond_to?(:id)
    return dados.atracao_id == id if dados.respond_to?(:atracao_id)

    false
  end

  def prioridade(dados)
    return dados.prioridade if dados.respond_to?(:prioridade) && dados.prioridade

    999_999
  end
end
