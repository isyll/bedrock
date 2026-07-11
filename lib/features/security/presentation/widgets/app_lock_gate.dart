import 'package:bedrock/features/security/presentation/cubit/app_lock_cubit.dart';
import 'package:bedrock/features/security/presentation/pages/lock_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppLockGate extends StatefulWidget {
  const AppLockGate({required this.child, super.key});

  final Widget child;

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> {
  late final AppLifecycleListener _lifecycleListener = AppLifecycleListener(
    onHide: () => context.read<AppLockCubit>().lock(),
  );

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = context.select<AppLockCubit, bool>(
      (cubit) => cubit.state.isLocked,
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (isLocked) const LockScreen(),
      ],
    );
  }
}
