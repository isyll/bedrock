import 'dart:async';

import 'package:bedrock/shared/widgets/adaptive/adaptive_progress_indicator.dart';
import 'package:bedrock/shared/widgets/feedback/app_loader.dart';
import 'package:bedrock/shared/widgets/feedback/loader_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildApp(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('AppLoader', () {
    testWidgets('shows a progress indicator', (tester) async {
      await tester.pumpWidget(buildApp(const AppLoader()));

      expect(find.byType(AdaptiveProgressIndicator), findsOneWidget);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('shows an optional message', (tester) async {
      await tester.pumpWidget(buildApp(const AppLoader(message: 'Syncing')));

      expect(find.text('Syncing'), findsOneWidget);
    });
  });

  group('LoaderOverlay', () {
    tearDown(LoaderOverlay.hide);

    testWidgets('show displays a blocking overlay above the page', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp(const Text('content')));

      LoaderOverlay.show(
        tester.element(find.text('content')),
        message: 'Please wait',
      );
      await tester.pump(const .new(milliseconds: 200));

      expect(LoaderOverlay.isVisible, isTrue);
      expect(find.byType(ModalBarrier), findsWidgets);
      expect(find.byType(AdaptiveProgressIndicator), findsOneWidget);
      expect(find.text('Please wait'), findsOneWidget);

      LoaderOverlay.hide();
      await tester.pump(const .new(milliseconds: 200));

      expect(LoaderOverlay.isVisible, isFalse);
      expect(find.byType(AdaptiveProgressIndicator), findsNothing);
    });

    testWidgets('show is idempotent while visible', (tester) async {
      await tester.pumpWidget(buildApp(const Text('content')));
      final context = tester.element(find.text('content'));

      LoaderOverlay.show(context);
      LoaderOverlay.show(context);
      await tester.pump(const .new(milliseconds: 200));

      expect(find.byType(AdaptiveProgressIndicator), findsOneWidget);
    });

    testWidgets('during hides the overlay after the operation', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp(const Text('content')));
      final completer = Completer<int>();

      final result = LoaderOverlay.during(
        tester.element(find.text('content')),
        completer.future,
      );
      await tester.pump(const .new(milliseconds: 200));
      expect(LoaderOverlay.isVisible, isTrue);

      completer.complete(7);
      expect(await result, 7);
      await tester.pump(const .new(milliseconds: 200));
      expect(LoaderOverlay.isVisible, isFalse);
    });

    testWidgets('during hides the overlay when the operation throws', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp(const Text('content')));

      await expectLater(
        LoaderOverlay.during(
          tester.element(find.text('content')),
          Future<void>.error(Exception('boom')),
        ),
        throwsException,
      );
      await tester.pump(const .new(milliseconds: 200));

      expect(LoaderOverlay.isVisible, isFalse);
    });
  });
}
