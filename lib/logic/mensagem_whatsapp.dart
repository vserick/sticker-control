import 'dinheiro.dart';
import 'formatacao.dart';
import 'orcamento.dart';

/// Modelo usado quando o usuário não definiu um próprio. `*texto*` é negrito
/// no WhatsApp.
const modeloMensagemPadrao = '''
🏷️ *{empresa}*
━━━━━━━━━━━━━━
*ORÇAMENTO DE ADESIVO*
━━━━━━━━━━━━━━

▪️ *Item:* {material}
▪️ *Descrição:* {descricao}
▪️ *Medidas:* {medidas}

💰 *Valor: {valor}*

📅 {data}''';

/// Variáveis disponíveis nos modelos, com a descrição mostrada no editor.
///
/// Custo, margem e percentual não existem aqui de propósito: a mensagem só
/// pode levar o preço final (ADR-005).
const variaveisMensagem = <String, String>{
  'empresa': 'Nome da empresa',
  'material': 'Material usado (só produção própria)',
  'descricao': 'Descrição do orçamento',
  'medidas': 'Largura × comprimento',
  'largura': 'Largura, ex.: 1,10 m',
  'comprimento': 'Comprimento, ex.: 2,00 m',
  'valor': 'Preço final',
  'data': 'Data do orçamento',
};

final _variavel = RegExp(r'\{(\w+)\}');

/// Texto enviado ao cliente, montado a partir de [modelo] (ou do
/// [modeloMensagemPadrao]). Nunca inclui custo, margem nem percentual.
///
/// Linhas cujas variáveis estão todas vazias (ex.: `{material}` na
/// terceirizada) são omitidas, e sobras de linhas em branco são enxugadas.
/// Variáveis desconhecidas ficam como o usuário digitou. [agora] só vale
/// para [RascunhoOrcamento]; um [Orcamento] salvo usa a própria data.
String montarMensagemWhatsapp(
  RascunhoOrcamento o, {
  String? empresa,
  String? modelo,
  DateTime? agora,
}) {
  final data = o is Orcamento ? o.criadoEm : (agora ?? DateTime.now());
  final valores = _valores(o, empresa, data);
  final texto = modelo == null || modelo.trim().isEmpty
      ? modeloMensagemPadrao
      : modelo;

  final linhas = <String>[];
  for (final linha in texto.replaceAll('\r\n', '\n').split('\n')) {
    var usouVariavel = false;
    var temConteudo = false;
    final resolvida = linha.replaceAllMapped(_variavel, (m) {
      final valor = valores[m[1]];
      if (valor == null) return m[0]!;
      usouVariavel = true;
      if (valor.isNotEmpty) temConteudo = true;
      return valor;
    });
    if (usouVariavel && !temConteudo) continue;
    linhas.add(resolvida.trimRight());
  }

  final saida = <String>[];
  for (final linha in linhas) {
    final duplicada = linha.isEmpty && (saida.isEmpty || saida.last.isEmpty);
    if (!duplicada) saida.add(linha);
  }
  while (saida.isNotEmpty && saida.last.isEmpty) {
    saida.removeLast();
  }
  return saida.join('\n');
}

Map<String, String> _valores(
  RascunhoOrcamento o,
  String? empresa,
  DateTime data,
) {
  final largura = o.larguraMm;
  final comprimento = o.comprimentoMm;
  final medidas = largura != null && comprimento != null
      ? '${formatarMetros(largura)} × ${formatarMetros(comprimento)} m'
      : largura != null
      ? 'largura ${formatarMetros(largura)} m'
      : '';
  return {
    'empresa': empresa?.trim() ?? '',
    'material': o.materialNome?.trim() ?? '',
    'descricao': o.descricao?.trim() ?? '',
    'medidas': medidas,
    'largura': largura == null ? '' : '${formatarMetros(largura)} m',
    'comprimento': comprimento == null
        ? ''
        : '${formatarMetros(comprimento)} m',
    'valor': formatarBrl(o.finalCentavos),
    'data': formatarData(data),
  };
}

/// Link `wa.me` que abre o WhatsApp com [mensagem] pronta para escolher o
/// contato.
Uri linkWhatsapp(String mensagem) =>
    Uri.parse('https://wa.me/?text=${Uri.encodeComponent(mensagem)}');
