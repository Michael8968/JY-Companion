import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:rive/rive.dart';

import 'core/network/token_manager.dart';
import 'injection.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Rive (for avatar / digital character)
  await RiveNative.init();

  // Initialize Hive
  await Hive.initFlutter();

  // Configure dependency injection
  configureDependencies();

  // Initialize TokenManager (must be after DI)
  // Register manually since injectable may not be generated yet
  if (!getIt.isRegistered<TokenManager>()) {
    getIt.registerSingleton(TokenManager());
  }
  await getIt<TokenManager>().init();
}
