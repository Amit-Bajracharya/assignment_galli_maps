import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/route_constants.dart';
import '../../features/entry/presentation/screen/main_screen.dart';
import '../../features/entry/presentation/screen/map_screen.dart';
import '../../features/entry/presentation/screen/saved_entries_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: RouteConstants.map,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScreen(navigationShell: navigationShell);
      },
      branches: [
        // BRANCH 0: MAP
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteConstants.map,
              name: RouteConstants.mapName,
              builder: (context, state) => const MapScreen(),
            ),
          ],
        ),
       
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteConstants.bookmarks,
              name: RouteConstants.bookmarksName,
              builder: (context, state) => const SavedEntriesScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
