import 'package:flutter_driver/driver_extension.dart';
import 'package:sticker_control/main.dart' as app;

/// Entrada usada só para automação (Dart/Flutter MCP e `flutter drive`).
/// O app de produção continua em `lib/main.dart`, sem a extensão.
void main() {
  enableFlutterDriverExtension();
  app.main();
}
