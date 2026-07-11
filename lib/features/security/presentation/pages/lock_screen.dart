import 'dart:async';

import 'package:bedrock/core/extensions/context_extensions.dart';
import 'package:bedrock/features/security/presentation/cubit/app_lock_cubit.dart';
import 'package:bedrock/shared/animations/staggered_column.dart';
import 'package:bedrock/shared/widgets/buttons/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  bool _authenticating = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const .new(maxWidth: 360),
              child: StaggeredColumn(
                mainAxisSize: .min,
                crossAxisAlignment: .stretch,
                children: [
                  Icon(
                    Icons.fingerprint,
                    size: 72,
                    color: context.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.lockedTitle,
                    style: context.textTheme.headlineSmall,
                    textAlign: .center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.lockedMessage,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: .center,
                  ),
                  const SizedBox(height: 32),
                  AppButton(
                    label: l10n.unlockButton,
                    loading: _authenticating,
                    onPressed: _unlock,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_unlock()));
  }

  Future<void> _unlock() async {
    if (_authenticating) return;
    setState(() => _authenticating = true);

    await context.read<AppLockCubit>().unlock(
      context.l10n.biometricPromptReason,
    );

    if (!mounted) return;
    setState(() => _authenticating = false);
  }
}
