import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'routes.dart';

void safeGoBack(BuildContext context, String fallbackRoute) {
  final router = GoRouter.of(context);
  if (router.canPop()) {
    router.pop();
  } else {
    context.go(fallbackRoute);
  }
}

void popToHome(BuildContext context) {
  final router = GoRouter.of(context);
  while (router.canPop()) {
    router.pop();
  }
  if (router.routeInformationProvider.value.uri.path != AppRoutes.home) {
    context.go(AppRoutes.home);
  }
}
