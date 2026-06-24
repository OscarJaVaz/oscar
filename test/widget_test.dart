import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:oscar/main.dart';

void main() {
  testWidgets('La app arranca y muestra la pantalla principal',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MyApp()),
    );

    await tester.pump();

    expect(find.text('Mis tareas'), findsOneWidget);
  });

  testWidgets('El botón de nueva tarea está visible en la pantalla principal',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MyApp()),
    );

    await tester.pump();

    expect(find.text('Nueva tarea'), findsOneWidget);
  });
}
