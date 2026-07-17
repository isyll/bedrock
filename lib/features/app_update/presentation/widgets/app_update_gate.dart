import 'dart:async';

import 'package:bedrock/app/router/app_router.dart';
import 'package:bedrock/core/extensions/context_extensions.dart';
import 'package:bedrock/features/app_update/presentation/cubit/app_update_cubit.dart';
import 'package:bedrock/shared/widgets/adaptive/adaptive_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppUpdateGate extends StatelessWidget {
  const AppUpdateGate({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppUpdateCubit, AppUpdateState>(
      listenWhen: (previous, current) =>
          current.updateAvailable && !previous.updateAvailable,
      listener: (context, state) => unawaited(_promptForUpdate(context)),
      child: child,
    );
  }

  Future<void> _promptForUpdate(BuildContext context) async {
    final cubit = context.read<AppUpdateCubit>();
    final navigatorContext = AppRouter.rootNavigatorKey.currentContext;
    if (navigatorContext == null) return;

    final l10n = navigatorContext.l10n;
    final accepted = await showConfirmDialog(
      navigatorContext,
      title: l10n.updateAvailableTitle,
      message: l10n.updateAvailableMessage,
      confirmLabel: l10n.updateButton,
      cancelLabel: l10n.updateLaterButton,
    );

    if (accepted) {
      cubit.clear();
      await cubit.openStore();
    } else {
      await cubit.dismiss();
    }
  }
}
