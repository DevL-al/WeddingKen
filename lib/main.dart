import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_gate.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('id_ID', null);
  runApp(const WeddingkenApp()) ;
}

class WeddingkenApp extends StatelessWidget {
  const WeddingkenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WEDDINGKEN',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AuthGate(),
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: const _WeddingkenScrollBehavior(),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

class _WeddingkenScrollBehavior extends MaterialScrollBehavior {
  const _WeddingkenScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }
}
