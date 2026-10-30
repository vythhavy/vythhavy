import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haru_cats/logic/game_controller.dart';
import 'package:haru_cats/main.dart';
import 'package:haru_cats/ui/dialogs/exit_game_dialog.dart';
import 'package:haru_cats/ui/screens/game_screen.dart';
import 'package:haru_cats/ui/screens/home_screen.dart';
import 'package:haru_cats/ui/widgets/game_popup_kit.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const HaruCatsApp());
    expect(find.byType(HaruCatsApp), findsOneWidget);
  });

  testWidgets('Back on HomeScreen shows ExitGameDialog and STAY dismisses it',
      (WidgetTester tester) async {
    await tester.pumpWidget(const HaruCatsApp());
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(ExitGameDialog), findsNothing);

    // Trigger system back on HomeScreen
    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.byType(ExitGameDialog), findsOneWidget);

    // Tap STAY button to remain in game
    await tester.tap(find.widgetWithText(Game3DButton, 'STAY').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.byType(ExitGameDialog), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('Gameplay blocks swipe/system back to HomeScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const HaruCatsApp());
    await tester.pump(const Duration(milliseconds: 50));

    final homeContext = tester.element(find.byType(HomeScreen));
    Navigator.of(homeContext).push(
      MaterialPageRoute(
        builder: (_) => const GameScreen(mode: GameMode.endless),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byType(GameScreen), findsOneWidget);

    // Trigger system back gesture while inside GameScreen
    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Must remain in GameScreen (blocked from popping back to HomeScreen)
    expect(find.byType(GameScreen), findsOneWidget);
    expect(find.byType(ExitGameDialog), findsNothing);
  });
}
