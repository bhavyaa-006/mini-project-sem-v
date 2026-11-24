import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_spacing.dart';

class AllergySelector extends StatelessWidget {
  const AllergySelector({required this.values, required this.onChanged, super.key});

  final List<String> values;
  final ValueChanged<List<String>> onChanged;

  static const commonAllergens = <String>[
    'Peanuts', 'Milk', 'Egg', 'Soy', 'Wheat / Gluten', 'Sesame', 'Mustard', 'Fish', 'Shellfish', 'Tree nuts', 'No known allergies',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: <Widget>[for (final item in commonAllergens) FilterChip(label: Text(item), selected: values.contains(item), onSelected: (selected) {
        final next = List<String>.from(values);
        if (selected) {
          if (item == 'No known allergies') next.clear();
          else next.remove('No known allergies');
          if (!next.contains(item)) next.add(item);
        } else {
          next.remove(item);
        }
        onChanged(next);
      })],
    );
  }
}
