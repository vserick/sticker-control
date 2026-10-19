import '../../logic/mensagem_whatsapp.dart';
import '../../logic/orcamento.dart';
import '../../servicos.dart';

/// Monta a mensagem com o modelo e o nome da empresa configurados (só preço
/// final) e abre o WhatsApp. `false` se não foi possível abrir.
Future<bool> enviarPorWhatsapp(
  Servicos servicos,
  RascunhoOrcamento orcamento,
) async {
  final empresa = await servicos.configuracoes.lerNomeEmpresa();
  final modelo = await servicos.configuracoes.lerModeloMensagem();
  return servicos.whatsapp.enviar(
    montarMensagemWhatsapp(orcamento, empresa: empresa, modelo: modelo),
  );
}
