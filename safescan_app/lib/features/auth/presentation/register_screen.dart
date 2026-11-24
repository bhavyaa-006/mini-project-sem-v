import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizing.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/auth_validators.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../data/auth_repository.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _validateLive() {
    setState(() {
      _nameError = AuthValidators.required(_name.text, 'Name');
      _emailError = AuthValidators.email(_email.text);
      _passwordError = AuthValidators.password(_password.text);
      _confirmError = AuthValidators.confirmPassword(_confirm.text, _password.text);
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    _validateLive();
    if (_nameError != null || _emailError != null || _passwordError != null || _confirmError != null) return;

    await ref.read(authProvider.notifier).register(RegistrationData(name: _name.text, email: _email.text, password: _password.text));
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(height: AppSpacing.lg),
                    Text('Create account', style: AppTypography.headline, textAlign: TextAlign.center),
                    const SizedBox(height: AppSpacing.xl),
                    AppTextField(label: 'Name', controller: _name, errorText: _nameError, onChanged: (_) => _validateLive()),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(label: 'Email', controller: _email, keyboardType: TextInputType.emailAddress, errorText: _emailError, onChanged: (_) => _validateLive()),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(label: 'Password', controller: _password, obscureText: true, errorText: _passwordError, onChanged: (_) => _validateLive()),
                    const SizedBox(height: AppSpacing.xs),
                    Text(AuthValidators.passwordHint(_password.text), style: AppTypography.bodySmall.copyWith(color: AppColors.secondaryText)),
                    const SizedBox(height: AppSpacing.sm),
                    AppTextField(label: 'Confirm password', controller: _confirm, obscureText: true, errorText: _confirmError, onChanged: (_) => _validateLive()),
                    if (auth.status == AuthStatus.error) ...<Widget>[const SizedBox(height: AppSpacing.sm), Text(auth.message ?? 'Registration failed.', textAlign: TextAlign.center, style: AppTypography.bodySmall.copyWith(color: AppColors.danger))],
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(height: AppSizing.buttonHeight, child: PrimaryButton(label: 'Register', isLoading: auth.status == AuthStatus.loading, onPressed: _submit)),
                    const SizedBox(height: AppSpacing.md),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[const Text('Already have an account?'), TextButton(onPressed: () => context.go(AppRoutes.login), child: const Text('Login'))]),
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
