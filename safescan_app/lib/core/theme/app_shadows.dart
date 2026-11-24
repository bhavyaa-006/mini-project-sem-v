import 'package:material_ui/material_ui.dart';

abstract final class AppShadows {
  static const List<BoxShadow> none = <BoxShadow>[];

  static const List<BoxShadow> subtle = <BoxShadow>[
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> card = <BoxShadow>[
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 18,
      offset: Offset(0, 6),
    ),
  ];
}
