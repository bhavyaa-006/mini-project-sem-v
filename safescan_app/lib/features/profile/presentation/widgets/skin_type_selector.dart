import 'package:material_ui/material_ui.dart';

import '../../data/models/user_preferences.dart';

class SkinTypeSelector extends StatelessWidget {
  const SkinTypeSelector({required this.value, required this.onChanged, super.key});

  final SkinType value;
  final ValueChanged<SkinType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[for (final type in SkinType.values) ChoiceChip(label: Text(type.name[0].toUpperCase() + type.name.substring(1)), selected: value == type, onSelected: (_) => onChanged(type))],
    );
  }
}
