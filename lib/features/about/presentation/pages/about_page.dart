import 'dart:async';

import 'package:bedrock/core/config/app_config.dart';
import 'package:bedrock/core/di/injector.dart';
import 'package:bedrock/core/extensions/context_extensions.dart';
import 'package:bedrock/services/device/device_info_service.dart';
import 'package:bedrock/services/store/store_service.dart';
import 'package:bedrock/shared/animations/app_motion.dart';
import 'package:bedrock/shared/animations/fade_slide_in.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final config = sl<AppConfig>();
    final info = sl<DeviceInfoService>().info;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final (index, section) in _sections(
              context,
              config,
              info.fullVersion,
            ).indexed)
              FadeSlideIn(
                delay: AppMotion.staggerInterval * index,
                child: section,
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _sections(
    BuildContext context,
    AppConfig config,
    String fullVersion,
  ) {
    final l10n = context.l10n;

    return [
      const SizedBox(height: 24),
      Icon(Icons.layers_outlined, size: 72, color: context.colorScheme.primary),
      const SizedBox(height: 16),
      Text(
        config.appName,
        style: context.textTheme.headlineSmall?.copyWith(fontWeight: .w700),
        textAlign: .center,
      ),
      const SizedBox(height: 4),
      Text(
        l10n.aboutVersion(fullVersion),
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
        textAlign: .center,
      ),
      const SizedBox(height: 32),
      Card(
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.star_outline),
              title: Text(l10n.rateAppButton),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => unawaited(sl<StoreService>().openListing()),
            ),
            const Divider(indent: 16, endIndent: 16),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: Text(l10n.licensesButton),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showLicensePage(
                context: context,
                applicationName: config.appName,
                applicationVersion: fullVersion,
              ),
            ),
          ],
        ),
      ),
    ];
  }
}
