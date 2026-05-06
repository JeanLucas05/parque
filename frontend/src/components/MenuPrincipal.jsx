export default function MenuPrincipal({ onNavigate }) {
  return (
    <>
      <div className="header park-hero">
        <p className="eyebrow">Sistema de reservas</p>
        <h1>Parque Tematico</h1>
        <p>Controle de atracoes, filas virtuais, reservas e indicadores do parque em um unico lugar.</p>
      </div>

      <div className="grid">
        <div className="card menu-card">
          <div>
            <div className="menu-icon">A</div>
            <h2>Painel Administrador</h2>
            <p>Gerencie atracoes, acompanhe filas e veja os relatorios do dia.</p>
          </div>
          <button className="primary" onClick={() => onNavigate('admin')} style={{ width: '100%', marginTop: '20px' }}>
            Acessar Painel
          </button>
        </div>

        <div className="card menu-card">
          <div>
            <div className="menu-icon">V</div>
            <h2>Portal do Visitante</h2>
            <p>Entre com e-mail e senha, escolha uma atracao e reserve um horario.</p>
          </div>
          <button className="primary" onClick={() => onNavigate('visitante')} style={{ width: '100%', marginTop: '20px' }}>
            Entrar no Portal
          </button>
        </div>

        <div className="card menu-card">
          <div>
            <div className="menu-icon">C</div>
            <h2>Cadastros</h2>
            <p>Cadastre novas atracoes e visitantes com seus tipos de ingresso.</p>
          </div>
          <button className="primary" onClick={() => onNavigate('cadastro')} style={{ width: '100%', marginTop: '20px' }}>
            Acessar Cadastros
          </button>
        </div>
      </div>
    </>
  )
}
