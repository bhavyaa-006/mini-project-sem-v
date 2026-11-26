import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/router/routes.dart';
import '../../../core/router/navigation.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/auth_validators.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../data/models/user_preferences.dart';
import '../providers/profile_provider.dart';
import 'widgets/allergy_selector.dart';
import 'widgets/skin_type_selector.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  String? _nameError;
  String? _emailError;
  bool _loaded = false;
  List<String> _allergies = <String>[];
  List<String> _dietary = <String>[];
  SkinType _skin = SkinType.unknown;
  List<String> _avoid = <String>[];

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  void _load(UserProfile profile) {
    if (_loaded) return;
    _loaded = true;
    _name.text = profile.name;
    _email.text = profile.email;
    _allergies = List<String>.from(profile.allergies);
    _dietary = List<String>.from(profile.dietaryPreferences);
    _skin = profile.skinType;
    _avoid = List<String>.from(profile.ingredientPreferences);
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _nameError = AuthValidators.required(_name.text, 'Name');
      _emailError = AuthValidators.email(_email.text);
    });
    if (_nameError != null || _emailError != null) return;

    final saved = await ref
        .read(profileProvider.notifier)
        .save(
          UserProfile(
            name: _name.text.trim(),
            email: _email.text.trim(),
            allergies: _allergies,
            dietaryPreferences: _dietary,
            skinType: _skin,
            ingredientPreferences: _avoid,
          ),
        );
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved ? 'Profile saved successfully.' : 'Profile could not be saved.',
        ),
      ),
    );
    if (saved) safeGoBack(context, AppRoutes.profile);
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit profile'),
        leading: IconButton(
          onPressed: () => safeGoBack(context, AppRoutes.profile),
          icon: const Icon(Icons.close),
          tooltip: 'Close',
        ),
      ),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          _load(data);
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Personal details', style: AppTypography.title),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          label: 'Name',
                          controller: _name,
                          errorText: _nameError,
                          onChanged: (_) => setState(
                            () => _nameError = AuthValidators.required(
                              _name.text,
                              'Name',
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          label: 'Email',
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          errorText: _emailError,
                          onChanged: (_) => setState(
                            () =>
                                _emailError = AuthValidators.email(_email.text),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text('Allergies', style: AppTypography.title),
                        const SizedBox(height: AppSpacing.sm),
                        AllergySelector(
                          values: _allergies,
                          onChanged: (values) =>
                              setState(() => _allergies = values),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text('Dietary preferences', style: AppTypography.title),
                        const SizedBox(height: AppSpacing.sm),
                        _ChoiceGroup(
                          values: _dietary,
                          options: const <String>[
                            'Vegetarian',
                            'Vegan',
                            'Jain',
                            'Low sugar',
                            'Low sodium',
                            'Gluten-free',
                          ],
                          onChanged: (values) =>
                              setState(() => _dietary = values),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text('Skin type', style: AppTypography.title),
                        const SizedBox(height: AppSpacing.sm),
                        SkinTypeSelector(
                          value: _skin,
                          onChanged: (value) => setState(() => _skin = value),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Ingredients to avoid',
                          style: AppTypography.title,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _ChoiceGroup(
                          values: _avoid,
                          options: const <String>[
                            'Fragrance',
                            'Parabens',
                            'Sulphates',
                            'Palm oil',
                            'Artificial colours',
                            'Artificial sweeteners',
                          ],
                          onChanged: (values) =>
                              setState(() => _avoid = values),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        PrimaryButton(
                          label: 'Save changes',
                          icon: Icons.save_outlined,
                          onPressed: _save,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ChoiceGroup extends StatelessWidget {
  const _ChoiceGroup({
    required this.values,
    required this.options,
    required this.onChanged,
  });

  final List<String> values;
  final List<String> options;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: <Widget>[
        for (final item in options)
          FilterChip(
            label: Text(item),
            selected: values.contains(item),
            onSelected: (selected) {
              final next = List<String>.from(values);
              selected ? next.add(item) : next.remove(item);
              onChanged(next);
            },
          ),
      ],
    );
  }
}
