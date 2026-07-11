import 'dart:async';

import 'package:bedrock/core/extensions/context_extensions.dart';
import 'package:bedrock/core/l10n/app_localizations.dart';
import 'package:bedrock/features/auth/presentation/bloc/session_bloc.dart';
import 'package:bedrock/features/security/presentation/cubit/app_lock_cubit.dart';
import 'package:bedrock/features/settings/presentation/cubit/locale_cubit.dart';
import 'package:bedrock/features/settings/presentation/cubit/theme_cubit.dart';
import 'package:bedrock/services/biometrics/biometrics_service.dart';
import 'package:bedrock/shared/animations/app_motion.dart';
import 'package:bedrock/shared/animations/fade_slide_in.dart';
import 'package:bedrock/shared/widgets/adaptive/adaptive_dialogs.dart';
import 'package:bedrock/shared/widgets/feedback/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final (index, section) in _sections(context, l10n).indexed)
              FadeSlideIn(
                delay: AppMotion.staggerInterval * index,
                child: section,
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _sections(BuildContext context, AppLocalizations l10n) {
    return [
      _SectionHeader(title: l10n.appearanceSection),
      Card(
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.brightness_6_outlined),
              title: Text(l10n.themeLabel),
              trailing: const _ThemeModeSelector(),
            ),
            const Divider(indent: 16, endIndent: 16),
            ListTile(
              leading: const Icon(Icons.language_outlined),
              title: Text(l10n.languageLabel),
              trailing: const _LocaleSelector(),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      _SectionHeader(title: l10n.securitySection),
      const Card(child: _BiometricLockTile()),
      const SizedBox(height: 24),
      _SectionHeader(title: l10n.accountSection),
      Card(
        child: ListTile(
          leading: Icon(Icons.logout, color: context.colorScheme.error),
          title: Text(
            l10n.signOutButton,
            style: TextStyle(color: context.colorScheme.error),
          ),
          onTap: () => _confirmSignOut(context),
        ),
      ),
    ];
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final l10n = context.l10n;
    final sessionBloc = context.read<SessionBloc>();
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.signOutConfirmTitle,
      message: l10n.signOutConfirmMessage,
      confirmLabel: l10n.signOutButton,
      destructive: true,
    );
    if (confirmed) {
      sessionBloc.add(const SessionSignOutRequested());
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title,
        style: context.textTheme.titleSmall?.copyWith(
          color: context.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ThemeModeSelector extends StatelessWidget {
  const _ThemeModeSelector();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, mode) {
        return MenuAnchor(
          builder: (context, controller, child) {
            return TextButton.icon(
              onPressed: () =>
                  controller.isOpen ? controller.close() : controller.open(),
              icon: const Icon(Icons.arrow_drop_down),
              label: Text(switch (mode) {
                ThemeMode.system => l10n.themeSystem,
                ThemeMode.light => l10n.themeLight,
                ThemeMode.dark => l10n.themeDark,
              }),
            );
          },
          menuChildren: [
            for (final option in ThemeMode.values)
              MenuItemButton(
                onPressed: () => context.read<ThemeCubit>().setMode(option),
                leadingIcon: Icon(
                  mode == option ? Icons.check : null,
                  size: 18,
                ),
                child: Text(switch (option) {
                  ThemeMode.system => l10n.themeSystem,
                  ThemeMode.light => l10n.themeLight,
                  ThemeMode.dark => l10n.themeDark,
                }),
              ),
          ],
        );
      },
    );
  }
}

class _BiometricLockTile extends StatelessWidget {
  const _BiometricLockTile();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<AppLockCubit, AppLockState>(
      builder: (context, state) {
        return SwitchListTile(
          secondary: const Icon(Icons.fingerprint),
          title: Text(l10n.biometricLockLabel),
          subtitle: Text(
            state.biometricsSupported
                ? l10n.biometricLockDescription
                : l10n.biometricsUnavailableMessage,
          ),
          value: state.isEnabled,
          onChanged: state.biometricsSupported
              ? (value) => unawaited(_toggle(context, enable: value))
              : null,
        );
      },
    );
  }

  Future<void> _toggle(BuildContext context, {required bool enable}) async {
    final cubit = context.read<AppLockCubit>();
    final l10n = context.l10n;

    final result = enable
        ? await cubit.enable(l10n.biometricPromptReason)
        : await cubit.disable(l10n.biometricPromptReason);

    final rejected =
        result == BiometricAuthResult.unavailable ||
        result == BiometricAuthResult.notEnrolled ||
        result == BiometricAuthResult.permanentlyLockedOut;
    if (rejected && context.mounted) {
      showAppSnackBar(
        context,
        l10n.biometricsUnavailableMessage,
        kind: SnackBarKind.error,
      );
    }
  }
}

class _LocaleSelector extends StatelessWidget {
  const _LocaleSelector();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<LocaleCubit, Locale?>(
      builder: (context, locale) {
        return MenuAnchor(
          builder: (context, controller, child) {
            return TextButton.icon(
              onPressed: () =>
                  controller.isOpen ? controller.close() : controller.open(),
              icon: const Icon(Icons.arrow_drop_down),
              label: Text(switch (locale?.languageCode) {
                'en' => l10n.languageEnglish,
                'fr' => l10n.languageFrench,
                _ => l10n.languageSystem,
              }),
            );
          },
          menuChildren: [
            MenuItemButton(
              onPressed: () => context.read<LocaleCubit>().setLocale(null),
              leadingIcon: Icon(locale == null ? Icons.check : null, size: 18),
              child: Text(l10n.languageSystem),
            ),
            MenuItemButton(
              onPressed: () =>
                  context.read<LocaleCubit>().setLocale(const Locale('en')),
              leadingIcon: Icon(
                locale?.languageCode == 'en' ? Icons.check : null,
                size: 18,
              ),
              child: Text(l10n.languageEnglish),
            ),
            MenuItemButton(
              onPressed: () =>
                  context.read<LocaleCubit>().setLocale(const Locale('fr')),
              leadingIcon: Icon(
                locale?.languageCode == 'fr' ? Icons.check : null,
                size: 18,
              ),
              child: Text(l10n.languageFrench),
            ),
          ],
        );
      },
    );
  }
}
