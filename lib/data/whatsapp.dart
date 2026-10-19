import 'package:url_launcher/url_launcher.dart';

import '../logic/mensagem_whatsapp.dart';

abstract class EnviadorWhatsApp {
  /// Abre o WhatsApp com [mensagem] pronta. `false` se não foi possível abrir.
  Future<bool> enviar(String mensagem);
}

class UrlLauncherWhatsApp implements EnviadorWhatsApp {
  @override
  Future<bool> enviar(String mensagem) async {
    try {
      return await launchUrl(
        linkWhatsapp(mensagem),
        mode: LaunchMode.externalApplication,
      );
    } on Exception {
      return false;
    }
  }
}
