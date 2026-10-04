import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_control/main.dart';

import 'support/material_repository_fake.dart';

void main() {
  testWidgets('app abre na lista de materiais', (tester) async {
    await tester.pumpWidget(
      StickerControlApp(materiais: MaterialRepositoryFake()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Materiais'), findsOneWidget);
  });
}
