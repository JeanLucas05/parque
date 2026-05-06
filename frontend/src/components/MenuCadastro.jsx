import { useState } from 'react'
import { createAtracao, createVisitante } from '../services/api'

export default function MenuCadastro({ onVoltar }) {
  const [abaSelecionada, setAbaSelecionada] = useState('atracao')
  const [carregando, setCarregando] = useState(false)
  const [erro, setErro] = useState(null)
  const [sucesso, setSucesso] = useState(null)

  const [atracaoForm, setAtracaoForm] = useState({
    nome: '',
    tipo: 'montanha-russa',
    capacidade_por_sessao: '',
    idade_minima: '',
    horarios_disponiveis: '',
    passes_com_prioridade: ''
  })

  const [visitanteForm, setVisitanteForm] = useState({
    nome: '',
    cpf: '',
    data_nascimento: '',
    email: '',
    senha: '',
    tipo_ingresso: 'normal'
  })

  const handleAtracaoChange = (e) => {
    const { name, value } = e.target
    setAtracaoForm(prev => ({ ...prev, [name]: value }))
  }

  const handleVisitanteChange = (e) => {
    const { name, value } = e.target
    setVisitanteForm(prev => ({ ...prev, [name]: value }))
  }

  const handleAtracaoSubmit = async (e) => {
    e.preventDefault()
    setCarregando(true)
    setErro(null)
    setSucesso(null)

    try {
      const horarios = atracaoForm.horarios_disponiveis.split(',').map(h => h.trim()).filter(Boolean)
      const passes = atracaoForm.passes_com_prioridade.split(',').map(p => p.trim()).filter(Boolean)

      await createAtracao({
        nome: atracaoForm.nome,
        tipo: atracaoForm.tipo,
        capacidade_por_sessao: parseInt(atracaoForm.capacidade_por_sessao),
        idade_minima: parseInt(atracaoForm.idade_minima),
        horarios_disponiveis: horarios,
        passes_com_prioridade: passes
      })

      setSucesso('Atracao criada com sucesso!')
      setAtracaoForm({
        nome: '',
        tipo: 'montanha-russa',
        capacidade_por_sessao: '',
        idade_minima: '',
        horarios_disponiveis: '',
        passes_com_prioridade: ''
      })
    } catch (err) {
      setErro('Erro ao criar atracao: ' + err.message)
    } finally {
      setCarregando(false)
    }
  }

  const handleVisitanteSubmit = async (e) => {
    e.preventDefault()
    setCarregando(true)
    setErro(null)
    setSucesso(null)

    try {
      await createVisitante({
        nome: visitanteForm.nome,
        cpf: visitanteForm.cpf,
        data_nascimento: visitanteForm.data_nascimento,
        email: visitanteForm.email,
        senha: visitanteForm.senha,
        tipo_ingresso: visitanteForm.tipo_ingresso
      })

      setSucesso('Visitante criado com sucesso!')
      setVisitanteForm({
        nome: '',
        cpf: '',
        data_nascimento: '',
        email: '',
        senha: '',
        tipo_ingresso: 'normal'
      })
    } catch (err) {
      setErro('Erro ao criar visitante: ' + err.message)
    } finally {
      setCarregando(false)
    }
  }

  return (
    <>
      <div className="header park-hero">
        <p className="eyebrow">Cadastros</p>
        <h1>Novos registros</h1>
        <p>Cadastre atracoes com horarios e visitantes com e-mail, senha e tipo de ingresso.</p>
        <button className="secondary" onClick={onVoltar} style={{ marginTop: '10px' }}>
          Voltar
        </button>
      </div>

      {erro && <div className="error">{erro}</div>}
      {sucesso && <div className="success">{sucesso}</div>}

      <div className="tabs">
        <button
          className={abaSelecionada === 'atracao' ? 'tab active' : 'tab'}
          onClick={() => setAbaSelecionada('atracao')}
        >
          Cadastrar Atracao
        </button>
        <button
          className={abaSelecionada === 'visitante' ? 'tab active' : 'tab'}
          onClick={() => setAbaSelecionada('visitante')}
        >
          Cadastrar Visitante
        </button>
      </div>

      {abaSelecionada === 'atracao' ? (
        <div className="card" style={{ maxWidth: '680px' }}>
          <h3>Cadastrar Nova Atracao</h3>
          <form onSubmit={handleAtracaoSubmit}>
            <label><strong>Nome da Atracao:</strong></label>
            <input
              type="text"
              name="nome"
              value={atracaoForm.nome}
              onChange={handleAtracaoChange}
              placeholder="Ex: Space Mountain"
              required
            />

            <label><strong>Tipo:</strong></label>
            <select name="tipo" value={atracaoForm.tipo} onChange={handleAtracaoChange}>
              <option value="montanha-russa">Montanha-russa</option>
              <option value="simulador">Simulador</option>
              <option value="teatro">Teatro</option>
              <option value="brinquedo infantil">Brinquedo infantil</option>
            </select>

            <div className="form-row">
              <div>
                <label><strong>Capacidade por Sessao:</strong></label>
                <input
                  type="number"
                  name="capacidade_por_sessao"
                  value={atracaoForm.capacidade_por_sessao}
                  onChange={handleAtracaoChange}
                  placeholder="Ex: 50"
                  required
                />
              </div>
              <div>
                <label><strong>Idade Minima:</strong></label>
                <input
                  type="number"
                  name="idade_minima"
                  value={atracaoForm.idade_minima}
                  onChange={handleAtracaoChange}
                  placeholder="Ex: 10"
                  required
                />
              </div>
            </div>

            <label><strong>Horarios Disponiveis:</strong></label>
            <input
              type="text"
              name="horarios_disponiveis"
              value={atracaoForm.horarios_disponiveis}
              onChange={handleAtracaoChange}
              placeholder="Ex: 09:00, 10:30, 12:00"
              required
            />

            <label><strong>Passes com Prioridade:</strong></label>
            <input
              type="text"
              name="passes_com_prioridade"
              value={atracaoForm.passes_com_prioridade}
              onChange={handleAtracaoChange}
              placeholder="Ex: vip, anual"
            />

            <button type="submit" className="primary" disabled={carregando} style={{ width: '100%' }}>
              {carregando ? 'Criando...' : 'Criar Atracao'}
            </button>
          </form>
        </div>
      ) : (
        <div className="card" style={{ maxWidth: '680px' }}>
          <h3>Cadastrar Novo Visitante</h3>
          <form onSubmit={handleVisitanteSubmit}>
            <label><strong>Nome:</strong></label>
            <input
              type="text"
              name="nome"
              value={visitanteForm.nome}
              onChange={handleVisitanteChange}
              placeholder="Ex: Joao Silva"
              required
            />

            <div className="form-row">
              <div>
                <label><strong>CPF:</strong></label>
                <input
                  type="text"
                  name="cpf"
                  value={visitanteForm.cpf}
                  onChange={handleVisitanteChange}
                  placeholder="Ex: 123.456.789-00"
                  required
                />
              </div>
              <div>
                <label><strong>Data de Nascimento:</strong></label>
                <input
                  type="date"
                  name="data_nascimento"
                  value={visitanteForm.data_nascimento}
                  onChange={handleVisitanteChange}
                  required
                />
              </div>
            </div>

            <label><strong>E-mail:</strong></label>
            <input
              type="email"
              name="email"
              value={visitanteForm.email}
              onChange={handleVisitanteChange}
              placeholder="Ex: joao@email.com"
              required
            />

            <label><strong>Senha:</strong></label>
            <input
              type="password"
              name="senha"
              value={visitanteForm.senha}
              onChange={handleVisitanteChange}
              placeholder="Minimo 4 caracteres"
              minLength="4"
              required
            />

            <label><strong>Tipo de Ingresso:</strong></label>
            <select name="tipo_ingresso" value={visitanteForm.tipo_ingresso} onChange={handleVisitanteChange}>
              <option value="normal">Normal</option>
              <option value="vip">VIP</option>
              <option value="anual">Passe Anual</option>
            </select>

            <button type="submit" className="primary" disabled={carregando} style={{ width: '100%' }}>
              {carregando ? 'Criando...' : 'Criar Visitante'}
            </button>
          </form>
        </div>
      )}
    </>
  )
}
