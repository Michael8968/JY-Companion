import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import '../../features/academic/presentation/pages/academic_page.dart';
import '../../features/admin/presentation/pages/admin_page.dart';
import '../../features/academic/presentation/pages/error_book_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/classroom/presentation/pages/classroom_page.dart';
import '../../features/classroom/presentation/pages/session_detail_page.dart';
import '../../features/emotional/presentation/pages/emotional_page.dart';
import '../../features/career/presentation/pages/career_page.dart';
import '../../features/creative/presentation/pages/creative_page.dart';
import '../../features/health/presentation/pages/health_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/chat/presentation/pages/conversation_list_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/persona/presentation/pages/persona_list_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../network/token_manager.dart';
import 'route_names.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

@singleton
class AppRouterConfig {
  final TokenManager _tokenManager;

  AppRouterConfig(this._tokenManager);

  late final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: _guard,
    routes: [
      GoRoute(
        path: '/splash',
        name: RouteNames.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        name: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: RouteNames.register,
        builder: (context, state) => const RegisterPage(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => HomePage(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: RouteNames.home,
            builder: (context, state) => const HomeContent(),
            routes: [
              GoRoute(
                path: 'conversations',
                name: RouteNames.conversations,
                builder: (context, state) => const ConversationListPage(),
              ),
              GoRoute(
                path: 'personas',
                name: RouteNames.personas,
                builder: (context, state) => const PersonaListPage(),
              ),
              GoRoute(
                path: 'profile',
                name: RouteNames.profile,
                builder: (context, state) => const ProfilePage(),
              ),
              GoRoute(
                path: 'academic',
                name: RouteNames.academic,
                builder: (context, state) => const AcademicPage(),
                routes: [
                  GoRoute(
                    path: 'error-book',
                    name: RouteNames.errorBook,
                    builder: (context, state) => const ErrorBookPage(),
                  ),
                ],
              ),
              GoRoute(
                path: 'classroom',
                name: RouteNames.classroom,
                builder: (context, state) => const ClassroomPage(),
                routes: [
                  GoRoute(
                    path: 'session/:sessionId',
                    name: RouteNames.sessionDetail,
                    builder: (context, state) {
                      final sessionId =
                          state.pathParameters['sessionId']!;
                      return SessionDetailPage(sessionId: sessionId);
                    },
                  ),
                ],
              ),
              GoRoute(
                path: 'emotional',
                name: RouteNames.emotional,
                builder: (context, state) => const EmotionalPage(),
              ),
              GoRoute(
                path: 'health',
                name: RouteNames.health,
                builder: (context, state) => const HealthPage(),
              ),
              GoRoute(
                path: 'creative',
                name: RouteNames.creative,
                builder: (context, state) => const CreativePage(),
              ),
              GoRoute(
                path: 'career',
                name: RouteNames.career,
                builder: (context, state) => const CareerPage(),
              ),
              GoRoute(
                path: 'admin',
                name: RouteNames.admin,
                builder: (context, state) => const AdminPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/chat/:conversationId',
        name: RouteNames.chat,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final conversationId = state.pathParameters['conversationId']!;
          return ChatPage(conversationId: conversationId);
        },
      ),
    ],
  );

  String? _guard(BuildContext context, GoRouterState state) {
    final isAuthenticated = _tokenManager.hasTokens;
    final isAuthRoute = state.matchedLocation == '/login' ||
        state.matchedLocation == '/register' ||
        state.matchedLocation == '/splash';

    if (!isAuthenticated && !isAuthRoute) {
      return '/login';
    }

    if (isAuthenticated && (state.matchedLocation == '/login' ||
        state.matchedLocation == '/register')) {
      return '/home';
    }

    return null;
  }
}
