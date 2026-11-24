import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

void safeGoBack(BuildContext context, String fallbackRoute) {
  final router = GoRouter.of(context);
  if (router.canPop()) {
    router.pop();
  } else {
    context.go(fallbackRoute);
  }
}
