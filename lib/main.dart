import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/preferences/app_preferences_provider.dart';
import 'core/preferences/app_preferences_state.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/supabase_service.dart';
import 'core/widgets/app_security_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase & Environment variables
  await SupabaseService.init();
  
  runApp(
    const ProviderScope(
      child: VeWalletApp(),
    ),
  );
}

class VeWalletApp extends ConsumerWidget {
  const VeWalletApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final preferences = ref.watch(appPreferencesProvider).asData?.value ??
        AppPreferencesState.defaults;

    return MaterialApp.router(
      title: 'Ve-Wallet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: preferences.themeMode,
      locale: preferences.locale,
      supportedLocales: const [
        Locale('id'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return AppSecurityGate(
          child: child ?? const SizedBox.shrink(),
        );
      },
      routerConfig: router,
    );
  }
}
