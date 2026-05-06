import { useState } from 'react'
import MenuPrincipal from './components/MenuPrincipal'
import PainelAdministrador from './components/PainelAdministrador'
import PortalVisitante from './components/PortalVisitante'
import MenuCadastro from './components/MenuCadastro'

export default function App() {
  const [telaAtual, setTelaAtual] = useState('menu')

  const renderTela = () => {
    switch (telaAtual) {
      case 'admin':
        return <PainelAdministrador onVoltar={() => setTelaAtual('menu')} />
      case 'visitante':
        return <PortalVisitante onVoltar={() => setTelaAtual('menu')} />
      case 'cadastro':
        return <MenuCadastro onVoltar={() => setTelaAtual('menu')} />
      default:
        return <MenuPrincipal onNavigate={setTelaAtual} />
    }
  }

  return (
    <div className="container">
      {renderTela()}
    </div>
  )
}
