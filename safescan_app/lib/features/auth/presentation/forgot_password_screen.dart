import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/router/routes.dart';
import '../../../core/router/navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/auth_validators.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _email = TextEditingController();
  String? _emailError;
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _emailError = AuthValidators.email(_email.text));
    if (_emailError != null) return;

    setState(() => _loading = true);
    await ref.read(authRepositoryProvider).forgotPassword(_email.text);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _sent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Forgot password')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: _sent
                    ? Column(
                        children: <Widget>[
                          const SizedBox(height: AppSpacing.xl),
                          const Icon(
                            Icons.mark_email_read_outlined,
                            size: 72,
                            color: AppColors.success,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            'Check your email',
                            style: AppTypography.headline,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'If an account exists for ${_email.text.trim()}, a mock reset link would be sent.',
                            textAlign: TextAlign.center,
                            style: AppTypography.body,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          PrimaryButton(
                            label: 'Back to Login',
                            onPressed: () =>
                                safeGoBack(context, AppRoutes.login),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            'Reset your password',
                            style: AppTypography.headline,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Enter your email and we will prepare a reset link.',
                            style: AppTypography.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          AppTextField(
                            label: 'Email',
                            hint: 'name@example.com',
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            errorText: _emailError,
                            onChanged: (_) => setState(
                              () => _emailError = AuthValidators.email(
                                _email.text,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          PrimaryButton(
                            label: 'Send reset link',
                            isLoading: _loading,
                            onPressed: _submit,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TextButton(
                            onPressed: () =>
                                safeGoBack(context, AppRoutes.login),
                            child: const Text('Back to Login'),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
