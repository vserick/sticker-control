import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_control/logic/formatacao.dart';
import 'package:sticker_control/logic/mensagem_whatsapp.dart';
import 'package:sticker_control/logic/orcamento.dart';

final _agora = DateTime(2026, 10, 19);

// Custo (R$ 100,00), acréscimo (37,5%) e final (R$ 137,50) distintos para
// provar que só o final vai na mensagem.
const _proprio = RascunhoOrcamento(
  tipo: TipoProducao.propria,
  descricao: 'Adesivo de porta',
  larguraMm: 1100,
  comprimentoMm: 2000,
  materialNome: 'Vinil branco',
  precoPorMetroCentavos: 5000,
  custoCentavos: 10000,
  acrescimoBp: 3750,
  finalCentavos: 13750,
);

const _terceirizada = RascunhoOrcamento(
  tipo: TipoProducao.terceirizada,
  descricao: 'Banner',
  larguraMm: 1500,
  fornecedorCentavos: 2000,
  custoCentavos: 2000,
  acrescimoBp: 10000,
  finalCentavos: 4000,
);

String _montar(RascunhoOrcamento o, {String? empresa, String? modelo}) =>
    montarMensagemWhatsapp(o, empresa: empresa, modelo: modelo, agora: _agora);

void main() {
  group('modelo padrão', () {
    test('própria: cabeçalho, item, descrição, medidas, valor e data', () {
      expect(
        _montar(_proprio, empresa: 'Adesivos Exemplo'),
        '🏷️ *Adesivos Exemplo*\n'
        '━━━━━━━━━━━━━━\n'
        '*ORÇAMENTO DE ADESIVO*\n'
        '━━━━━━━━━━━━━━\n'
        '\n'
        '▪️ *Item:* Vinil branco\n'
        '▪️ *Descrição:* Adesivo de porta\n'
        '▪️ *Medidas:* 1,10 × 2,00 m\n'
        '\n'
        '💰 *Valor: R\$ 137,50*\n'
        '\n'
        '📅 19/10/2026',
      );
    });

    test('nunca contém custo, percentual nem preço por metro', () {
      final m = _montar(_proprio, empresa: 'Adesivos Exemplo');
      expect(m, isNot(contains('100,00')));
      expect(m, isNot(contains('%')));
      expect(m, isNot(contains('50,00')));
    });

    test('terceirizada omite o item e mostra a largura', () {
      final m = _montar(_terceirizada);
      expect(m, isNot(contains('Item')));
      expect(m, contains('▪️ *Descrição:* Banner'));
      expect(m, contains('▪️ *Medidas:* largura 1,50 m'));
      expect(m, contains('💰 *Valor: R\$ 40,00*'));
    });

    test('sem empresa e sem descrição, as linhas somem sem sobrar vazios', () {
      const r = RascunhoOrcamento(
        tipo: TipoProducao.terceirizada,
        fornecedorCentavos: 2000,
        custoCentavos: 2000,
        acrescimoBp: 10000,
        finalCentavos: 4000,
      );
      expect(
        _montar(r),
        '━━━━━━━━━━━━━━\n'
        '*ORÇAMENTO DE ADESIVO*\n'
        '━━━━━━━━━━━━━━\n'
        '\n'
        '💰 *Valor: R\$ 40,00*\n'
        '\n'
        '📅 19/10/2026',
      );
    });

    test('modelo nulo ou em branco usa o padrão', () {
      final padrao = _montar(_proprio);
      expect(_montar(_proprio, modelo: '   \n '), padrao);
      expect(_montar(_proprio, modelo: null), padrao);
    });
  });

  group('modelo próprio', () {
    test('substitui todas as variáveis', () {
      expect(
        _montar(
          _proprio,
          empresa: 'Adesivos Exemplo',
          modelo:
              '{empresa}: {descricao} em {material}, {largura} x {comprimento}'
              ' ({medidas}) = {valor} em {data}',
        ),
        'Adesivos Exemplo: Adesivo de porta em Vinil branco, 1,10 m x 2,00 m '
        '(1,10 × 2,00 m) = R\$ 137,50 em 19/10/2026',
      );
    });

    test('mantém variável desconhecida como digitada', () {
      expect(
        _montar(_proprio, modelo: 'Total {valor} {custo}'),
        'Total R\$ 137,50 {custo}',
      );
    });

    test('não existem variáveis de custo nem de percentual', () {
      expect(variaveisMensagem.keys, isNot(contains('custo')));
      expect(variaveisMensagem.keys, isNot(contains('percentual')));
      expect(variaveisMensagem.keys, isNot(contains('acrescimo')));
    });

    test('valor digitado pelo usuário não é interpretado como variável', () {
      const r = RascunhoOrcamento(
        tipo: TipoProducao.propria,
        descricao: '{valor}',
        larguraMm: 1000,
        comprimentoMm: 1000,
        custoCentavos: 100,
        acrescimoBp: 0,
        finalCentavos: 100,
      );
      expect(_montar(r, modelo: '{descricao}'), '{valor}');
    });

    test('preserva linhas em branco simples e enxuga as repetidas', () {
      expect(
        _montar(_proprio, modelo: '\n\nOlá\n\n\n\n{valor}\n\n'),
        'Olá\n\nR\$ 137,50',
      );
    });

    test('aceita quebras de linha do Windows', () {
      expect(_montar(_proprio, modelo: 'A\r\nB {valor}'), 'A\nB R\$ 137,50');
    });

    test('orçamento salvo usa a data em que foi criado', () {
      final salvo = Orcamento(
        id: 1,
        criadoEm: DateTime(2026, 1, 5),
        tipo: TipoProducao.propria,
        larguraMm: 1000,
        comprimentoMm: 1000,
        custoCentavos: 100,
        acrescimoBp: 0,
        finalCentavos: 100,
      );
      expect(
        montarMensagemWhatsapp(salvo, modelo: '{data}', agora: _agora),
        '05/01/2026',
      );
    });
  });

  test('linkWhatsapp codifica a mensagem', () {
    final uri = linkWhatsapp('Olá\n*valor* R\$ 40,00');
    expect(uri.host, 'wa.me');
    expect(uri.queryParameters['text'], 'Olá\n*valor* R\$ 40,00');
  });

  group('formatação', () {
    test('formatarMetros', () {
      expect(formatarMetros(1100), '1,10');
      expect(formatarMetros(2000), '2,00');
      expect(formatarMetros(1125), '1,125');
      expect(formatarMetros(1050), '1,05');
      expect(formatarMetros(500), '0,50');
    });

    test('formatarPercentual', () {
      expect(formatarPercentual(5000), '50');
      expect(formatarPercentual(1250), '12,5');
      expect(formatarPercentual(1205), '12,05');
      expect(formatarPercentual(0), '0');
    });

    test('formatarData e formatarDataHora', () {
      expect(formatarData(DateTime(2026, 10, 5, 9, 7)), '05/10/2026');
      expect(formatarDataHora(DateTime(2026, 10, 5, 9, 7)), '05/10/2026 09:07');
    });
  });
}
