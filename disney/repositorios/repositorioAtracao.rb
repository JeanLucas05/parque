require 'json'
require_relative 'database'

class RepositorioAtracao
  def initialize(_arquivo = nil)
    Database.criar_tabelas
  end

  def salvar(atracao)
    Database.with_connection do |conn|
      conn.exec_params(
        <<~SQL,
          INSERT INTO atracoes (
            id, nome, tipo, capacidade_por_sessao, idade_minima,
            horarios_disponiveis, passes_com_prioridade
          )
          VALUES ($1, $2, $3, $4, $5, $6::jsonb, $7::jsonb)
          ON CONFLICT (id) DO UPDATE SET
            nome = EXCLUDED.nome,
            tipo = EXCLUDED.tipo,
            capacidade_por_sessao = EXCLUDED.capacidade_por_sessao,
            idade_minima = EXCLUDED.idade_minima,
            horarios_disponiveis = EXCLUDED.horarios_disponiveis,
            passes_com_prioridade = EXCLUDED.passes_com_prioridade,
            updated_at = CURRENT_TIMESTAMP
        SQL
        [
          atracao.id,
          atracao.nome,
          atracao.tipo,
          atracao.capacidade_por_sessao,
          atracao.idade_minima,
          JSON.generate(atracao.horarios_disponiveis || []),
          JSON.generate(atracao.passes_com_prioridade || [])
        ]
      )
    end
  end

  def obter_por_id(id)
    Database.with_connection do |conn|
      result = conn.exec_params('SELECT * FROM atracoes WHERE id = $1 LIMIT 1', [id])
      row = result.first
      row ? row_para_atracao(row) : nil
    end
  end

  def obter_todas
    Database.with_connection do |conn|
      conn.exec('SELECT * FROM atracoes ORDER BY id').map { |row| row_para_atracao(row) }
    end
  end

  def deletar(id)
    Database.with_connection do |conn|
      conn.exec_params('DELETE FROM atracoes WHERE id = $1', [id])
    end
  end

  private

  def row_para_atracao(row)
    atracao = AtracaoModel.new(
      row['id'].to_i,
      row['nome'],
      row['tipo'],
      row['capacidade_por_sessao'].to_i,
      row['idade_minima'].to_i
    )
    atracao.horarios_disponiveis = JSON.parse(row['horarios_disponiveis'] || '[]')
    atracao.passes_com_prioridade = JSON.parse(row['passes_com_prioridade'] || '[]')
    atracao
  end
end
