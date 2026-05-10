# Prompt para Refatoração com Listas Encadeadas Explícitas

## Objetivo
Refatorar o código do projeto Disney para implementar **Listas Encadeadas explícitas** em vez de usar Arrays e Hashes embutidos do Ruby. Isso é necessário para atender aos requisitos acadêmicos de usar estruturas de dados de forma explícita.

---

## Requisitos Obrigatórios

### 1. Criar Estrutura Base de Nó e Lista Encadeada
- ✅ Implementar classe `No` (Node) com:
  - `dados` - o valor armazenado
  - `proximo` - referência ao próximo nó
  - `anterior` (opcional, se for duplamente encadeada)

- ✅ Implementar classe `ListaEncadeada` com métodos explícitos:
  - `inserir(dados)` - insere no final
  - `inserir_no_inicio(dados)` - insere no início
  - `remover_primeiro()` - remove primeiro
  - `remover_por_id(id)` - remove por identificador
  - `buscar_por_id(id)` - busca e retorna o nó/dados
  - `obter_posicao(id)` - retorna a posição na fila
  - `obter_tamanho()` - conta nós percorrendo
  - `obter_primeiros(n)` - retorna array com n primeiros (apenas para conversão)
  - `listar_todos()` - percorre e exibe

### 2. Implementar Fila com Lista Encadeada
- ✅ Refatorar `FilaVirtual.rb`:
  - Remover `@fila = []`
  - Usar `@fila = ListaEncadeada.new`
  - Reescrever todos os métodos usando operações explícitas de nós

### 3. Refatorar Controladores
- ✅ `ControladorReserva.rb`:
  - Remover `@filas = {}` (Hash)
  - Usar estrutura de filas com ListaEncadeada
  - Atualizar métodos de gerenciamento de filas

### 4. Sem Exceções Permitidas
- ❌ Não usar: `[]`, `.<<`, `.shift`, `.first`, `.last`, `.each`, `.map`, `.sort`, etc.
- ✅ Usar: Loops com `while` percorrendo nós manualmente
- ✅ Usar: Método `.next` ou `.proximo` para navegar

---

## Estrutura de Arquivos a Criar/Modificar

```
disney/
├── estruturas/                    ← NOVO
│   ├── no.rb                     ← Classe Node
│   └── lista_encadeada.rb        ← Classe ListaEncadeada
├── fila/
│   └── filaVirtual.rb            ← REFATORAR
└── controladores/
    └── controladorReserva.rb     ← REFATORAR
```

---

## Exemplo de Implementação

### `disney/estruturas/no.rb`
```ruby
# -*- coding: utf-8 -*-

class No
  attr_accessor :dados, :proximo

  def initialize(dados)
    @dados = dados
    @proximo = nil
  end
end
```

### `disney/estruturas/lista_encadeada.rb`
```ruby
# -*- coding: utf-8 -*-

require_relative 'no'

class ListaEncadeada
  attr_accessor :inicio

  def initialize
    @inicio = nil
  end

  # Insere no final da lista
  def inserir(dados)
    novo_no = No.new(dados)
    
    if @inicio.nil?
      @inicio = novo_no
    else
      atual = @inicio
      atual = atual.proximo while atual.proximo
      atual.proximo = novo_no
    end
  end

  # Insere no início da lista
  def inserir_no_inicio(dados)
    novo_no = No.new(dados)
    novo_no.proximo = @inicio
    @inicio = novo_no
  end

  # Remove o primeiro elemento
  def remover_primeiro
    @inicio = @inicio.proximo if @inicio
  end

  # Remove por ID (busca no objeto dados)
  def remover_por_id(id)
    return if @inicio.nil?

    # Se é o primeiro
    if @inicio.dados.id == id
      @inicio = @inicio.proximo
      return
    end

    # Percorre a lista
    atual = @inicio
    while atual.proximo
      if atual.proximo.dados.id == id
        atual.proximo = atual.proximo.proximo
        return
      end
      atual = atual.proximo
    end
  end

  # Busca por ID
  def buscar_por_id(id)
    atual = @inicio
    while atual
      return atual.dados if atual.dados.id == id
      atual = atual.proximo
    end
    nil
  end

  # Obtém a posição de um elemento por ID
  def obter_posicao(id)
    atual = @inicio
    posicao = 1

    while atual
      return posicao if atual.dados.id == id
      atual = atual.proximo
      posicao += 1
    end

    nil
  end

  # Obtém o tamanho da lista
  def obter_tamanho
    tamanho = 0
    atual = @inicio

    while atual
      tamanho += 1
      atual = atual.proximo
    end

    tamanho
  end

  # Obtém os primeiros N elementos (retorna array apenas para compatibilidade)
  def obter_primeiros(n)
    resultado = []
    atual = @inicio
    contador = 0

    while atual && contador < n
      resultado << atual.dados
      atual = atual.proximo
      contador += 1
    end

    resultado
  end

  # Lista todos os elementos
  def listar_todos
    resultado = []
    atual = @inicio

    while atual
      resultado << atual.dados
      atual = atual.proximo
    end

    resultado
  end

  # Ordena a lista por prioridade (para filas)
  def ordenar_por_prioridade
    return if @inicio.nil? || @inicio.proximo.nil?

    # Bubble sort com nós
    mudou = true
    while mudou
      mudou = false
      atual = @inicio

      while atual && atual.proximo
        if atual.dados.prioridade > atual.proximo.dados.prioridade
          # Troca dados (mais simples que trocar nós)
          atual.dados, atual.proximo.dados = atual.proximo.dados, atual.dados
          mudou = true
        end
        atual = atual.proximo
      end
    end
  end
end
```

### `disney/fila/filaVirtual.rb` (REFATORADO)
```ruby
# -*- coding: utf-8 -*-

require_relative '../estruturas/lista_encadeada'
require 'date'

class FilaVirtual
  attr_accessor :fila, :atracao_id

  def initialize(atracao_id = nil)
    @fila = ListaEncadeada.new
    @atracao_id = atracao_id
  end

  def adicionar_reserva(reserva)
    @fila.inserir(reserva)
    ordenar_fila
  end

  def remover_primeira_reserva
    @fila.remover_primeiro
  end

  def obter_posicao(reserva_id)
    @fila.obter_posicao(reserva_id)
  end

  def obter_proximas_reservas(quantidade)
    @fila.obter_primeiros(quantidade)
  end

  def tamanho_fila
    @fila.obter_tamanho
  end

  def limpar_fila
    @fila = ListaEncadeada.new
  end

  private

  def ordenar_fila
    @fila.ordenar_por_prioridade
  end
end
```

---

## Passo a Passo da Refatoração

### Fase 1: Criar Estruturas Base
1. Criar diretório `disney/estruturas/`
2. Criar `no.rb` com classe Node
3. Criar `lista_encadeada.rb` com operações explícitas

### Fase 2: Refatorar FilaVirtual
1. Remover uso de Array (`[]`)
2. Importar `ListaEncadeada`
3. Reescrever todos os métodos

### Fase 3: Refatorar ControladorReserva
1. Remover `@filas = {}` (Hash)
2. Usar instâncias de `ListaEncadeada` por atração
3. Atualizar lógica de gerenciamento

### Fase 4: Testes
1. Verificar se funciona: criar reserva
2. Verificar se funciona: obter posição na fila
3. Verificar se funciona: ordenar por prioridade

---

## Checklist Final

- [ ] Classe `No` implementada
- [ ] Classe `ListaEncadeada` implementada com todos os métodos
- [ ] `FilaVirtual.rb` refatorado sem Arrays
- [ ] `ControladorReserva.rb` refatorado sem Hashes
- [ ] Sem uso de métodos embutidos como `<<`, `.shift`, `.each`, etc.
- [ ] Operações de inserção explícitas (percorrendo com while)
- [ ] Operações de remoção explícitas (encontrando e desconectando nós)
- [ ] Operações de busca explícitas (percorrendo com while)
- [ ] Testes funcionando na API

---

## Notas Importantes

⚠️ **Não esquecer de:**
- Atualizar `app.rb` para require as novas estruturas
- Manter compatibilidade com `RepositorioReserva` (que usa banco de dados)
- A conversão para array no método `obter_primeiros` é apenas para compatibilidade, mas o armazenamento é em nós
- Remover TODO uso de métodos Array/Hash built-in

✅ **O projeto ficará:**
- Com listas encadeadas EXPLÍCITAS
- Com operações de nó VISÍVEIS no código
- Pronto para apresentação académica
- Sem dependência de abstrações built-in
