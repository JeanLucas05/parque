export default function MenuPrincipal({ onNavigate }) {
  return (
    <>
      <div className="header">
        <h1>🎡 Parque Temático</h1>
        <p>Sistema de Reservas de Atrações</p>
      </div>

      <div className="grid">
        <div className="card" style={{ textAlign: 'center' }}>
          <h2>🎯 Menu Administrador</h2>
          <p>Gerenciar atrações, visitantes, filas e visualizar relatórios</p>
          <button 
            className="primary"
            onClick={() => onNavigate('admin')}
            style={{ width: '100%', marginTop: '20px' }}
          >
            Acessar Painel
          </button>
        </div>

        <div className="card" style={{ textAlign: 'center' }}>
          <h2>👤 Portal do Visitante</h2>
          <p>Faça login e gerenciar suas reservas</p>
          <button 
            className="primary"
            onClick={() => onNavigate('visitante')}
            style={{ width: '100%', marginTop: '20px' }}
          >
            Entrar no Portal
          </button>
        </div>

        <div className="card" style={{ textAlign: 'center' }}>
          <h2>📝 Cadastros</h2>
          <p>Cadastrar novas atrações e visitantes</p>
          <button 
            className="primary"
            onClick={() => onNavigate('cadastro')}
            style={{ width: '100%', marginTop: '20px' }}
          >
            Acessar Cadastros
          </button>
        </div>
      </div>
    </>
  )
}
