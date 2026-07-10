import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'screens/login_screen.dart';
import 'screens/katalog_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'POS Aksesoris Elektronik',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          foregroundColor: Colors.white, 
        )
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/katalog': (context) => const KatalogBarangScreen(),
      },
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return FutureBuilder(
            future: authProvider.checkLoginStatus(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              } else {
                if (authProvider.isLoggedIn) {
                  return const KatalogBarangScreen();
                } else {
                  return const LoginScreen();
                }
              }
            },
          );
        },
      ),
    );
  }
}