import { useState, useEffect } from 'react'
import { getVisitanteById, getReservaByVisitante, getAtracao, createReserva } from '../services/api'

export default function PortalVisitante({ onVoltar }) {
  const [visitanteId, setVisitanteId] = useState('')
  const [visitanteLogado, setVisitanteLogado] = useState(null)
  const [atracao, setAtracao] = useState([])
  const [reservas, setReservas] = useState([])
  const [atracaoParaReserva, setAtracaoParaReserva] = useState(null)
  const [horarioSelecionado, setHorarioSelecionado] = useState('')
  const [carregando, setCarregando] = useState(false)
  const [erro, setErro] = useState(null)
  const [sucesso, setSucesso] = useState(null)
  const [abaSelecionada, setAbaSelecionada] = useState('atracao')

  useEffect(() => {
    carregarAtracao()
  }, [])

  const carregarAtracao = async () => {
    try {
      const data = await getAtracao()
      setAtracao(data)
    } catch (err) {
      setErro('Erro ao carregar atrações')
    }
  }

  const carregarReservasVisitante = async (id) => {
    const data = await getReservaByVisitante(id)
    setReservas(data)
    return data
  }

  const fazerLogin = async (e) => {
    e.preventDefault()
    setCarregando(true)
    setErro(null)
    setSucesso(null)

    try {
      const visitante = await getVisitanteById(parseInt(visitanteId))
      setVisitanteLogado(visitante)
      
      await carregarReservasVisitante(parseInt(visitanteId))
      
      setSucesso(`Bem-vindo, ${visitante.nome}!`)
    } catch (err) {
      setErro('Visitante não encontrado')
    } finally {
      setCarregando(false)
    }
  }

  const fazerReserva = async (e) => {
    e.preventDefault()
    if (!atracaoParaReserva || !horarioSelecionado) {
      setErro('Selecione uma atração e um horário')
      return
    }

    setCarregando(true)
    setErro(null)
    setSucesso(null)

    try {
      await createReserva({
        visitante_id: visitanteLogado.id,
        atracao_id: atracaoParaReserva,
        horario: horarioSelecionado
      })

      setSucesso('Reserva criada com sucesso!')
      setAtracaoParaReserva(null)
      setHorarioSelecionado('')

      await carregarReservasVisitante(visitanteLogado.id)
    } catch (err) {
      setErro(err.response?.data?.erro || 'Erro ao criar reserva')
    } finally {
      setCarregando(false)
    }
  }

  if (!visitanteLogado) {
    return (
      <>
        <div className="header">
          <h1>👤 Portal do Visitante</h1>
          <button 
            className="secondary"
            onClick={onVoltar}
            style={{ marginTop: '10px' }}
          >
            ← Voltar
          </button>
        </div>

        <div className="card" style={{ maxWidth: '500px', margin: '0 auto' }}>
          <h3>Login</h3>
          
          {erro && <div className="error">{erro}</div>}
          {sucesso && <div className="success">{sucesso}</div>}

          <form onSubmit={fazerLogin}>
            <label>
              <strong>ID do Visitante:</strong>
            </label>
            <input
              type="number"
              value={visitanteId}
              onChange={(e) => setVisitanteId(e.target.value)}
              placeholder="Digite seu ID"
              min="1"
              required
            />
            <button 
              type="submit" 
              className="primary"
              disabled={carregando}
              style={{ width: '100%' }}
            >
              {carregando ? 'Entrando...' : 'Entrar'}
            </button>
          </form>

          <p style={{ marginTop: '20px', color: '#666' }}>
            💡 Dica: IDs de exemplo: 1, 2, 3, 4, 5
          </p>
        </div>
      </>
    )
  }

  return (
    <>
      <div className="header">
        <h1>👤 {visitanteLogado.nome}</h1>
        <p>Tipo: <span className={`badge ${visitanteLogado.tipo_ingresso}`}>
          {visitanteLogado.tipo_ingresso.toUpperCase()}
        </span> | Idade: {visitanteLogado.idade} anos</p>
        <div style={{ marginTop: '10px' }}>
          <button 
            className="secondary"
            onClick={() => {
              setVisitanteLogado(null)
              setVisitanteId('')
              setReservas([])
            }}
            style={{ marginRight: '10px' }}
          >
            Logout
          </button>
          <button 
            className="secondary"
            onClick={onVoltar}
          >
            ← Voltar
          </button>
        </div>
      </div>

      {erro && <div className="error">{erro}</div>}
      {sucesso && <div className="success">{sucesso}</div>}

      <div style={{ marginBottom: '20px', display: 'flex', gap: '10px' }}>
        <button 
          className={abaSelecionada === 'atracao' ? 'primary' : 'secondary'}
          onClick={() => setAbaSelecionada('atracao')}
        >
          🎢 Atrações
        </button>
        <button 
          className={abaSelecionada === 'reservas' ? 'primary' : 'secondary'}
          onClick={() => setAbaSelecionada('reservas')}
        >
          📋 Na Fila ({reservas.filter(r => r.status === 'aguardando').length})
        </button>
        <button 
          className={abaSelecionada === 'historico' ? 'primary' : 'secondary'}
          onClick={() => setAbaSelecionada('historico')}
        >
          Historico ({reservas.filter(r => r.status !== 'aguardando').length})
        </button>
      </div>

      {abaSelecionada === 'atracao' ? (
        <>
          <div className="grid">
            {atracao.map(a => {
              const idadeOk = visitanteLogado.idade >= a.idade_minima
              return (
                <div key={a.id} className="card">
                  <h4>{a.nome} {idadeOk ? '✅' : '❌'}</h4>
                  <p><strong>Tipo:</strong> {a.tipo}</p>
                  <p><strong>Capacidade:</strong> {a.capacidade_por_sessao}/sessão</p>
                  <p><strong>Idade Mínima:</strong> {a.idade_minima}+</p>
                  <button 
                    className={idadeOk ? 'primary' : 'secondary'}
                    disabled={!idadeOk}
                    onClick={() => setAtracaoParaReserva(a.id)}
                    style={{ width: '100%', marginTop: '10px' }}
                  >
                    {idadeOk ? 'Reservar' : 'Não pode acessar'}
                  </button>
                </div>
              )
            })}
          </div>

          {atracaoParaReserva && (
            <div className="card" style={{ marginTop: '20px', maxWidth: '500px' }}>
              <h4>Nova Reserva</h4>
              <p><strong>Atração:</strong> {atracao.find(a => a.id === atracaoParaReserva)?.nome}</p>
              
              <form onSubmit={fazerReserva}>
                <label><strong>Horário:</strong></label>
                <select 
                  value={horarioSelecionado}
                  onChange={(e) => setHorarioSelecionado(e.target.value)}
                  required
                >
                  <option value="">Selecione um horário</option>
                  {atracao.find(a => a.id === atracaoParaReserva)?.horarios_disponiveis.map(h => (
                    <option key={h} value={h}>{h}</option>
                  ))}
                </select>
                
                <button 
                  type="submit"
                  className="primary"
                  disabled={carregando}
                  style={{ width: '100%' }}
                >
                  {carregando ? 'Reservando...' : 'Confirmar Reserva'}
                </button>
                <button 
                  type="button"
                  className="secondary"
                  onClick={() => setAtracaoParaReserva(null)}
                  style={{ width: '100%', marginTop: '10px' }}
                >
                  Cancelar
                </button>
              </form>
            </div>
          )}
        </>
      ) : abaSelecionada === 'reservas' ? (
        <>
          <div className="grid">
            {reservas.filter(r => r.status === 'aguardando').map(r => {
              const atracaoInfo = atracao.find(a => a.id === r.atracao_id)
              return (
                <div key={r.id} className="card">
                  <h4>{r.atracao_nome || atracaoInfo?.nome}</h4>
                  <p><strong>Horário:</strong> {r.horario}</p>
                  <p><strong>Posição na Fila:</strong> {r.posicao_na_fila || 'Carregando...'}</p>
                  <p><strong>Status:</strong> {r.status}</p>
                </div>
              )
            })}
          </div>
          {reservas.filter(r => r.status === 'aguardando').length === 0 && (
            <div className="card" style={{ textAlign: 'center', color: '#666' }}>
              <p>Você não tem reservas ativas</p>
            </div>
          )}
        </>
      ) : (
        <>
          <div className="grid">
            {reservas.filter(r => r.status !== 'aguardando').map(r => {
              const atracaoInfo = atracao.find(a => a.id === r.atracao_id)
              return (
                <div key={r.id} className="card">
                  <h4>{r.atracao_nome || atracaoInfo?.nome}</h4>
                  <p><strong>Horario:</strong> {r.horario}</p>
                  <p><strong>Data:</strong> {r.data_reserva}</p>
                  <p><strong>Status:</strong> {r.status}</p>
                </div>
              )
            })}
          </div>
          {reservas.filter(r => r.status !== 'aguardando').length === 0 && (
            <div className="card" style={{ textAlign: 'center', color: '#666' }}>
              <p>Nenhum historico de visitas ainda</p>
            </div>
          )}
        </>
      )}
    </>
  )
}
