# Referência HTML do design Recorte

Fontes das pranchetas do canvas de design, só para **consulta de valores exatos** (cores, tamanhos, raios, espaçamentos, textos). Não fazem parte do app e não precisam rodar — dependem do editor do canvas para desenhar.

A especificação oficial é `../recorte.md`; as imagens aprovadas ficam em `../telas/`.

| Arquivo | Tela |
|---|---|
| `D4Recorte.dc.html` | Folha de identidade (paleta, tipografia, componentes) |
| `D4Inicio.dc.html` | Início com dados (aprovado) |
| `D4Novo.dc.html` | Novo orçamento · Própria preenchida (aprovado) |
| `D4EmpresaA.dc.html` / `D4EmpresaB.dc.html` | Personalização futura (empresas fictícias) |
| `R1Inicio.dc.html` | Início — estados (`estado`: vazio, carregando, erro, lista, menu, salvo, falhaWhats, msgSalva) |
| `R1Empresa.dc.html` | Diálogo "Nome da empresa" |
| `R2Novo.dc.html` | Novo orçamento — estados (terceirizada, incompleto, semMaterial, erro, aviso, teclado, salvando, carregando, duplicado) |
| `R3Detalhe.dc.html` | Orçamento (detalhe) — própria, terceirizada, excluir, falhaWhats |
| `R4Materiais.dc.html` | Materiais — lista, vazio, carregando, erro |
| `R4Material.dc.html` | Novo/Editar material — novo, validacao, repetido, teclado, editar, excluir |
| `R5Mensagem.dc.html` | Mensagem do WhatsApp — topo, previa, teclado, vazia, empresa |
| `RTeclado.dc.html` | Teclado ilustrativo (não implementar) |
| `R*Estados.dc.html` | Faixas que montam vários estados lado a lado |
| `R0Mapa.dc.html` | Mapa do app: inventário, fluxo e decisões |

Os estados ficam no bloco `<script>` de cada arquivo (função `renderVals`). As cores derivadas da marca (`onBrand`, `linhaMarca`, `textoMarca`, `tint`, `dobra`) são calculadas ali — mesma regra da seção 2.2 do `recorte.md`.
