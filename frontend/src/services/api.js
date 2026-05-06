import axios from 'axios'

// Usar variável de ambiente ou padrão para desenvolvimento
const API_BASE = import.meta.env.VITE_API_URL || 'http://localhost:4567'

const api = axios.create({
  baseURL: `${API_BASE}/api`,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  }
})

// ========== ATRAÇÕES ==========

export const getAtracao = async () => {
  try {
    const response = await api.get('/atracao')
    return response.data
  } catch (error) {
    console.error('Erro ao buscar atrações:', error)
    throw error
  }
}

export const getAtracaoById = async (id) => {
  try {
    const response = await api.get(`/atracao/${id}`)
    return response.data
  } catch (error) {
    console.error('Erro ao buscar atração:', error)
    throw error
  }
}

export const createAtracao = async (data) => {
  try {
    const response = await api.post('/atracao', data)
    return response.data
  } catch (error) {
    console.error('Erro ao criar atração:', error)
    throw error
  }
}

// ========== VISITANTES ==========

export const getVisitante = async () => {
  try {
    const response = await api.get('/visitante')
    return response.data
  } catch (error) {
    console.error('Erro ao buscar visitantes:', error)
    throw error
  }
}

export const getVisitanteById = async (id) => {
  try {
    const response = await api.get(`/visitante/${id}`)
    return response.data
  } catch (error) {
    console.error('Erro ao buscar visitante:', error)
    throw error
  }
}

export const loginVisitante = async (email, senha) => {
  try {
    const response = await api.post('/visitante/login', { email, senha })
    return response.data
  } catch (error) {
    console.error('Erro ao fazer login do visitante:', error)
    throw error
  }
}

export const createVisitante = async (data) => {
  try {
    const response = await api.post('/visitante', data)
    return response.data
  } catch (error) {
    console.error('Erro ao criar visitante:', error)
    throw error
  }
}

// ========== RESERVAS ==========

export const getReserva = async () => {
  try {
    const response = await api.get('/reserva')
    return response.data
  } catch (error) {
    console.error('Erro ao buscar reservas:', error)
    throw error
  }
}

export const getReservaByVisitante = async (visitanteId) => {
  try {
    const response = await api.get(`/reserva/visitante/${visitanteId}`)
    return response.data
  } catch (error) {
    console.error('Erro ao buscar reservas do visitante:', error)
    throw error
  }
}

export const getReservaByAtracao = async (atracaoId) => {
  try {
    const response = await api.get(`/reserva/atracao/${atracaoId}`)
    return response.data
  } catch (error) {
    console.error('Erro ao buscar reservas da atração:', error)
    throw error
  }
}

export const createReserva = async (data) => {
  try {
    const response = await api.post('/reserva', data)
    return response.data
  } catch (error) {
    console.error('Erro ao criar reserva:', error)
    throw error
  }
}

// ========== FILA VIRTUAL ==========

export const getFila = async (atracaoId) => {
  try {
    const response = await api.get(`/fila/${atracaoId}`)
    return response.data
  } catch (error) {
    console.error('Erro ao buscar fila:', error)
    throw error
  }
}

export const avancarFila = async (atracaoId, quantidade = 1) => {
  try {
    const response = await api.post(`/fila/${atracaoId}/avancar`, { quantidade })
    return response.data
  } catch (error) {
    console.error('Erro ao avancar fila:', error)
    throw error
  }
}

// ========== ESTATÍSTICAS ==========

export const getEstatisticaDiaria = async () => {
  try {
    const response = await api.get('/estatistica/diario')
    return response.data
  } catch (error) {
    console.error('Erro ao buscar estatística diária:', error)
    throw error
  }
}

export const getEstatisticaPeriodo = async (dataInicio, dataFim) => {
  try {
    const response = await api.get('/estatistica/periodo', {
      params: {
        data_inicio: dataInicio,
        data_fim: dataFim
      }
    })
    return response.data
  } catch (error) {
    console.error('Erro ao buscar estatística de período:', error)
    throw error
  }
}

// ========== HEALTH CHECK ==========

export const healthCheck = async () => {
  try {
    const response = await api.get('/health')
    return response.data
  } catch (error) {
    console.error('Erro ao verificar saúde da API:', error)
    throw error
  }
}
