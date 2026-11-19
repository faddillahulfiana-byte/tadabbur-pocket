import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_theme.dart';
import 'core/services/notification_service.dart';
import 'core/services/supabase_service.dart';
import 'providers/auth_provider.dart';
import 'providers/murajaah_provider.dart';
import 'providers/quote_provider.dart';
import 'providers/surah_provider.dart';
import 'views/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Layanan Notifikasi Lokal Android
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Inisialisasi Klien Supabase (membaca dari --dart-define)
  await SupabaseService.initialize();

  runApp(const TadabburPocketApp());
}

class TadabburPocketApp extends StatelessWidget {
  const TadabburPocketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SurahProvider()),
        ChangeNotifierProvider(create: (_) => MurajaahProvider()),
        ChangeNotifierProvider(create: (_) => QuoteProvider()),
      ],
      child: MaterialApp(
        title: 'Tadabbur Pocket',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('id', 'ID'),
          Locale('en', 'US'),
        ],
        home: const MainNavigationScreen(),
      ),
    );
  }
}
