require 'date'
require 'json'
require_relative 'database'

class RepositorioVisitante
  def initialize(_arquivo = nil)
    Database.criar_tabelas
  end

  def salvar(visitante)
    Database.with_connection do |conn|
      conn.exec_params(
        <<~SQL,
          INSERT INTO visitantes (
            id, nome, cpf, data_nascimento, email, senha_hash, tipo_ingresso, reservas
          )
          VALUES ($1, $2, $3, $4, $5, $6, $7, $8::jsonb)
          ON CONFLICT (id) DO UPDATE SET
            nome = EXCLUDED.nome,
            cpf = EXCLUDED.cpf,
            data_nascimento = EXCLUDED.data_nascimento,
            email = EXCLUDED.email,
            senha_hash = EXCLUDED.senha_hash,
            tipo_ingresso = EXCLUDED.tipo_ingresso,
            reservas = EXCLUDED.reservas,
            updated_at = CURRENT_TIMESTAMP
        SQL
        [
          visitante.id,
          visitante.nome,
          visitante.cpf,
          visitante.data_nascimento.to_s,
          visitante.email,
          visitante.senha_hash.to_s,
          visitante.tipo_ingresso.to_s,
          JSON.generate(visitante.reservas || [])
        ]
      )
    end
  end

  def obter_por_id(id)
    Database.with_connection do |conn|
      result = conn.exec_params('SELECT * FROM visitantes WHERE id = $1 LIMIT 1', [id])
      row = result.first
      row ? row_para_visitante(row) : nil
    end
  end

  def obter_por_cpf(cpf)
    Database.with_connection do |conn|
      result = conn.exec_params('SELECT * FROM visitantes WHERE cpf = $1 LIMIT 1', [cpf])
      row = result.first
      row ? row_para_visitante(row) : nil
    end
  end

  def obter_por_email(email)
    Database.with_connection do |conn|
      result = conn.exec_params('SELECT * FROM visitantes WHERE lower(email) = lower($1) LIMIT 1', [email])
      row = result.first
      row ? row_para_visitante(row) : nil
    end
  end

  def obter_todos
    Database.with_connection do |conn|
      conn.exec('SELECT * FROM visitantes ORDER BY id').map { |row| row_para_visitante(row) }
    end
  end

  def deletar(id)
    Database.with_connection do |conn|
      conn.exec_params('DELETE FROM visitantes WHERE id = $1', [id])
    end
  end

  private

  def row_para_visitante(row)
    visitante = VisitanteModel.new(
      row['id'].to_i,
      row['nome'],
      row['cpf'],
      Date.parse(row['data_nascimento']),
      row['email'],
      row['tipo_ingresso'].to_sym,
      row['senha_hash']
    )
    visitante.reservas = JSON.parse(row['reservas'] || '[]')
    visitante
  end
end
