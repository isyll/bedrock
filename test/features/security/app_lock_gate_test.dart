import 'package:bedrock/core/l10n/app_localizations.dart';
import 'package:bedrock/core/storage/storage_keys.dart';
import 'package:bedrock/features/security/presentation/cubit/app_lock_cubit.dart';
import 'package:bedrock/features/security/presentation/pages/lock_screen.dart';
import 'package:bedrock/features/security/presentation/widgets/app_lock_gate.dart';
import 'package:bedrock/services/biometrics/biometrics_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  Widget wrap(AppLockCubit cubit) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: BlocProvider.value(
      value: cubit,
      child: const AppLockGate(child: Scaffold(body: Text('secret'))),
    ),
  );

  testWidgets('overlays the lock screen while locked', (tester) async {
    final cubit = AppLockCubit(
      storage: InMemoryKeyValueStorage({StorageKeys.biometricLock: true}),
      biometrics: FakeBiometricsService(authResult: BiometricAuthResult.failed),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(wrap(cubit));
    await tester.pumpAndSettle();

    expect(find.byType(LockScreen), findsOneWidget);
  });

  testWidgets('shows the content when unlocked', (tester) async {
    final cubit = AppLockCubit(
      storage: InMemoryKeyValueStorage(),
      biometrics: FakeBiometricsService(),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(wrap(cubit));
    await tester.pumpAndSettle();

    expect(find.byType(LockScreen), findsNothing);
    expect(find.text('secret'), findsOneWidget);
  });
}
