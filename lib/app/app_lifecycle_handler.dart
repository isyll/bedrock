import 'dart:async';

import 'package:bedrock/features/app_update/presentation/cubit/app_update_cubit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppLifecycleHandler extends StatefulWidget {
  const AppLifecycleHandler({required this.child, super.key});

  final Widget child;

  @override
  State<AppLifecycleHandler> createState() => _AppLifecycleHandlerState();
}

class _AppLifecycleHandlerState extends State<AppLifecycleHandler> {
  late final _lifecycleListener = AppLifecycleListener(onResume: _onResume);

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    unawaited(context.read<AppUpdateCubit>().check());
  }

  void _onResume() {
    unawaited(context.read<AppUpdateCubit>().check());
  }
}
