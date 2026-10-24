# StickerControl · Identidade visual "Recorte"

Especificação de interface aprovada em 19/10/2026. É a fonte de verdade para o visual do app.
Este documento muda **só a aparência** — com três exceções de comportamento, listadas na seção 5.

- **Imagens aprovadas:** `design/telas/*.png` (exportadas do canvas de design; mapa na seção 9).
- **Referência de estilos exatos:** `design/referencia/*.dc.html` — HTML com todos os estilos escritos por extenso. São documentos de consulta (abrir no editor e ler os valores), não código do app e não precisam rodar.
- Em caso de conflito: **este arquivo > imagens > referência HTML**.

---

## 0. Regras para quem implementar

1. Não alterar regras de cálculo, campos, validações, navegação nem textos — exceto o que está na seção 5.
2. Todo texto visível vem do código atual (`lib/ui/**`). Os textos citados aqui foram copiados de lá.
3. Implementar por fases (seção 8). Cada fase termina com `flutter analyze` limpo e `flutter test` verde.
4. Testes existentes: pode ajustar **como** o teste encontra o widget (finders), nunca **o que** ele verifica.
5. Cores, fontes, raios e espaçamentos saem dos tokens (seção 2) — nada de valores soltos nas telas.
6. A cor da marca é **um único valor** (`brand`). Hoje fixo em magenta `#C2185B`; no futuro virá da configuração da empresa (seção 7).

---

## 1. Conceito

**Liner e adesivo.** O fundo de todas as telas é o papel de proteção do adesivo (liner): cinza-claro, organizado, técnico. Campos e informações ficam nele, em células brancas. Só o que é **resultado** ou **ação principal** "descola" do liner: ganha cor da marca, relevo e a **linha de corte** tracejada da plotter.

Regra de moderação: no máximo dois elementos "adesivo" por tela (o preço final e o botão flutuante).

---

## 2. Tokens

### 2.1 Cores fixas

| Token | Hex | Uso |
|---|---|---|
| `liner` | `#EEF0EC` | Fundo de todas as telas |
| `superficie` | `#FFFFFF` | Células, lista, diálogos, segmento selecionado |
| `trilho` | `#E2E5DF` | Fundo do seletor de modalidade; barra superior quando rolada; botão desativado |
| `borda` | `#CDD0C9` | Contorno de células e cartões (1 px) |
| `divisoria` | `#E4E6E1` | Divisórias internas (1 px) |
| `grafite` | `#17181B` | Texto principal, botão "Salvar", linha de corte, marca de registro |
| `textoSecundario` | `#4A4E55` | Corpo secundário, rótulos de linha de resultado |
| `rotulo` | `#5A5E66` | Rótulos de célula, metadados, unidades (5,7:1 no liner) |
| `contornoNeutro` | `#8A8E95` | Ficha "Terceirizada", contorno do resultado vazio, ilustrações vazias |
| `desativadoTexto` | `#8A8E95` | Texto de botão desativado |
| `desativadoBorda` | `#D5D8D1` | Borda de botão secundário desativado |
| `pontilhado` | `#B4B8B0` | Guias pontilhadas entre rótulo e valor |
| `grade` | `#DDE0D8` | Grade de mesa de corte (só topo do Início) |
| `erro` | `#B3261E` | Entrada inválida, exclusão |
| `avisoFundo` | `#FFF1B8` | Fundo de aviso amarelo |
| `avisoBorda` | `#6B5100` | Borda e ícone do aviso amarelo |
| `avisoTexto` | `#3D2E00` | Texto do aviso amarelo |
| `alertaEscuro` | `#F2C94C` | Ícone de alerta no aviso de rodapé (fundo grafite) |
| `okEscuro` | `#9BE0BC` | Ícone de sucesso no aviso de rodapé |
| `scrim` | `#17181B` a 48% | Fundo atrás de diálogos |

### 2.2 Cor da marca e derivadas

Entrada única: `brand` (padrão `#C2185B`, magenta). Derivadas calculadas no código (não escolhidas à mão):

| Derivada | Regra | Uso |
|---|---|---|
| `onBrand` | Branco ou `grafite`, o que tiver **maior contraste** com `brand` | Texto/ícone sobre a cor da marca |
| `brandLinha` | `brand` escurecida (mistura com preto em passos de 5%) até contraste **≥ 3:1** sobre branco | Contorno de foco, arco do indicador de carregamento, contorno da ficha "Própria" |
| `brandTexto` | Idem até **≥ 4,5:1** sobre branco | Rótulo da célula em foco |
| `brandTint` | `brand` misturada com branco (72% branco) | Preenchimento da ficha "Própria" e do ícone de material |
| `brandDobra` | `brand` misturada com branco (50% branco) | "Ponta descolando" do adesivo de preço |

Contraste = fórmula WCAG de luminância relativa. Com isso, amarelo claro recebe texto grafite e contornos escurecidos automaticamente.

### 2.3 Tipografia

Duas famílias, **embutidas no app como assets** (o app funciona offline; ambas são OFL, Google Fonts):
- **Schibsted Grotesk** (500, 600, 700, 800): títulos, valores digitados, preços, botões.
- **Instrument Sans** (400, 500, 600, 700): corpo, rótulos, listas.

Números de dinheiro e medidas usam algarismos tabulares (`FontFeature.tabularFigures()`).
`letterSpacing` em Flutter = valor em em × tamanho da fonte.

| Papel | Família / peso | Tamanho / altura | Espaçamento |
|---|---|---|---|
| Título do Início ("Orçamentos") | Schibsted 800 | 36 / 40 | −0,035 em |
| Título da barra superior | Schibsted 800 | 21 / 28 | −0,025 em |
| Wordmark "StickerControl" | Schibsted 800 | 20 | −0,03 em |
| Preço final (adesivo) | Schibsted 800 | 38 / 46 | −0,035 em |
| Valor digitado em célula | Schibsted 600 | 26 / 34 | — |
| Preço na lista / valores do resultado | Schibsted 700 / 600 | 17 / 14 | — |
| Título de diálogo | Schibsted 800 | 22 / 28 | −0,03 em |
| Título de estado vazio/erro | Schibsted 700 | 18 / 24 | — |
| Botão | Schibsted 700 | 16 (diálogo: 15) | — |
| Título de item de lista | Instrument 600 | 16 / 21 | — |
| Corpo | Instrument 400 | 15 / 22 | — |
| Corpo secundário | Instrument 400 | 14 / 20–21 | — |
| Metadado (data · modalidade) | Instrument 400 | 13 / 17 | — |
| Rótulo de célula | Instrument 600 | 12 / 16 | — |
| Ajuda / erro sob campo | Instrument 400 / 600 | 12 / 16 | — |

### 2.4 Espaços, raios e sombras

- Margem lateral da tela: **16**. Espaço entre blocos: **14**. Entre botões empilhados: **8**.
- Barra superior: altura **64**, botões de ícone 48×48.
- Célula: padding **10 vertical / 16 horizontal**, altura mínima **72–76** (valor grande) ou **58–66** (linha simples).
- Item de lista: altura mínima **66**.
- Alvos de toque ≥ 44 (botões: 52 principais, 48 de texto, 44 em diálogos).

| Raio | Valor |
|---|---|
| Célula, cartão, botão, aviso | 12 |
| Adesivo de preço, botão flutuante | 14 |
| Segmento selecionado | 9 (trilho 12, padding 4) |
| Diálogo | 20 |
| Chip de variável | 10 |
| Menu | 14 (itens 10) |

| Sombra (cor `grafite`) | Valor |
|---|---|
| Botão flutuante | y 6, blur 14, 22% |
| Adesivo de preço | y 6, blur 14, 18% |
| Segmento selecionado | y 1, blur 3, 20% |
| Menu | y 10, blur 28, 20% |
| Diálogo | y 18, blur 40, 30% |
| Aviso de rodapé | y 6, blur 16, 25% |

Células e listas **não** têm sombra (só borda 1 px).

### 2.5 Ícones

Traço de 1,8–2 px, estilo "outlined". Equivalentes Material servem: voltar `arrow_back`, materiais `layers_outlined`, menu `more_vert`, adicionar `add`, salvar `save_outlined`, enviar `send`, duplicar `copy`, excluir `delete_outline`, restaurar `restore`, alerta `warning_amber`, informação `info_outline`, empresa `storefront_outlined`, mensagem `chat_outlined`.
Ícones próprios (desenhar com `CustomPainter` ou SVG): **cota horizontal** (comprimento), **cota vertical** (largura), **ficha de modalidade**, **marca de registro** (logo).

---

## 3. Componentes compartilhados

Construir estes widgets antes das telas. Cada um num arquivo em `lib/ui/recorte/` (ou equivalente).

### 3.1 Barra superior
Fundo transparente sobre o liner; ao rolar o conteúdo, fundo `trilho`. Voltar à esquerda, título (2.3), ações à direita. Sem sombra.

### 3.2 Célula de campo
- Fundo `superficie`, borda 1 px `borda`, raio 12, padding 10/16.
- Rótulo em cima (12/600 `rotulo`), valor embaixo (26/600 Schibsted, ou 17–18 Instrument para texto).
- Prefixo/sufixo (`R$`, `m`, `%`, `/ m`) em 15/600 `rotulo`, alinhados pela linha de base do valor.
- **Foco:** contorno interno de 2 px `brandLinha`; rótulo 700 `brandTexto`.
- **Erro:** contorno interno de 2 px `erro`; rótulo `erro`; mensagem abaixo da célula (12/600 `erro`, recuo 16).
- **Vazio sem foco:** só o rótulo (como placeholder) ou placeholder `opcional` em `rotulo`.
- **Moldura compartilhada:** campos relacionados dividem a mesma célula, separados por divisória 1 px (Comprimento | Largura lado a lado; Acréscimo / Descrição empilhados; Valor do fornecedor / Largura empilhados).
- Descrição é linha simples: rótulo "Descrição" à esquerda (14/600 `rotulo`), campo à direita, altura 58.

### 3.3 Seletor de modalidade
Trilho `trilho`, raio 12, padding 4, altura 52, duas metades. Selecionado: fundo branco, raio 9, sombra leve, texto grafite 700 e uma bolinha de 18 px na cor `brand` com ✓ em `onBrand`. Não selecionado: texto `textoSecundario` 600, sem fundo.

### 3.4 Seletor de material
Célula de linha (altura 66): rótulo "Material" + nome do material (17/600) à esquerda; preço "R$ 50,00 / m" (Schibsted 600 14 `rotulo`) e seta para baixo à direita. Sem material escolhido: só "Material" em 17 `rotulo`. A lista aberta continua sendo o menu suspenso atual, com o mesmo estilo de menu (3.13).

### 3.5 Ícones de cota
Antes do rótulo "Comprimento": cota horizontal (16×10, linha com setas e batentes). Antes de "Largura": cota vertical (10×16). Traço 1,2 `rotulo`. Também em "Largura fixa: 1,10 m." no formulário de material.

### 3.6 Resultado
1. **Parcelas:** célula branca, padding 12/16, linhas "Custo" e "Acréscimo (N%)" em 14/20 `textoSecundario`, valor à direita (Schibsted 600), **guia pontilhada** `pontilhado` 1,5 px entre rótulo e valor.
2. **Adesivo de preço:** bloco `brand`, raio 14, padding 14/18, sombra (2.4). "Preço final" (13/700) à esquerda, valor (2.3) à direita, ambos em `onBrand`.
   - **Linha de corte:** retângulo arredondado tracejado, 1,5 px `grafite`, afastado **4 px** para fora do bloco, acompanhando o raio (traço ≈ 4, espaço ≈ 3). Margem externa de 5 px para não colar em nada.
   - **Ponta descolando:** canto superior direito, 26×26: triângulo na cor do fundo (`liner`) cobrindo o canto + triângulo `brandDobra` simulando a dobra.
3. **Sem resultado** (campos incompletos ou inválidos): só a linha de corte, 1,5 px tracejada `contornoNeutro`, raio 14, altura 64, com o texto "Preencha os campos para ver o preço." (14/600 `rotulo`) centralizado. Ocupa o mesmo lugar do adesivo — a tela não "pula" quando o preço aparece.
4. **Aviso de largura** (3.8), quando houver, fica entre as parcelas e o adesivo.

### 3.7 Botões
| Tipo | Visual | Onde |
|---|---|---|
| Primário | Fundo `grafite`, texto branco, raio 12, altura 52, largura total | Salvar, Enviar por WhatsApp (detalhe), Salvar (material/mensagem) |
| Secundário | Fundo branco, borda 1 px `grafite`, texto grafite | Salvar e enviar por WhatsApp, Duplicar, Cadastrar |
| Texto | Sem fundo, texto grafite, altura 48 | Restaurar padrão, Cancelar |
| Destrutivo | Texto `erro` com ícone (tela); fundo `erro` + texto branco (diálogo) | Excluir |
| Flutuante | Fundo `brand`, texto `onBrand`, raio 14, altura 56, sombra, **linha de corte** 1,5 px tracejada `grafite` a 4 px | Novo orçamento, Novo material |
| Desativado | Primário: fundo `trilho`, texto `desativadoTexto`. Secundário: borda `desativadoBorda`, texto `desativadoTexto` | Salvar enquanto não há orçamento válido ou durante o salvamento |

### 3.8 Aviso amarelo
Fundo `avisoFundo`, borda 1 px `avisoBorda`, raio 12, padding 12/14, ícone 22 (`warning_amber` ou `info_outline`) em `avisoBorda`, texto 14/20 `avisoTexto`. Usos: largura acima de 1,10 m; material original excluído (5.3).

### 3.9 Aviso de rodapé (SnackBar)
Fundo `grafite`, texto branco 14/20, raio 12, margens 16, sombra. Ícone à esquerda: ✓ `okEscuro` (sucesso) ou alerta `alertaEscuro` (falha). O botão flutuante sobe para não ficar coberto.

### 3.10 Diálogos
Fundo branco, raio 20, padding 24/24/18, sombra, `scrim` atrás. Título (2.3), texto 15/22 `textoSecundario`. Ações à direita, altura 44, raio 12: "Cancelar" = botão de texto; confirmação:
- **Excluir** (orçamento e material): fundo `erro`, texto branco — igual nos dois diálogos.
- **Salvar** (nome da empresa): fundo `brand`, texto `onBrand`.

### 3.11 Lista em bloco
Um único cartão branco (borda 1 px, raio 12) com itens separados por divisória `divisoria`. Item: ficha de modalidade (36), título + metadado, valor à direita. Sem cartão por item.

**Ficha de modalidade** (36×36): quadrado interno 24 (raio 6) + contorno tracejado externo (raio 9, traço 3,5 / espaço 3, 1,5 px).
- Própria: interno `brandTint`, contorno `brandLinha` ("adesivo produzido aqui").
- Terceirizada: sem interno, contorno `contornoNeutro` ("só o contorno, produzido fora").
- Materiais usam a mesma ficha com o ícone de camadas no centro.

### 3.12 Estados vazio, carregando e erro
- **Vazio:** ilustração 88 (quadrado branco com contorno tracejado `contornoNeutro` e ícone ao centro), título 18/700, texto 15/22 `textoSecundario`, tudo centralizado.
- **Carregando:** anel tracejado `borda` de 44 px com arco sólido `brandLinha` girando. Sem texto.
- **Erro:** quadrado tracejado `erro` de 64 px com "!" e o texto "Não foi possível carregar." (18/700).

### 3.13 Menu
Cartão branco, borda 1 px, raio 14, sombra, largura ≈ 252, ancorado abaixo do botão ⋮ (que fica com fundo `trilho` enquanto aberto). Itens de 52 com ícone 22 + texto 15/600.

### 3.14 Grade de mesa de corte
Só no topo do Início: grade de 16 px em linhas `grade` de 1 px, ~190 px de altura, desaparecendo gradualmente para baixo. Decorativa (excluir da acessibilidade).

### 3.15 Logotipo no topo do Início
- **Sem empresa configurada (padrão, hoje):** marca de registro (círculo + cruz em grafite, ponto central `brand`) + wordmark "StickerControl".
- **Com empresa (futuro, seção 7):** logo da empresa (32 px) + nome da empresa (Schibsted 700 18).

---

## 4. Telas

### 4.1 Início — `historico_page.dart`
Grade de mesa (3.14), barra com logotipo (3.15) e menu ⋮, título "Orçamentos" (36), lista em bloco (3.11), botão flutuante "Novo orçamento" (3.7).
- Item: título = descrição ?? material ?? "Sem descrição"; metadado = data completa no formato atual (`19/10/2026 14:32`) · "Própria"/"Terceirizada"; valor final à direita.
- **Vazio:** "Nenhum orçamento salvo ainda." / "Toque em "Novo orçamento" para começar."
- **Carregando:** indicador (3.12).
- **Erro:** ver 5.2.
- **Menu:** Materiais · Nome da empresa · Mensagem do WhatsApp (3.13).
- **Avisos de rodapé** (ao voltar de outras telas): "Orçamento salvo." (sucesso) · "Orçamento salvo, mas não foi possível abrir o WhatsApp." (alerta) · "Mensagem salva." (sucesso).
- Imagens: `01-inicio-lista.png`, `01-inicio-vazio.png`, `01-inicio-estados.png`.

### 4.2 Diálogo "Nome da empresa"
Diálogo (3.10) com título "Nome da empresa", célula de texto em foco, ajuda "Aparece no topo da mensagem de WhatsApp.", ações Cancelar / **Salvar na cor da marca**. Abre com o teclado. Vazio continua permitido.
Imagem: `02-dialogo-nome-empresa.png`.

### 4.3 Novo orçamento — `novo_orcamento_page.dart`
Estrutura "B": tudo numa rolagem só, resultado e botões **no fim** do formulário (nada fixo no rodapé). Ordem:
1. Seletor de modalidade (3.3).
2. **Própria:** seletor de material (3.4) → moldura Comprimento | Largura (3.2, 3.5).
   **Terceirizada:** moldura Valor do fornecedor (`R$`) / Largura (informativa) + ajuda "Não altera o preço.".
3. Moldura Acréscimo (`%`) / Descrição.
4. Resultado (3.6).
5. Botões: Salvar (primário) · Salvar e enviar por WhatsApp (secundário).

Estados: própria preenchida · terceirizada · incompleto · sem material (cartão "Nenhum material cadastrado" / "Cadastre um material para calcular." + botão secundário "Cadastrar", acréscimo e descrição continuam visíveis) · erro de validação (mensagens atuais, ex.: "Valor inválido, ex.: 1,50.") · aviso de largura (3.8, texto atual) · teclado aberto (o campo em edição fica visível; o resultado segue no fim da rolagem) · salvando (botões desativados) · **carregando materiais** (5.1) · **duplicado com material excluído** (5.3).
O título continua "Novo orçamento" também ao duplicar.
Imagens: `03-novo-propria.png`, `03-novo-terceirizada.png`, `03-novo-estados.png`.

### 4.4 Orçamento (detalhe) — `detalhe_orcamento_page.dart`
Barra "Orçamento". Cartão de dados: cabeçalho com ficha de modalidade + título (descrição ?? material) + "data · modalidade"; abaixo, linhas rótulo/valor só dos campos que existem (Material "Vinil Branco · R$ 50,00 / m", Largura, Comprimento, Fornecedor). Resultado (3.6) com os valores salvos. Botões: Enviar por WhatsApp (primário) · Duplicar (secundário) · Excluir (destrutivo de texto).
Diálogo "Excluir orçamento?" / "Essa ação não pode ser desfeita." (Cancelar / Excluir vermelho). Falha: aviso de rodapé "Não foi possível abrir o WhatsApp.".
Imagens: `04-detalhe-propria.png`, `04-detalhe-estados.png`.

### 4.5 Materiais — `materiais_page.dart`
Barra "Materiais", lista em bloco: ficha de material + nome + "Largura 1,10 m" + "R$ 50,00 / m". Botão flutuante "Novo material" (3.7, cor da marca + linha de corte).
Estados: lista · vazio ("Nenhum material cadastrado" / "Cadastre o primeiro material para poder fazer orçamentos.") · carregando · erro ("Não foi possível carregar.").
Imagens: `05-materiais-lista.png`, `05-materiais-estados.png`.

### 4.6 Novo / Editar material — `material_form_page.dart`
Barra "Novo material" ou "Editar material" (com ícone de excluir em `erro` ao editar). Células separadas: "Nome do material" e "Preço por metro" (`R$` … `/ m`). Linha "Largura fixa: 1,10 m." com cota vertical. Botão Salvar (primário).
Validações atuais: "Informe o nome." · "Informe um valor válido, ex.: 50,00." · "O preço deve ser maior que zero." · "Já existe um material com esse nome.".
Diálogo "Excluir material?" / "Orçamentos já salvos com "<nome>" não são alterados." (Cancelar / Excluir vermelho).
Imagens: `06-material-novo.png`, `06-material-estados.png`.

### 4.7 Mensagem do WhatsApp — `modelo_mensagem_page.dart`
Barra "Mensagem do WhatsApp". Texto de instrução atual (14/21 `textoSecundario`). Célula grande "Modelo da mensagem" (texto 15/22). Chips de variáveis: botões brancos, borda 1 px, raio 10, altura 40, Schibsted 600 14 (dica/tooltip atual mantida). "Prévia" (Schibsted 700 15) + cartão branco com o texto montado ("(mensagem vazia)" em `rotulo` quando vazio). Salvar (primário) · Restaurar padrão (texto, sem confirmação — decisão mantida).
Imagens: `07-mensagem-topo.png`, `07-mensagem-estados.png`.

---

## 5. Mudanças de comportamento aprovadas (fazer em fase separada)

### 5.1 Carregamento no Novo orçamento
Hoje, na modalidade Própria, enquanto o stream de materiais ainda não emitiu, a tela mostra "Nenhum material cadastrado". Novo: enquanto `snapshot.data == null`, mostrar no lugar do seletor de material + medidas uma célula branca (altura ≈ 156) com o indicador de carregamento (3.12). Acréscimo, descrição e o resultado vazio continuam visíveis; botões desativados. Terceirizada não muda.

### 5.2 Erro no Início
Se o stream de orçamentos der erro (`snapshot.hasError`), mostrar o estado de erro (3.12) com "Não foi possível carregar.", igual à tela de Materiais.

### 5.3 Duplicar com material excluído
Ao abrir o Novo orçamento a partir de "Duplicar" (`base != null`) na modalidade Própria, se a lista de materiais já carregou e nenhum material tem o nome do original, mostrar logo abaixo do seletor o aviso amarelo (3.8) com ícone de informação: **"O material original não existe mais. Escolha outro."**. Os demais campos continuam preenchidos; o aviso some quando o usuário escolhe um material.

Cada uma dessas três precisa de teste de widget novo.

---

## 6. O que não muda
Cálculos, arredondamentos, validações, campos, ordem do fluxo, navegação, textos (exceto os de 5.1–5.3), dados salvos, mensagem do WhatsApp, "Restaurar padrão" sem confirmação, nome da empresa podendo ficar vazio.

---

## 7. Personalização por empresa
| | Situação |
|---|---|
| Nome da empresa | **Existe hoje** (diálogo do menu); usado na mensagem e na prévia ("Sua Empresa" quando vazio). |
| Nome da empresa no topo do Início | Futuro (3.15). Hoje o topo mostra a marca StickerControl. |
| Logotipo | Futuro. Ainda **sem tela de configuração** — decisão adiada. |
| Cor principal | Futuro. Nesta implementação, `brand` fica fixo em `#C2185B`, mas tudo que usa a marca deve ler de **um só lugar** (ex.: `ThemeExtension`), com as derivadas da 2.2 calculadas a partir dele. |

Onde a cor da marca aparece: adesivo de preço, botões flutuantes, bolinha do segmento selecionado, foco de campos, ficha "Própria", ícone de material, arco do carregamento, ponto da marca de registro, "Salvar" do diálogo do nome da empresa. Todo o resto é fixo.

---

## 8. Fases sugeridas
1. **Tema:** tokens (2.1–2.4) em `ThemeData` + `ThemeExtension`; fontes como assets; funções de contraste/mistura da 2.2 com testes unitários (ex.: amarelo `#F2C200` → `onBrand` grafite).
2. **Componentes** (seção 3), com testes de widget simples. A linha de corte e as fichas exigem `CustomPainter` (o Flutter não tem borda tracejada pronta).
3. **Telas**, uma por fase: Início → Novo orçamento → Detalhe → Materiais → Formulário de material → Mensagem. Conferir cada uma com a imagem correspondente.
4. **Comportamentos 5.1–5.3**, com testes novos.

Critério de pronto em toda fase: `flutter analyze` limpo, `flutter test` verde, tela conferida no emulador contra a imagem.

---

## 9. Mapa de imagens (`design/telas/`)

Exportar cada prancheta do canvas com o nome abaixo. As pranchetas "estados" são uma faixa com várias telas lado a lado, na ordem indicada.

| Arquivo | Prancheta no canvas | Conteúdo |
|---|---|---|
| `00-identidade-1.png` e `00-identidade-2.png` | Direção 4 · Recorte — identidade | Paleta, tipografia, componentes |
| `01-inicio-lista.png` | Recorte · Início (padrão StickerControl) | Início com dados |
| `01-inicio-vazio.png` | Início · vazio | Estado vazio |
| `01-inicio-estados.png` | Início · carregando · erro · menu · avisos… | carregando, erro, menu, "Orçamento salvo.", falha WhatsApp, "Mensagem salva.", empresa Corte Fino |
| `02-dialogo-nome-empresa.png` | Diálogo · Nome da empresa | Diálogo com teclado |
| `03-novo-propria.png` | Recorte · Novo orçamento (padrão) | Própria preenchida |
| `03-novo-terceirizada.png` | Novo orçamento · Terceirizada | Terceirizada preenchida |
| `03-novo-estados.png` | Novo orçamento · carregando · duplicado… | carregando, duplicado sem material, incompleto, sem material, erro, aviso de largura, teclado, salvando |
| `04-detalhe-propria.png` | Orçamento (detalhe) · Própria | Detalhe própria |
| `04-detalhe-estados.png` | Detalhe · terceirizada · excluir… | terceirizada, confirmar exclusão, falha WhatsApp, marca amarela |
| `05-materiais-lista.png` | Materiais · lista | Lista |
| `05-materiais-estados.png` | Materiais · vazio · carregando · erro · empresa | vazio, carregando, erro, marca amarela |
| `06-material-novo.png` | Novo material · inicial | Formulário vazio |
| `06-material-estados.png` | Material · validação · nome repetido… | validação, nome repetido, teclado, editar, excluir |
| `07-mensagem-topo.png` | Mensagem do WhatsApp · topo | Topo da tela |
| `07-mensagem-estados.png` | Mensagem · prévia e ações… | prévia e ações, teclado, vazia, com nome da empresa |
| `08-empresa-bentevi.png` | Recorte · Bentevi Adesivos (amarelo) | Personalização futura |
| `08-empresa-corte-fino.png` | Recorte · Corte Fino Visual (violeta) | Personalização futura |
| `99-mapa.png` | Mapa do app | Inventário, fluxo e decisões |

Os nomes de empresas e os valores nas imagens são **fictícios**.
