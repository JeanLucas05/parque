require 'date'

class VisitanteModel
  attr_accessor :id, :nome, :cpf, :data_nascimento, :email, :tipo_ingresso, :reservas, :senha_hash

  def initialize(id, nome, cpf, data_nascimento, email, tipo_ingresso, senha_hash = nil)
    @id = id
    @nome = nome
    @cpf = cpf
    @data_nascimento = data_nascimento
    @email = email
    @tipo_ingresso = tipo_ingresso
    @senha_hash = senha_hash
    @reservas = []
  end

  def get_idade
    hoje = Date.today
    idade = hoje.year - @data_nascimento.year

    # ajusta se ainda não fez aniversário no ano
    if hoje < Date.new(hoje.year, @data_nascimento.month, @data_nascimento.day)
      idade -= 1
    end

    idade
  end
end
