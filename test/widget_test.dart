import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_activity2/main.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('dashboard reflects global display-name state', (tester) async {
    final settings = AppSettings()..setDisplayName('Alex');
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: settings,
        child: const PortfolioApp(),
      ),
    );
    expect(find.text('Welcome, Alex!'), findsOneWidget);
  });
}
