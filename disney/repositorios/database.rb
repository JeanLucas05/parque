require 'pg'

module Database
  module_function

  def url
    ENV.fetch('DATABASE_URL') do
      'postgresql://disney_user:disney_pass_2026@localhost:5432/disney_db'
    end
  end

  def with_connection
    connection = PG.connect(url)
    yield connection
  ensure
    connection&.close
  end

  def criar_tabelas
    with_connection do |conn|
      conn.exec('SET client_min_messages TO warning')
      conn.exec <<~SQL
        CREATE TABLE IF NOT EXISTS atracoes (
          id INTEGER PRIMARY KEY,
          nome TEXT NOT NULL,
          tipo TEXT NOT NULL,
          capacidade_por_sessao INTEGER NOT NULL,
          idade_minima INTEGER NOT NULL,
          horarios_disponiveis JSONB NOT NULL DEFAULT '[]'::jsonb,
          passes_com_prioridade JSONB NOT NULL DEFAULT '[]'::jsonb,
          created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        );

        CREATE TABLE IF NOT EXISTS visitantes (
          id INTEGER PRIMARY KEY,
          nome TEXT NOT NULL,
          cpf TEXT NOT NULL UNIQUE,
          data_nascimento DATE NOT NULL,
          email TEXT NOT NULL UNIQUE,
          senha_hash TEXT NOT NULL DEFAULT '',
          tipo_ingresso TEXT NOT NULL,
          reservas JSONB NOT NULL DEFAULT '[]'::jsonb,
          created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        );

        CREATE TABLE IF NOT EXISTS reservas (
          id INTEGER PRIMARY KEY,
          visitante_id INTEGER NOT NULL REFERENCES visitantes(id) ON DELETE CASCADE,
          atracao_id INTEGER NOT NULL REFERENCES atracoes(id) ON DELETE CASCADE,
          horario TEXT NOT NULL,
          status TEXT NOT NULL DEFAULT 'aguardando',
          posicao_na_fila INTEGER,
          prioridade INTEGER,
          data_reserva DATE NOT NULL DEFAULT CURRENT_DATE,
          created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        );
      SQL

      conn.exec("ALTER TABLE visitantes ADD COLUMN IF NOT EXISTS senha_hash TEXT NOT NULL DEFAULT ''")
      conn.exec("CREATE UNIQUE INDEX IF NOT EXISTS visitantes_email_unique ON visitantes (email)")
    end
  end
end
