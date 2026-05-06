require 'date'
require_relative 'database'

class RepositorioReserva
  def initialize(_arquivo = nil)
    Database.criar_tabelas
  end

  def salvar(reserva)
    visitante_id = reserva.visitante_id || reserva.visitante&.id
    atracao_id = reserva.atracao_id || reserva.atracao&.id

    Database.with_connection do |conn|
      conn.exec_params(
        <<~SQL,
          INSERT INTO reservas (
            id, visitante_id, atracao_id, horario, status,
            posicao_na_fila, prioridade, data_reserva
          )
          VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
          ON CONFLICT (id) DO UPDATE SET
            visitante_id = EXCLUDED.visitante_id,
            atracao_id = EXCLUDED.atracao_id,
            horario = EXCLUDED.horario,
            status = EXCLUDED.status,
            posicao_na_fila = EXCLUDED.posicao_na_fila,
            prioridade = EXCLUDED.prioridade,
            data_reserva = EXCLUDED.data_reserva,
            updated_at = CURRENT_TIMESTAMP
        SQL
        [
          reserva.id,
          visitante_id,
          atracao_id,
          reserva.horario.to_s,
          reserva.status,
          reserva.posicao_na_fila,
          reserva.prioridade,
          (reserva.data_reserva || Date.today).to_s
        ]
      )
    end
  end

  def obter_por_id(id)
    Database.with_connection do |conn|
      result = conn.exec_params('SELECT * FROM reservas WHERE id = $1 LIMIT 1', [id])
      row = result.first
      row ? row_para_reserva(row) : nil
    end
  end

  def obter_por_visitante(visitante_id)
    Database.with_connection do |conn|
      conn.exec_params(
        'SELECT * FROM reservas WHERE visitante_id = $1 ORDER BY prioridade NULLS LAST, id',
        [visitante_id]
      ).map { |row| row_para_reserva(row) }
    end
  end

  def obter_por_atracao(atracao_id)
    Database.with_connection do |conn|
      conn.exec_params(
        'SELECT * FROM reservas WHERE atracao_id = $1 ORDER BY prioridade NULLS LAST, id',
        [atracao_id]
      ).map { |row| row_para_reserva(row) }
    end
  end

  def obter_fila_ativa_por_atracao(atracao_id)
    Database.with_connection do |conn|
      conn.exec_params(
        <<~SQL,
          SELECT * FROM reservas
          WHERE atracao_id = $1 AND status = 'aguardando'
          ORDER BY prioridade NULLS LAST, id
        SQL
        [atracao_id]
      ).map { |row| row_para_reserva(row) }
    end
  end

  def obter_todas
    Database.with_connection do |conn|
      conn.exec('SELECT * FROM reservas ORDER BY id').map { |row| row_para_reserva(row) }
    end
  end

  def obter_por_data(data)
    Database.with_connection do |conn|
      conn.exec_params(
        'SELECT * FROM reservas WHERE data_reserva = $1 ORDER BY id',
        [data.to_s]
      ).map { |row| row_para_reserva(row) }
    end
  end

  def deletar(id)
    Database.with_connection do |conn|
      conn.exec_params('DELETE FROM reservas WHERE id = $1', [id])
    end
  end

  def atualizar_status(id, status)
    Database.with_connection do |conn|
      result = conn.exec_params(
        <<~SQL,
          UPDATE reservas
          SET status = $2, updated_at = CURRENT_TIMESTAMP
          WHERE id = $1
          RETURNING *
        SQL
        [id, status]
      )
      row = result.first
      row ? row_para_reserva(row) : nil
    end
  end

  private

  def row_para_reserva(row)
    reserva = ReservaModel.new(
      row['id'].to_i,
      nil,
      nil,
      row['horario'],
      row['status'],
      row['posicao_na_fila']&.to_i,
      row['prioridade']&.to_i
    )
    reserva.visitante_id = row['visitante_id'].to_i
    reserva.atracao_id = row['atracao_id'].to_i
    reserva.data_reserva = Date.parse(row['data_reserva'])
    reserva
  end
end
