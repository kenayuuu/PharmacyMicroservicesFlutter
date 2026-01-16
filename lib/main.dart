import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/auth_provider.dart';
import 'screen/login_screen.dart';
import 'screen/home_screen.dart';
import 'screen/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 WAJIB SEKALI UNTUK HAPUS DATA RUSAK
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'Apotek Pharmacy',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // 🌿 WARNA UTAMA & GRADIENT KONSISTEN
          primaryColor: const Color(0xFF00695C),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00695C),
            primary: const Color(0xFF00695C),
            secondary: const Color(0xFF4DB6AC),
          ),
          scaffoldBackgroundColor: Colors.grey.shade50,

          // 🔹 AppBar Theme
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF00695C),
            foregroundColor: Colors.white,
            elevation: 2,
          ),

          // 🔹 ElevatedButton Theme
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00695C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),

          // 🔹 Input Fields Theme
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),

          // 🔹 Card Theme
          cardTheme: CardTheme(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            shadowColor: Colors.black26,
          ),

          // 🔹 Typography
          textTheme: const TextTheme(
            headlineMedium: TextStyle(
              fontWeight: FontWeight.bold,
            ),
            titleLarge: TextStyle(
              fontWeight: FontWeight.bold,
            ),
            titleMedium: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isAuthenticated) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}
