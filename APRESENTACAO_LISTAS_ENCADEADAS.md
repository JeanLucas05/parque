# Apresentacao - Sistema de Reservas para Atracoes de Parque Tematico

## Slide 1 - Tema do Projeto

**Sistema de Reservas para Atracoes de um Parque Tematico**

O sistema permite que visitantes entrem em filas virtuais de atracoes, acompanhem sua posicao e sejam atendidos conforme a ordem da fila.

O diferencial da implementacao e o uso explicito de **listas encadeadas**, com nos, insercao, remocao, busca, calculo de posicao e ordenacao por prioridade.

---

## Slide 2 - Entidades Principais

O projeto possui as entidades pedidas na especificacao:

- Atracao
- Visitante
- Reserva
- Fila virtual por atracao

### Codigo - Atracao

Arquivo: `disney/atracao/atracaoModel.rb`

```ruby
class AtracaoModel
  attr_accessor :id, :nome, :tipo, :capacidade_por_sessao,
                :idade_minima, :horarios_disponiveis,
                :passes_com_prioridade, :fila_virtual

  def initialize(id, nome, tipo, capacidade_por_sessao, idade_minima)
    @id = id
    @nome = nome
    @tipo = tipo
    @capacidade_por_sessao = capacidade_por_sessao
    @idade_minima = idade_minima
    @horarios_disponiveis = []
    @passes_com_prioridade = []
    @fila_virtual = FilaVirtual.new
  end
end
```

---

## Slide 3 - Cadastro de Visitantes

Cada visitante possui dados pessoais e tipo de ingresso. O tipo de ingresso e usado depois para calcular prioridade na fila.

### Codigo - Visitante

Arquivo: `disney/visitante/visitanteModel.rb`

```ruby
class VisitanteModel
  attr_accessor :id, :nome, :cpf, :data_nascimento, :email,
                :tipo_ingresso, :reservas, :senha_hash

  def initialize(id, nome, cpf, data_nascimento, email, tipo_ingresso, senha_hash = nil)
    @id = id
    @nome = nome
    @cpf = cpf
    @data_nascimento = data_nascimento
    @email = email
    @tipo_ingresso = tipo_ingresso
    @senha_hash = senha_hash
    @reservas = []
  end
end
```

---

## Slide 4 - Reserva e Prioridade

Quando uma reserva e criada, ela guarda visitante, atracao, horario, status, posicao na fila e prioridade.

Visitantes VIP ou com passe anual recebem prioridade `1`; visitantes normais recebem prioridade `2`.

### Codigo - Reserva

Arquivo: `disney/reserva/reservaModel.rb`

```ruby
class ReservaModel
  attr_accessor :id, :visitante, :atracao, :horario, :status,
                :posicao_na_fila, :prioridade, :data_reserva,
                :visitante_id, :atracao_id

  def initialize(id, visitante, atracao, horario, status, posicaoNaFila, prioridade)
    @id = id
    @visitante = visitante
    @atracao = atracao
    @visitante_id = visitante.id if visitante
    @atracao_id = atracao.id if atracao
    @horario = horario
    @status = status || "aguardando"
    @posicao_na_fila = posicaoNaFila
    @prioridade = prioridade || calcular_prioridade
    @data_reserva = Date.today
  end

  def calcular_prioridade
    return 2 unless @visitante
    case @visitante.tipo_ingresso
    when :vip, :anual
      1
    else
      2
    end
  end
end
```

---

## Slide 5 - Estrutura de Dados: No

A lista encadeada comeca com a classe `No`.

Cada no armazena:

- `dados`: objeto guardado na lista
- `proximo`: referencia para o proximo no

### Codigo - No

Arquivo: `disney/estruturas/no.rb`

```ruby
class No
  attr_accessor :dados, :proximo

  def initialize(dados)
    @dados = dados
    @proximo = nil
  end
end
```

---

## Slide 6 - Estrutura de Dados: Lista Encadeada

A classe `ListaEncadeada` possui referencia para o primeiro no da lista.

Ela nao depende de colecoes prontas para armazenar os dados principais da fila.

### Codigo - Inicio da Lista

Arquivo: `disney/estruturas/lista_encadeada.rb`

```ruby
class ListaEncadeada
  attr_accessor :inicio

  def initialize
    @inicio = nil
  end
end
```

---

## Slide 7 - Insercao na Lista Encadeada

A insercao percorre os nos manualmente ate encontrar o ultimo elemento.

Isso mostra explicitamente o uso de ponteiros/referencias entre nos.

### Codigo - Inserir no Final

Arquivo: `disney/estruturas/lista_encadeada.rb`

```ruby
def inserir(dados)
  novo_no = No.new(dados)

  if @inicio.nil?
    @inicio = novo_no
    return novo_no
  end

  atual = @inicio
  atual = atual.proximo while atual.proximo
  atual.proximo = novo_no
  novo_no
end
```

---

## Slide 8 - Remocao na Lista Encadeada

A remocao altera a referencia do inicio ou desconecta um no do meio da lista.

### Codigo - Remover Primeiro

Arquivo: `disney/estruturas/lista_encadeada.rb`

```ruby
def remover_primeiro
  return nil if @inicio.nil?

  removido = @inicio
  @inicio = @inicio.proximo
  removido.dados
end
```

### Codigo - Remover por ID

```ruby
def remover_por_id(id)
  return nil if @inicio.nil?

  if mesmo_id?(@inicio.dados, id)
    return remover_primeiro
  end

  atual = @inicio
  while atual.proximo
    if mesmo_id?(atual.proximo.dados, id)
      removido = atual.proximo
      atual.proximo = atual.proximo.proximo
      return removido.dados
    end

    atual = atual.proximo
  end

  nil
end
```

---

## Slide 9 - Busca e Posicao na Fila

A posicao do visitante na fila e calculada percorrendo os nos da lista um por um.

### Codigo - Obter Posicao

Arquivo: `disney/estruturas/lista_encadeada.rb`

```ruby
def obter_posicao(id)
  atual = @inicio
  posicao = 1

  while atual
    return posicao if mesmo_id?(atual.dados, id)

    atual = atual.proximo
    posicao += 1
  end

  nil
end
```

---

## Slide 10 - Ordenacao por Prioridade

A lista e ordenada por prioridade usando os nos da lista.

Prioridade menor vem primeiro:

- `1`: VIP ou passe anual
- `2`: normal

### Codigo - Ordenar por Prioridade

Arquivo: `disney/estruturas/lista_encadeada.rb`

```ruby
def ordenar_por_prioridade
  return if @inicio.nil? || @inicio.proximo.nil?

  mudou = true
  while mudou
    mudou = false
    atual = @inicio

    while atual && atual.proximo
      prioridade_atual = prioridade(atual.dados)
      prioridade_proximo = prioridade(atual.proximo.dados)

      if prioridade_atual > prioridade_proximo
        temporario = atual.dados
        atual.dados = atual.proximo.dados
        atual.proximo.dados = temporario
        mudou = true
      end

      atual = atual.proximo
    end
  end
end
```

---

## Slide 11 - Fila Virtual com Lista Encadeada

Cada fila virtual usa uma `ListaEncadeada`.

Quando uma reserva entra, ela e inserida na lista e a fila e reordenada por prioridade.

### Codigo - FilaVirtual

Arquivo: `disney/fila/filaVirtual.rb`

```ruby
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

  def tamanho_fila
    @fila.obter_tamanho
  end

  private

  def ordenar_fila
    @fila.ordenar_por_prioridade
  end
end
```

---

## Slide 12 - Lista de Filas por Atracao

O controlador nao usa `Hash` para guardar as filas.

Ele usa uma lista encadeada onde cada no armazena uma `FilaVirtual`.

### Codigo - ControladorReserva

Arquivo: `disney/controladores/controladorReserva.rb`

```ruby
def initialize(repositorio_reserva, repositorio_atracao, repositorio_visitante)
  @repositorio_reserva = repositorio_reserva
  @repositorio_atracao = repositorio_atracao
  @repositorio_visitante = repositorio_visitante
  @proximo_id = 1
  @filas = ListaEncadeada.new
end
```

### Codigo - Buscar Fila de Uma Atracao

```ruby
def obter_fila_atracao(atracao_id)
  atual = @filas.inicio

  while atual
    return atual.dados if atual.dados.atracao_id == atracao_id

    atual = atual.proximo
  end

  nil
end
```

---

## Slide 13 - Criacao de Reserva e Entrada na Fila

Ao criar uma reserva:

1. O sistema valida visitante e atracao.
2. Valida idade minima.
3. Cria a reserva.
4. Inicializa a fila da atracao.
5. Insere a reserva na lista encadeada da fila.
6. Calcula a posicao na fila.

### Codigo - Criar Reserva

Arquivo: `disney/controladores/controladorReserva.rb`

```ruby
reserva = ReservaModel.new(@proximo_id, visitante, atracao, horario, "aguardando", nil, nil)
reserva.data_reserva = Date.today

inicializar_fila_atracao(atracao_id)
fila = obter_fila_atracao(atracao_id)
fila.adicionar_reserva(reserva)

reserva.posicao_na_fila = fila.obter_posicao(reserva.id)

@repositorio_reserva.salvar(reserva)
```

---

## Slide 14 - Inicializacao da Fila da Atracao

Cada atracao tem sua propria fila virtual.

Quando a fila ainda nao existe, ela e criada e armazenada na lista encadeada de filas.

### Codigo - Inicializar Fila

Arquivo: `disney/controladores/controladorReserva.rb`

```ruby
def inicializar_fila_atracao(atracao_id)
  return if obter_fila_atracao(atracao_id)

  fila = FilaVirtual.new(atracao_id)
  @filas.inserir(fila)

  reservas_existentes = @repositorio_reserva.obter_por_atracao(atracao_id)
  indice = 0

  while indice < reservas_existentes.length
    reserva = reservas_existentes[indice]
    fila.adicionar_reserva(reserva) if reserva.status == "aguardando"
    indice += 1
  end
end
```

---

## Slide 15 - Avanco da Fila

Quando visitantes entram na atracao, o sistema remove reservas do inicio da lista encadeada.

Isso representa o comportamento real de uma fila.

### Codigo - Processar Entrada

Arquivo: `disney/controladores/controladorReserva.rb`

```ruby
fila = obter_fila_atracao(atracao_id)
entrada = ListaEncadeada.new
contador = 0

while contador < quantidade
  reserva = fila.remover_primeira_reserva
  break if !reserva

  reserva.status = "em_uso"
  @repositorio_reserva.salvar(reserva)
  entrada.inserir(reserva)
  contador += 1
end
```

---

## Slide 16 - Visualizacao da Fila

O painel do parque consegue visualizar:

- total de pessoas na fila
- proximas reservas
- prioridade VIP/normal

### Codigo - Visualizar Fila

Arquivo: `disney/controladores/controladorReserva.rb`

```ruby
fila = obter_fila_atracao(atracao_id)
puts "Total na fila: #{fila.tamanho_fila} pessoas"

proximas = fila.obter_proximas_reservas(10)

index = 0
while index < proximas.length
  reserva = proximas[index]
  visitante = if reserva.visitante.nil?
                @repositorio_visitante.obter_por_id(reserva.visitante_id)
              else
                reserva.visitante
              end

  if visitante
    tipo_ingresso = visitante.tipo_ingresso
    prioridade_texto = tipo_ingresso == :vip || tipo_ingresso == :anual ? "VIP" : "Normal"
    puts "#{index + 1}. #{visitante.nome} [#{prioridade_texto}]"
  end

  index += 1
end
```

---

## Slide 17 - Estatisticas e Metricas

O sistema tambem possui modulo analitico para:

- total de reservas do dia
- atracao mais disputada
- visitante mais ativo

### Codigo - Relatorio Diario

Arquivo: `disney/modelos/estatistica.rb`

```ruby
def gerar_relatorio_diario(data = Date.today)
  reservas_do_dia = @repositorio_reserva.obter_por_data(data)

  relatorio = {
    data: data.to_s,
    total_reservas: reservas_do_dia.length,
    atracao_mais_disputada: obter_atracao_mais_disputada(reservas_do_dia),
    visitante_mais_ativo: obter_visitante_mais_ativo(reservas_do_dia),
    reservas_por_status: contar_por_status(reservas_do_dia),
    reservas_por_tipo_ingresso: contar_por_tipo_ingresso(reservas_do_dia)
  }

  relatorio
end
```

---

## Slide 18 - Onde a Lista Encadeada Tem Papel Relevante

A lista encadeada nao e apenas decorativa. Ela participa diretamente do armazenamento e funcionamento principal do sistema:

- Armazena as reservas dentro da fila virtual.
- Armazena as filas virtuais existentes no controlador de reservas.
- Calcula posicao percorrendo os nos.
- Remove visitantes do inicio quando a fila avanca.
- Ordena as reservas por prioridade.

### Resumo Tecnico

```ruby
@fila = ListaEncadeada.new       # Fila de reservas
@filas = ListaEncadeada.new      # Lista de filas por atracao
atual = atual.proximo            # Percurso explicito dos nos
@fila.remover_primeiro           # Avanco da fila
@fila.ordenar_por_prioridade     # Prioridade VIP/anual
```

---

## Slide 19 - Observacao Importante para a Apresentacao

O nucleo da fila virtual foi refatorado para usar lista encadeada explicita.

Pontos fortes para defender em sala:

- O armazenamento principal das filas nao usa `Array` nem `Hash`.
- Cada fila e uma `ListaEncadeada`.
- Cada elemento da fila e um `No`.
- O controlador armazena as filas de atracoes tambem em `ListaEncadeada`.
- Insercao, remocao, busca, tamanho e posicao percorrem os nos manualmente.

Ponto de atencao:

Algumas camadas auxiliares, como API, banco de dados e estatisticas, ainda podem usar estruturas do Ruby para JSON, consultas e relatorios. Na apresentacao, o foco deve ser o requisito principal: as **filas virtuais e reservas em espera** usam listas encadeadas explicitas.

---

## Slide 20 - Conclusao

O sistema atende ao tema escolhido porque implementa:

- Cadastro de atracoes.
- Cadastro de visitantes.
- Reservas em atracoes.
- Fila virtual por atracao.
- Prioridade para VIP e passe anual.
- Avanco da fila.
- Visualizacao de posicao.
- Metricas e estatisticas.
- Lista encadeada explicita como estrutura central das filas.

Frase para finalizar:

> "A estrutura mais importante do sistema e a fila virtual, e ela foi implementada manualmente com nos encadeados, deixando visiveis as operacoes de insercao, remocao, busca, posicao e ordenacao por prioridade."
