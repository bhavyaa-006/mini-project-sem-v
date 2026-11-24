import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/auth_validators.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../data/auth_repository.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _emailError = AuthValidators.email(_email.text);
      _passwordError = AuthValidators.password(_password.text);
    });
    if (_emailError != null || _passwordError != null) return;

    await ref.read(authProvider.notifier).login(AuthCredentials(email: _email.text, password: _password.text));
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    if (auth.status == AuthStatus.signedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(AppRoutes.home);
      });
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - AppSpacing.lg * 2),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text('Welcome back', style: AppTypography.headline, textAlign: TextAlign.center),
                          const SizedBox(height: AppSpacing.xs),
                          Text('Sign in to continue', style: AppTypography.bodySmall, textAlign: TextAlign.center),
                          const SizedBox(height: AppSpacing.xl),
                          AppTextField(label: 'Email', hint: 'name@example.com', controller: _email, keyboardType: TextInputType.emailAddress, errorText: _emailError, onChanged: (_) => setState(() => _emailError = AuthValidators.email(_email.text))),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(label: 'Password', controller: _password, obscureText: true, errorText: _passwordError, onChanged: (_) => setState(() => _passwordError = AuthValidators.password(_password.text))),
                          const SizedBox(height: AppSpacing.xs),
                          Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => context.go(AppRoutes.forgotPassword), child: const Text('Forgot password?'))),
                          if (auth.status == AuthStatus.error) ...<Widget>[Text(auth.message ?? 'Login failed.', textAlign: TextAlign.center, style: AppTypography.bodySmall.copyWith(color: AppColors.danger)), const SizedBox(height: AppSpacing.sm)],
                          const SizedBox(height: AppSpacing.sm),
                          PrimaryButton(label: 'Login', isLoading: auth.status == AuthStatus.loading, onPressed: _submit),
                          const SizedBox(height: AppSpacing.md),
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[const Text('New here?'), TextButton(onPressed: () => context.go(AppRoutes.register), child: const Text('Register'))]),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
