import 'dart:async';

import 'package:bedrock/core/error/error_messages.dart';
import 'package:bedrock/core/extensions/context_extensions.dart';
import 'package:bedrock/core/utils/validators.dart';
import 'package:bedrock/features/auth/presentation/cubit/sign_in_cubit.dart';
import 'package:bedrock/shared/widgets/buttons/app_button.dart';
import 'package:bedrock/shared/widgets/feedback/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    unawaited(
      context.read<SignInCubit>().submit(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocListener<SignInCubit, SignInState>(
      listenWhen: (previous, current) => current.failure != null,
      listener: (context, state) {
        showAppSnackBar(
          context,
          state.failure!.localizedMessage(l10n),
          kind: SnackBarKind.error,
        );
      },
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: l10n.emailLabel,
                hintText: l10n.emailHint,
                prefixIcon: const Icon(Icons.alternate_email),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: (value) => Validators.email(l10n, value),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: l10n.passwordLabel,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              validator: (value) => Validators.password(l10n, value),
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 24),
            BlocBuilder<SignInCubit, SignInState>(
              builder: (context, state) {
                return AppButton(
                  label: l10n.signInButton,
                  loading: state.isSubmitting,
                  onPressed: _submit,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
