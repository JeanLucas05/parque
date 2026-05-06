import { useState, useEffect } from 'react'
import { getAtracao, getVisitante, getReserva, getEstatisticaDiaria, getFila, avancarFila } from '../services/api'

export default function PainelAdministrador({ onVoltar }) {
  const [abaSelecionada, setAbaSelecionada] = useState('atracao')
  const [atracao, setAtracao] = useState([])
  const [visitantes, setVisitantes] = useState([])
  const [reservas, setReservas] = useState([])
  const [estatistica, setEstatistica] = useState(null)
  const [fila, setFila] = useState(null)
  const [atracaoSelecionada, setAtracaoSelecionada] = useState(null)
  const [carregando, setCarregando] = useState(false)
  const [erro, setErro] = useState(null)

  useEffect(() => {
    carregarDados()
  }, [])

  const carregarDados = async () => {
    setCarregando(true)
    setErro(null)
    try {
      const [atracaoData, visitanteData, reservaData, estatisticaData] = await Promise.all([
        getAtracao(),
        getVisitante(),
        getReserva(),
        getEstatisticaDiaria()
      ])
      setAtracao(atracaoData)
      setVisitantes(visitanteData)
      setReservas(reservaData)
      setEstatistica(estatisticaData)
    } catch (err) {
      setErro('Erro ao carregar dados: ' + err.message)
    } finally {
      setCarregando(false)
    }
  }

  const carregarFila = async (atracaoId) => {
    try {
      const filaData = await getFila(atracaoId)
      setFila(filaData)
      setAtracaoSelecionada(atracaoId)
    } catch (err) {
      setErro('Erro ao carregar fila: ' + err.message)
    }
  }

  const atenderProximo = async () => {
    if (!atracaoSelecionada) return

    try {
      await avancarFila(atracaoSelecionada, 1)
      await carregarFila(atracaoSelecionada)
      await carregarDados()
    } catch (err) {
      setErro('Erro ao avancar fila: ' + err.message)
    }
  }

  const totalReservasPorAtracao = (atracaoId) => {
    return reservas.filter(r => r.atracao_id === atracaoId).length
  }

  const totalNaFilaPorAtracao = (atracaoId) => {
    return reservas.filter(r => r.atracao_id === atracaoId && r.status === 'aguardando').length
  }

  const renderAba = () => {
    switch (abaSelecionada) {
      case 'atracao':
        return (
          <div>
            <h3>🎢 Atrações</h3>
            <div className="grid">
              {atracao.map(a => (
                <div key={a.id} className="card">
                  <h4>{a.nome}</h4>
                  <p><strong>Tipo:</strong> {a.tipo}</p>
                  <p><strong>Capacidade:</strong> {a.capacidade_por_sessao} pessoas</p>
                  <p><strong>Idade Mínima:</strong> {a.idade_minima}+</p>
                  <p><strong>Horários:</strong> {a.horarios_disponiveis.join(', ')}</p>
                  <p><strong>Visitantes na fila:</strong> {totalNaFilaPorAtracao(a.id)}</p>
                  <p><strong>Reservas do dia:</strong> {totalReservasPorAtracao(a.id)}</p>
                  <button 
                    className="secondary"
                    onClick={() => {
                      setAbaSelecionada('fila')
                      carregarFila(a.id)
                    }}
                    style={{ width: '100%', marginTop: '10px' }}
                  >
                    Ver Fila
                  </button>
                </div>
              ))}
            </div>
          </div>
        )

      case 'visitante':
        return (
          <div>
            <h3>👥 Visitantes</h3>
            <div style={{ overflowX: 'auto' }}>
              <table style={{ width: '100%', borderCollapse: 'collapse' }}>
                <thead>
                  <tr style={{ background: '#f0f0f0' }}>
                    <th style={{ padding: '10px', textAlign: 'left', borderBottom: '2px solid #ccc' }}>ID</th>
                    <th style={{ padding: '10px', textAlign: 'left', borderBottom: '2px solid #ccc' }}>Nome</th>
                    <th style={{ padding: '10px', textAlign: 'left', borderBottom: '2px solid #ccc' }}>CPF</th>
                    <th style={{ padding: '10px', textAlign: 'left', borderBottom: '2px solid #ccc' }}>Idade</th>
                    <th style={{ padding: '10px', textAlign: 'left', borderBottom: '2px solid #ccc' }}>Tipo Ingresso</th>
                  </tr>
                </thead>
                <tbody>
                  {visitantes.map(v => (
                    <tr key={v.id} style={{ borderBottom: '1px solid #eee' }}>
                      <td style={{ padding: '10px' }}>{v.id}</td>
                      <td style={{ padding: '10px' }}>{v.nome}</td>
                      <td style={{ padding: '10px' }}>{v.cpf}</td>
                      <td style={{ padding: '10px' }}>{v.idade}</td>
                      <td style={{ padding: '10px' }}>
                        <span className={`badge ${v.tipo_ingresso}`}>
                          {v.tipo_ingresso.toUpperCase()}
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )

      case 'fila':
        return (
          <div>
            <h3>⏳ Filas Virtuais</h3>
            {fila ? (
              <div className="card">
                <h4>{fila.atracao_nome}</h4>
                <p><strong>Total na Fila:</strong> {fila.total_na_fila}</p>
                <button
                  className="primary"
                  onClick={atenderProximo}
                  disabled={fila.total_na_fila === 0}
                  style={{ width: '100%', marginBottom: '10px' }}
                >
                  Atender proximo visitante
                </button>
                <div>
                  <h5>Próximas Pessoas:</h5>
                  {fila.fila.slice(0, 10).map(item => (
                    <div key={item.reserva_id} style={{ padding: '10px', background: '#f9f9f9', margin: '5px 0', borderRadius: '4px' }}>
                      <p><strong>{item.posicao}.</strong> {item.visitante_nome}</p>
                      <p>Horário: {item.horario} | 
                        <span className={`badge ${item.tipo_ingresso}`}>
                          {item.tipo_ingresso.toUpperCase()}
                        </span>
                      </p>
                    </div>
                  ))}
                </div>
              </div>
            ) : (
              <p>Selecione uma atração acima para ver a fila</p>
            )}
          </div>
        )

      case 'estatistica':
        return (
          <div>
            <h3>📊 Estatísticas</h3>
            {estatistica && (
              <div className="grid">
                <div className="card">
                  <h4>Total de Reservas</h4>
                  <p style={{ fontSize: '2rem', color: '#667eea', fontWeight: 'bold' }}>
                    {estatistica.total_reservas}
                  </p>
                </div>

                {estatistica.atracao_mais_disputada && (
                  <div className="card">
                    <h4>Atração Mais Disputada</h4>
                    <p>ID: {estatistica.atracao_mais_disputada.atracao_id}</p>
                    <p style={{ fontSize: '1.5rem', color: '#667eea', fontWeight: 'bold' }}>
                      {estatistica.atracao_mais_disputada.quantidade_reservas} reservas
                    </p>
                  </div>
                )}

                {estatistica.visitante_mais_ativo && (
                  <div className="card">
                    <h4>Visitante Mais Ativo</h4>
                    <p>ID: {estatistica.visitante_mais_ativo.visitante_id}</p>
                    <p style={{ fontSize: '1.5rem', color: '#667eea', fontWeight: 'bold' }}>
                      {estatistica.visitante_mais_ativo.quantidade_reservas} reservas
                    </p>
                  </div>
                )}
              </div>
            )}
          </div>
        )

      default:
        return null
    }
  }

  return (
    <>
      <div className="header">
        <h1>🎯 Painel de Controle</h1>
        <button 
          className="secondary"
          onClick={onVoltar}
          style={{ marginTop: '10px' }}
        >
          ← Voltar
        </button>
      </div>

      {erro && <div className="error">{erro}</div>}

      {carregando ? (
        <div className="loading">Carregando dados...</div>
      ) : (
        <>
          <div style={{ marginBottom: '20px', display: 'flex', gap: '10px', flexWrap: 'wrap' }}>
            <button 
              className={abaSelecionada === 'atracao' ? 'primary' : 'secondary'}
              onClick={() => setAbaSelecionada('atracao')}
            >
              🎢 Atrações
            </button>
            <button 
              className={abaSelecionada === 'visitante' ? 'primary' : 'secondary'}
              onClick={() => setAbaSelecionada('visitante')}
            >
              👥 Visitantes
            </button>
            <button 
              className={abaSelecionada === 'fila' ? 'primary' : 'secondary'}
              onClick={() => setAbaSelecionada('fila')}
            >
              ⏳ Filas
            </button>
            <button 
              className={abaSelecionada === 'estatistica' ? 'primary' : 'secondary'}
              onClick={() => setAbaSelecionada('estatistica')}
            >
              📊 Estatísticas
            </button>
            <button 
              className="secondary"
              onClick={carregarDados}
              style={{ marginLeft: 'auto' }}
            >
              🔄 Atualizar
            </button>
          </div>

          <div className="card">
            {renderAba()}
          </div>
        </>
      )}
    </>
  )
}
