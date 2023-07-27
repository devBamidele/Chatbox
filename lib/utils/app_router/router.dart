import 'package:auto_route/auto_route.dart';
import 'package:chatbox/utils/app_router/router.gr.dart';
import 'package:flutter/cupertino.dart';

@AutoRouterConfig()
class AppRouter extends $AppRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: SplashRoute.page, initial: true),
        AutoRoute(page: LoginRoute.page)
      ];
}

void navPush(BuildContext context, PageRouteInfo<dynamic>? route) {
  context.router.push(route!);
}

bool isRoot(BuildContext context) => context.router.isRoot;

void replaceAll(
  BuildContext context,
  List<PageRouteInfo<dynamic>> routes,
) {
  context.router.replaceAll(routes);
}

void navReplace(BuildContext context, PageRouteInfo<dynamic> route) {
  context.router.replace(route);
}
