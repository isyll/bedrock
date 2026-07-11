import 'package:bedrock/shared/widgets/adaptive/adaptive_progress_indicator.dart';
import 'package:bedrock/shared/widgets/buttons/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpButton(
    WidgetTester tester, {
    required VoidCallback? onPressed,
    bool loading = false,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppButton(
            label: 'Continue',
            onPressed: onPressed,
            loading: loading,
          ),
        ),
      ),
    );
  }

  testWidgets('renders its label and reacts to taps', (tester) async {
    var pressed = false;
    await pumpButton(tester, onPressed: () => pressed = true);

    await tester.tap(find.text('Continue'));

    expect(pressed, isTrue);
  });

  testWidgets('is disabled without an onPressed callback', (tester) async {
    await pumpButton(tester, onPressed: null);

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('shows a progress indicator while loading', (tester) async {
    await pumpButton(tester, onPressed: () {}, loading: true);

    expect(find.byType(AdaptiveProgressIndicator), findsOneWidget);
    expect(find.text('Continue'), findsNothing);

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });
}
