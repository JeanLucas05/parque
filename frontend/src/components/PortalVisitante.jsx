import { useState, useEffect, useRef } from 'react'
import { loginVisitante, getReservaByVisitante, getAtracao, createReserva } from '../services/api'

export default function PortalVisitante({ onVoltar }) {
  const [email, setEmail] = useState('')
  const [senha, setSenha] = useState('')
  const [visitanteLogado, setVisitanteLogado] = useState(null)
  const [atracao, setAtracao] = useState([])
  const [reservas, setReservas] = useState([])
  const [atracaoParaReserva, setAtracaoParaReserva] = useState(null)
  const [horarioSelecionado, setHorarioSelecionado] = useState('')
  const [carregando, setCarregando] = useState(false)
  const [erro, setErro] = useState(null)
  const [sucesso, setSucesso] = useState(null)
  const [abaSelecionada, setAbaSelecionada] = useState('atracao')
  const reservaRef = useRef(null)

  useEffect(() => {
    carregarAtracao()
  }, [])

  useEffect(() => {
    if (atracaoParaReserva && reservaRef.current) {
      reservaRef.current.scrollIntoView({ behavior: 'smooth', block: 'start' })
    }
  }, [atracaoParaReserva])

  const carregarAtracao = async () => {
    try {
      const data = await getAtracao()
      setAtracao(data)
    } catch (err) {
      setErro('Erro ao carregar atracoes')
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
      const visitante = await loginVisitante(email, senha)
      setVisitanteLogado(visitante)
      await carregarReservasVisitante(visitante.id)
      setSucesso(`Bem-vindo, ${visitante.nome}!`)
    } catch (err) {
      setErro(err.response?.data?.erro || 'E-mail ou senha invalidos')
    } finally {
      setCarregando(false)
    }
  }

  const selecionarAtracao = (atracaoId) => {
    setAtracaoParaReserva(atracaoId)
    setHorarioSelecionado('')
    setErro(null)
    setSucesso(null)
  }

  const fazerReserva = async (e) => {
    e.preventDefault()
    if (!atracaoParaReserva || !horarioSelecionado) {
      setErro('Selecione uma atracao e um horario')
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
        <div className="header park-hero">
          <p className="eyebrow">Entrada do visitante</p>
          <h1>Portal do Visitante</h1>
          <p>Entre com e-mail e senha para reservar seu lugar nas atracoes do parque.</p>
          <button className="secondary" onClick={onVoltar} style={{ marginTop: '10px' }}>
            Voltar
          </button>
        </div>

        <div className="card login-card" style={{ maxWidth: '500px', margin: '0 auto' }}>
          <h3>Login</h3>

          {erro && <div className="error">{erro}</div>}
          {sucesso && <div className="success">{sucesso}</div>}

          <form onSubmit={fazerLogin}>
            <label>
              <strong>E-mail:</strong>
            </label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="Digite seu e-mail"
              required
            />

            <label>
              <strong>Senha:</strong>
            </label>
            <input
              type="password"
              value={senha}
              onChange={(e) => setSenha(e.target.value)}
              placeholder="Digite sua senha"
              required
            />

            <button type="submit" className="primary" disabled={carregando} style={{ width: '100%' }}>
              {carregando ? 'Entrando...' : 'Entrar'}
            </button>
          </form>

          <p className="helper-text">Dica: use joao@email.com com senha 1234 para testar.</p>
        </div>
      </>
    )
  }

  const reservasAtivas = reservas.filter(r => r.status === 'aguardando')
  const historico = reservas.filter(r => r.status !== 'aguardando')
  const atracaoSelecionada = atracao.find(a => a.id === atracaoParaReserva)

  return (
    <>
      <div className="header park-hero">
        <p className="eyebrow">Portal do visitante</p>
        <h1>{visitanteLogado.nome}</h1>
        <p>
          Tipo: <span className={`badge ${visitanteLogado.tipo_ingresso}`}>
            {visitanteLogado.tipo_ingresso.toUpperCase()}
          </span> | Idade: {visitanteLogado.idade} anos
        </p>
        <div style={{ marginTop: '10px' }}>
          <button
            className="secondary"
            onClick={() => {
              setVisitanteLogado(null)
              setEmail('')
              setSenha('')
              setReservas([])
            }}
            style={{ marginRight: '10px' }}
          >
            Logout
          </button>
          <button className="secondary" onClick={onVoltar}>
            Voltar
          </button>
        </div>
      </div>

      {erro && <div className="error">{erro}</div>}
      {sucesso && <div className="success">{sucesso}</div>}

      <div className="tabs">
        <button
          className={abaSelecionada === 'atracao' ? 'tab active' : 'tab'}
          onClick={() => setAbaSelecionada('atracao')}
        >
          Atracoes
        </button>
        <button
          className={abaSelecionada === 'reservas' ? 'tab active' : 'tab'}
          onClick={() => setAbaSelecionada('reservas')}
        >
          Na Fila ({reservasAtivas.length})
        </button>
        <button
          className={abaSelecionada === 'historico' ? 'tab active' : 'tab'}
          onClick={() => setAbaSelecionada('historico')}
        >
          Historico ({historico.length})
        </button>
      </div>

      {abaSelecionada === 'atracao' ? (
        <>
          <div className="grid">
            {atracao.map(a => {
              const idadeOk = visitanteLogado.idade >= a.idade_minima
              return (
                <div key={a.id} className={`card attraction-card ${atracaoParaReserva === a.id ? 'selected' : ''}`}>
                  <div className="attraction-image" aria-hidden="true">
                    <span>{a.tipo?.slice(0, 2).toUpperCase()}</span>
                  </div>
                  <h4>{a.nome}</h4>
                  <div className="meta-row">
                    <span>{a.tipo}</span>
                    <span>{a.idade_minima}+ anos</span>
                  </div>
                  <p><strong>Capacidade:</strong> {a.capacidade_por_sessao}/sessao</p>
                  <p><strong>Horarios:</strong> {a.horarios_disponiveis?.join(', ')}</p>
                  {a.passes_com_prioridade?.length > 0 && (
                    <p><strong>Prioridade:</strong> {a.passes_com_prioridade.join(', ')}</p>
                  )}
                  <button
                    className={idadeOk ? 'primary' : 'secondary'}
                    disabled={!idadeOk}
                    onClick={() => selecionarAtracao(a.id)}
                    style={{ width: '100%', marginTop: '10px' }}
                  >
                    {idadeOk ? 'Reservar horario' : 'Nao pode acessar'}
                  </button>
                </div>
              )
            })}
          </div>

          {atracaoParaReserva && (
            <div ref={reservaRef} className="card reservation-panel" style={{ marginTop: '20px', maxWidth: '640px' }}>
              <p className="eyebrow">Escolha o horario</p>
              <h4>Nova Reserva</h4>
              <p><strong>Atracao:</strong> {atracaoSelecionada?.nome}</p>

              <form onSubmit={fazerReserva}>
                <label><strong>Horario:</strong></label>
                <select
                  value={horarioSelecionado}
                  onChange={(e) => setHorarioSelecionado(e.target.value)}
                  required
                >
                  <option value="">Selecione um horario</option>
                  {atracaoSelecionada?.horarios_disponiveis.map(h => (
                    <option key={h} value={h}>{h}</option>
                  ))}
                </select>

                <button type="submit" className="primary" disabled={carregando} style={{ width: '100%' }}>
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
            {reservasAtivas.map(r => (
              <div key={r.id} className="card queue-card">
                <h4>{r.atracao_nome || atracao.find(a => a.id === r.atracao_id)?.nome}</h4>
                <p><strong>Horario:</strong> {r.horario}</p>
                <p><strong>Posicao na Fila:</strong> {r.posicao_na_fila || 'Carregando...'}</p>
                <p><strong>Status:</strong> {r.status}</p>
              </div>
            ))}
          </div>
          {reservasAtivas.length === 0 && (
            <div className="card empty-state">
              <p>Voce nao tem reservas ativas</p>
            </div>
          )}
        </>
      ) : (
        <>
          <div className="grid">
            {historico.map(r => (
              <div key={r.id} className="card queue-card">
                <h4>{r.atracao_nome || atracao.find(a => a.id === r.atracao_id)?.nome}</h4>
                <p><strong>Horario:</strong> {r.horario}</p>
                <p><strong>Data:</strong> {r.data_reserva}</p>
                <p><strong>Status:</strong> {r.status}</p>
              </div>
            ))}
          </div>
          {historico.length === 0 && (
            <div className="card empty-state">
              <p>Nenhum historico de visitas ainda</p>
            </div>
          )}
        </>
      )}
    </>
  )
}
