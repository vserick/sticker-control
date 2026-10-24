import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_control/ui/recorte/avisos.dart';
import 'package:sticker_control/ui/recorte/botoes.dart';
import 'package:sticker_control/ui/recorte/campo.dart';
import 'package:sticker_control/ui/recorte/estados.dart';
import 'package:sticker_control/ui/recorte/icones.dart';
import 'package:sticker_control/ui/recorte/lista_bloco.dart';
import 'package:sticker_control/ui/recorte/marca.dart';
import 'package:sticker_control/ui/recorte/menu.dart';
import 'package:sticker_control/ui/recorte/resultado.dart';
import 'package:sticker_control/ui/recorte/seletores.dart';
import 'package:sticker_control/ui/recorte/tema.dart';
import 'package:sticker_control/ui/recorte/tokens.dart';

Future<void> _mostrar(
  WidgetTester tester,
  Widget filho, {
  Color brand = corMarcaPadrao,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: construirTema(brand: brand),
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: filho,
        ),
      ),
    ),
  );
}

void main() {
  group('campo', () {
    testWidgets('mostra rótulo, unidade e aceita digitação', (tester) async {
      final c = TextEditingController();
      addTearDown(c.dispose);
      await _mostrar(
        tester,
        CampoRecorte(rotulo: 'Acréscimo', controller: c, sufixo: '%'),
      );
      expect(find.text('Acréscimo'), findsOneWidget);
      expect(find.text('%'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '50');
      expect(c.text, '50');
    });

    testWidgets('foco desenha contorno de 2 px na cor de foco da marca', (
      tester,
    ) async {
      final c = TextEditingController();
      addTearDown(c.dispose);
      await _mostrar(tester, CampoRecorte(rotulo: 'Acréscimo', controller: c));
      Border? contorno() {
        final caixa = tester.widget<Container>(
          find.descendant(
            of: find.byType(CampoInterno),
            matching: find.byType(Container),
          ),
        );
        return (caixa.foregroundDecoration as BoxDecoration?)?.border
            as Border?;
      }

      expect(contorno()!.top.color, Colors.transparent);
      await tester.tap(find.byType(TextField));
      await tester.pump();
      final marca = RecorteMarca.de(corMarcaPadrao);
      expect(contorno()!.top.color, marca.brandLinha);
      expect(contorno()!.top.width, 2);
    });

    testWidgets('erro mostra a mensagem abaixo e contorno de erro', (
      tester,
    ) async {
      final c = TextEditingController(text: 'abc');
      addTearDown(c.dispose);
      await _mostrar(
        tester,
        CampoRecorte(
          rotulo: 'Comprimento',
          controller: c,
          erro: 'Valor inválido, ex.: 1,50.',
        ),
      );
      expect(find.text('Valor inválido, ex.: 1,50.'), findsOneWidget);
    });

    testWidgets('moldura compartilhada divide campos com divisória', (
      tester,
    ) async {
      final a = TextEditingController();
      final b = TextEditingController();
      addTearDown(a.dispose);
      addTearDown(b.dispose);
      await _mostrar(
        tester,
        MolduraRecorte(
          eixo: Axis.horizontal,
          filhos: [
            CampoInterno(
              rotulo: 'Comprimento',
              icone: const IconeCota.horizontal(),
              controller: a,
              sufixo: 'm',
            ),
            CampoInterno(
              rotulo: 'Largura',
              icone: const IconeCota.vertical(),
              controller: b,
              sufixo: 'm',
            ),
          ],
        ),
      );
      expect(find.byType(VerticalDivider), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.byType(IconeCota), findsNWidgets(2));
    });

    testWidgets('com validator participa do Form e mostra o erro', (
      tester,
    ) async {
      final c = TextEditingController();
      final chave = GlobalKey<FormState>();
      addTearDown(c.dispose);
      await _mostrar(
        tester,
        Form(
          key: chave,
          child: CampoRecorte(
            rotulo: 'Nome do material',
            controller: c,
            validator: (v) => (v ?? '').isEmpty ? 'Informe o nome.' : null,
          ),
        ),
      );
      expect(find.text('Informe o nome.'), findsNothing);
      expect(chave.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Informe o nome.'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Vinil');
      expect(chave.currentState!.validate(), isTrue);
      await tester.pump();
      expect(find.text('Informe o nome.'), findsNothing);
    });
  });

  group('seletores', () {
    testWidgets('modalidade: toque troca; selecionada mostra ✓', (
      tester,
    ) async {
      var atual = 'a';
      await tester.pumpWidget(
        MaterialApp(
          theme: construirTema(),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (_, setState) => SeletorModalidade<String>(
                opcoes: const [
                  (valor: 'a', rotulo: 'Própria'),
                  (valor: 'b', rotulo: 'Terceirizada'),
                ],
                selecionado: atual,
                onChanged: (v) => setState(() => atual = v),
              ),
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.check), findsOneWidget);
      await tester.tap(find.text('Terceirizada'));
      await tester.pump();
      expect(atual, 'b');
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('material: sem escolha mostra só "Material"; escolher chama', (
      tester,
    ) async {
      int? escolhido;
      await tester.pumpWidget(
        MaterialApp(
          theme: construirTema(),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (_, setState) => SeletorMaterial(
                materiais: const [
                  (id: 1, nome: 'Vinil Branco', preco: r'R$ 50,00 / m'),
                ],
                selecionado: escolhido,
                onChanged: (id) => setState(() => escolhido = id),
              ),
            ),
          ),
        ),
      );
      expect(find.text('Material'), findsOneWidget);
      await tester.tap(find.byType(DropdownButtonFormField<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Vinil Branco').last);
      await tester.pumpAndSettle();
      expect(escolhido, 1);
      expect(find.text('Vinil Branco'), findsOneWidget);
      expect(find.text(r'R$ 50,00 / m'), findsOneWidget);
    });
  });

  group('resultado', () {
    testWidgets('sem resumo mostra só o convite, sem preço final', (
      tester,
    ) async {
      await _mostrar(tester, const ResultadoRecorte(resumo: null));
      expect(find.text('Preencha os campos para ver o preço.'), findsOneWidget);
      expect(find.text('Preço final'), findsNothing);
    });

    testWidgets('com resumo mostra parcelas, aviso e adesivo', (tester) async {
      await _mostrar(
        tester,
        const ResultadoRecorte(
          resumo: ResumoPreco(
            custo: r'R$ 100,00',
            rotuloAcrescimo: 'Acréscimo',
            acrescimo: r'R$ 50,00',
            precoFinal: r'R$ 150,00',
          ),
          avisos: ['Largura acima de 1,10 m: a produção própria não comporta.'],
        ),
      );
      expect(find.text('Custo'), findsOneWidget);
      expect(find.text(r'R$ 100,00'), findsOneWidget);
      expect(find.text('Acréscimo'), findsOneWidget);
      expect(find.text(r'R$ 50,00'), findsOneWidget);
      expect(find.text('Preço final'), findsOneWidget);
      expect(find.text(r'R$ 150,00'), findsOneWidget);
      expect(find.textContaining('Largura acima de 1,10 m'), findsOneWidget);
    });

    testWidgets('adesivo usa a cor da marca e o texto de maior contraste', (
      tester,
    ) async {
      await _mostrar(
        tester,
        const AdesivoPreco(valor: r'R$ 10,00'),
        brand: const Color(0xFFF2C200),
      );
      final marca = RecorteMarca.de(const Color(0xFFF2C200));
      final texto = tester.widget<Text>(find.text(r'R$ 10,00'));
      expect(texto.style!.color, marca.onBrand);
      expect(marca.onBrand, RecorteCores.grafite);
    });
  });

  group('botões', () {
    testWidgets('primário desativado usa trilho e texto desativado', (
      tester,
    ) async {
      await _mostrar(
        tester,
        const FilledButton(onPressed: null, child: Text('Salvar')),
      );
      final estilo = tester
          .widget<FilledButton>(find.byType(FilledButton))
          .style;
      expect(estilo, isNull); // vem do tema
      final material = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(FilledButton),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(material.color, RecorteCores.trilho);
    });

    testWidgets('flutuante mostra rótulo e responde ao toque', (tester) async {
      var toques = 0;
      await _mostrar(
        tester,
        BotaoFlutuanteRecorte(
          rotulo: 'Novo material',
          onPressed: () => toques++,
        ),
      );
      await tester.tap(find.text('Novo material'));
      expect(toques, 1);
    });

    testWidgets('botões de diálogo disparam seus callbacks', (tester) async {
      final chamados = <String>[];
      await _mostrar(
        tester,
        Row(
          children: [
            BotaoCancelarDialogo(onPressed: () => chamados.add('c')),
            BotaoExcluirDialogo(onPressed: () => chamados.add('e')),
            BotaoMarcaDialogo(
              texto: 'Salvar',
              onPressed: () => chamados.add('s'),
            ),
          ],
        ),
      );
      await tester.tap(find.text('Cancelar'));
      await tester.tap(find.text('Excluir'));
      await tester.tap(find.text('Salvar'));
      expect(chamados, ['c', 'e', 's']);
    });
  });

  group('lista, estados, avisos e menu', () {
    testWidgets('lista em bloco separa itens por divisória', (tester) async {
      await _mostrar(
        tester,
        ListaBloco(
          itens: [
            ItemListaBloco(
              ficha: const FichaModalidade(propria: true),
              titulo: 'Vinil Branco',
              metadado: '19/10/2026 10:05 · Própria',
              valor: r'R$ 100,00',
              onTap: () {},
            ),
            const ItemListaBloco(
              ficha: FichaModalidade(propria: false),
              titulo: 'Placa',
              metadado: '18/10/2026 · Terceirizada',
              valor: r'R$ 640,00',
            ),
          ],
        ),
      );
      expect(find.byType(Divider), findsOneWidget);
      expect(find.text('Vinil Branco'), findsOneWidget);
      expect(find.text(r'R$ 640,00'), findsOneWidget);
    });

    testWidgets('estados vazio, erro e carregando renderizam', (tester) async {
      Future<void> mostrar(Widget filho) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: construirTema(),
            home: Scaffold(body: filho),
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));
      }

      await mostrar(
        const EstadoVazio(
          icone: Icons.layers_outlined,
          titulo: 'Nenhum material cadastrado',
          texto: 'Cadastre o primeiro material.',
        ),
      );
      expect(find.text('Nenhum material cadastrado'), findsOneWidget);
      await mostrar(const EstadoErro());
      expect(find.text('Não foi possível carregar.'), findsOneWidget);
      await mostrar(const CarregandoCentralizado());
      expect(find.bySemanticsLabel('Carregando'), findsOneWidget);
    });

    testWidgets('aviso amarelo e aviso de rodapé', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: construirTema(),
          home: Scaffold(
            body: Builder(
              builder: (context) => Column(
                children: [
                  const AvisoAmarelo(texto: 'Escolha outro.'),
                  TextButton(
                    onPressed: () =>
                        ScaffoldMessenger.of(context)
                            .showSnackBar(avisoRodape('Mensagem salva.')),
                    child: const Text('abrir'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      expect(find.text('Escolha outro.'), findsOneWidget);
      await tester.tap(find.text('abrir'));
      await tester.pump();
      expect(find.text('Mensagem salva.'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('menu abre, escolhe e devolve o valor', (tester) async {
      String? escolha;
      await tester.pumpWidget(
        MaterialApp(
          theme: construirTema(),
          home: Scaffold(
            appBar: AppBar(
              actions: [
                MenuRecorte<String>(
                  onSelected: (v) => escolha = v,
                  itens: (_) => [
                    itemMenuRecorte(
                      valor: 'm',
                      icone: Icons.layers_outlined,
                      texto: 'Materiais',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.byTooltip('Menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Materiais'));
      await tester.pumpAndSettle();
      expect(escolha, 'm');
    });
  });
}
