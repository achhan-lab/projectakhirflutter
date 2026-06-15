import 'package:flutter/material.dart';
import 'services/seed_service.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/splash/get_started_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/products/add_product_screen.dart';
import 'screens/products/product_detail_screen.dart';
import 'models/product_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Seed dummy data on first launch
  await SeedService().seed();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SAMBA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF27AE60)),
        useMaterial3: true,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/product-detail') {
          final args = settings.arguments;
          if (args is ProductModel) {
            return MaterialPageRoute(
              builder: (_) => ProductDetailScreen(product: args),
            );
          }
        }
        return null;
      },
      routes: {
        '/': (_) => const SplashScreen(),
        '/get-started': (_) => const GetStartedScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const HomeScreen(),
        '/add-product': (_) => const AddProductScreen(),
      },
    );
  }
}
