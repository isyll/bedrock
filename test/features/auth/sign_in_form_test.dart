import 'package:bedrock/core/config/app_config.dart';
import 'package:bedrock/core/l10n/app_localizations.dart';
import 'package:bedrock/core/session/session_manager.dart';
import 'package:bedrock/features/auth/domain/auth_repository.dart';
import 'package:bedrock/features/auth/presentation/cubit/sign_in_cubit.dart';
import 'package:bedrock/features/auth/presentation/widgets/sign_in_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  late ScriptedAuthApi api;
  late SessionManager session;
  late AuthRepository repository;

  setUp(() {
    api = .new(
      signInResult: .new(
        user: ScriptedAuthApi.demoUser,
        tokens: .new(
          accessToken: 'access',
          refreshToken: 'refresh',
          expiresAt: .now().toUtc().add(const .new(hours: 1)),
        ),
      ),
    );
    session = .new(config: _config, storage: InMemorySecureStorage());
    repository = .new(
      api: api,
      session: session,
      storage: InMemoryKeyValueStorage(),
      deviceInfoService: const FakeDeviceInfoService(),
    );
  });

  tearDown(() => session.dispose());

  Future<void> pumpForm(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider(
        create: (_) => SignInCubit(authRepository: repository),
        child: const Scaffold(body: SignInForm()),
      ),
    ),
  );

  testWidgets('shows required errors when submitting empty fields', (
    tester,
  ) async {
    await pumpForm(tester);

    await tester.tap(find.text('Sign in'));
    await tester.pump();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    expect(api.lastSignInDevice, isNull);
  });

  testWidgets('rejects an invalid email address', (tester) async {
    await pumpForm(tester);

    await tester.enterText(find.byType(TextFormField).first, 'not-an-email');
    await tester.enterText(find.byType(TextFormField).last, 'password123');
    await tester.tap(find.text('Sign in'));
    await tester.pump();

    expect(find.text('Enter a valid email address'), findsOneWidget);
    expect(api.lastSignInDevice, isNull);
  });

  testWidgets('submits when the credentials are valid', (tester) async {
    await pumpForm(tester);

    await tester.enterText(
      find.byType(TextFormField).first,
      'demo@example.com',
    );
    await tester.enterText(find.byType(TextFormField).last, 'password123');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Email is required'), findsNothing);
    expect(api.lastSignInDevice, isNotNull);
  });
}

const _config = AppConfig(
  flavor: .dev,
  appName: 'Test',
  apiBaseUrl: 'https://api.test',
);
