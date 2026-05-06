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
            <h3>Atracoes</h3>
            <div className="grid">
              {atracao.map(a => (
                <div key={a.id} className="card attraction-card">
                  <div className="attraction-image" aria-hidden="true">
                    <span>{a.tipo?.slice(0, 2).toUpperCase()}</span>
                  </div>
                  <h4>{a.nome}</h4>
                  <div className="meta-row">
                    <span>{a.tipo}</span>
                    <span>{a.idade_minima}+ anos</span>
                  </div>
                  <p><strong>Capacidade:</strong> {a.capacidade_por_sessao} pessoas</p>
                  <p><strong>Horarios:</strong> {a.horarios_disponiveis.join(', ')}</p>
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
            <h3>Visitantes</h3>
            <div style={{ overflowX: 'auto' }}>
              <table>
                <thead>
                  <tr>
                    <th>ID</th>
                    <th>Nome</th>
                    <th>CPF</th>
                    <th>Idade</th>
                    <th>Tipo Ingresso</th>
                  </tr>
                </thead>
                <tbody>
                  {visitantes.map(v => (
                    <tr key={v.id}>
                      <td>{v.id}</td>
                      <td>{v.nome}</td>
                      <td>{v.cpf}</td>
                      <td>{v.idade}</td>
                      <td>
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
            <h3>Filas Virtuais</h3>
            {fila ? (
              <div className="card queue-card">
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
                  <h5>Proximas Pessoas:</h5>
                  {fila.fila.slice(0, 10).map(item => (
                    <div key={item.reserva_id} className="list-item">
                      <div className="list-item-info">
                        <h4>{item.posicao}. {item.visitante_nome}</h4>
                        <p>Horario: {item.horario}</p>
                      </div>
                      <span className={`badge ${item.tipo_ingresso}`}>
                        {item.tipo_ingresso.toUpperCase()}
                      </span>
                    </div>
                  ))}
                </div>
              </div>
            ) : (
              <div className="card empty-state">
                <p>Selecione uma atracao para ver a fila.</p>
              </div>
            )}
          </div>
        )

      case 'estatistica':
        return (
          <div>
            <h3>Estatisticas</h3>
            {estatistica && (
              <div className="grid">
                <div className="card">
                  <h4>Total de Reservas</h4>
                  <p style={{ fontSize: '2rem', color: '#1769aa', fontWeight: 'bold' }}>
                    {estatistica.total_reservas}
                  </p>
                </div>

                {estatistica.atracao_mais_disputada && (
                  <div className="card">
                    <h4>Atracao Mais Disputada</h4>
                    <p>ID: {estatistica.atracao_mais_disputada.atracao_id}</p>
                    <p style={{ fontSize: '1.5rem', color: '#1769aa', fontWeight: 'bold' }}>
                      {estatistica.atracao_mais_disputada.quantidade_reservas} reservas
                    </p>
                  </div>
                )}

                {estatistica.visitante_mais_ativo && (
                  <div className="card">
                    <h4>Visitante Mais Ativo</h4>
                    <p>ID: {estatistica.visitante_mais_ativo.visitante_id}</p>
                    <p style={{ fontSize: '1.5rem', color: '#1769aa', fontWeight: 'bold' }}>
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
      <div className="header park-hero">
        <p className="eyebrow">Operacao do parque</p>
        <h1>Painel de Controle</h1>
        <p>Acompanhe atracoes, visitantes, filas virtuais e metricas do dia.</p>
        <button className="secondary" onClick={onVoltar} style={{ marginTop: '10px' }}>
          Voltar
        </button>
      </div>

      {erro && <div className="error">{erro}</div>}

      {carregando ? (
        <div className="loading">Carregando dados...</div>
      ) : (
        <>
          <div className="tabs">
            <button
              className={abaSelecionada === 'atracao' ? 'tab active' : 'tab'}
              onClick={() => setAbaSelecionada('atracao')}
            >
              Atracoes
            </button>
            <button
              className={abaSelecionada === 'visitante' ? 'tab active' : 'tab'}
              onClick={() => setAbaSelecionada('visitante')}
            >
              Visitantes
            </button>
            <button
              className={abaSelecionada === 'fila' ? 'tab active' : 'tab'}
              onClick={() => setAbaSelecionada('fila')}
            >
              Filas
            </button>
            <button
              className={abaSelecionada === 'estatistica' ? 'tab active' : 'tab'}
              onClick={() => setAbaSelecionada('estatistica')}
            >
              Estatisticas
            </button>
            <button className="secondary" onClick={carregarDados}>
              Atualizar
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
