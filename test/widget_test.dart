import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_control/main.dart';

import 'support/servicos_fake.dart';

void main() {
  testWidgets('app abre no histórico de orçamentos', (tester) async {
    await tester.pumpWidget(
      StickerControlApp(servicos: ServicosFake().servicos),
    );
    await tester.pumpAndSettle();
    expect(find.text('Orçamentos'), findsOneWidget);
    expect(find.text('Novo orçamento'), findsOneWidget);
  });
}
