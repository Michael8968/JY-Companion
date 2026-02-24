import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'injection.dart';

class JYCompanionApp extends StatelessWidget {
  const JYCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    final routerConfig = getIt<AppRouterConfig>();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<AuthBloc>()..add(const AuthEvent.appStarted()),
        ),
      ],
      child: MaterialApp.router(
        title: '星澜学伴',
        theme: AppTheme.light,
        routerConfig: routerConfig.router,
        debugShowCheckedModeBanner: false,
        locale: const Locale('zh', 'CN'),
        supportedLocales: const [
          Locale('zh', 'CN'),
          Locale('en', 'US'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
  }
}
