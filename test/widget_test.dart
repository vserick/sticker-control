import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_control/main.dart';

void main() {
  testWidgets('app abre com o título', (tester) async {
    await tester.pumpWidget(const StickerControlApp());
    expect(find.text('Sticker Control'), findsOneWidget);
  });
}
