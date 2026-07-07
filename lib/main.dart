import 'dart:convert';
import 'dart:io';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trizy_app/di/locator.dart';
import 'package:trizy_app/repositories/cart_repository.dart';
import 'package:trizy_app/repositories/products_repository.dart';
import 'package:trizy_app/routing/app_router.dart';
import 'package:trizy_app/services/demo/demo_data_service.dart';
import 'package:trizy_app/theme/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trizy_app/utils/auth_check.dart';
//import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {

    /*
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
     */

    await dotenv.load();

    // Load demo data before setting up the locator
    if (useDemoData) {
      await DemoDataService.instance.load();
    }

    setupLocator();

    if (Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      );
    }

    if (useDemoData) {
      // In demo mode, auto-authenticate and skip Stripe
      await _setupDemoUser();
    } else {
      setupStripeKey();
      await Stripe.instance.applySettings();
    }

    await initializeApp();

    runApp(const MyApp());
  } catch (e) {
    print("Initialization error: $e");
  }
}

/// Sets up a fake authenticated user for demo mode
Future<void> _setupDemoUser() async {
  final prefs = await SharedPreferences.getInstance();
  // Set a demo access token so the app thinks the user is authenticated
  await prefs.setString('accessToken', 'demo_access_token');
  await prefs.setString('refreshToken', 'demo_refresh_token');
  // Set demo user info
  await prefs.setString('user', jsonEncode({
    'id': 'user_001',
    'email': 'demo@trizy.app',
    'firstName': 'Ahmad',
    'lastName': 'Demo',
    'isSubscriber': true,
  }));
}

Future<void> initializeApp() async {
  final isUserAuthenticated = await isAuthenticated();

  if (isUserAuthenticated) {
    final cartRepository = getIt<CartRepository>();
    final productsRepository = getIt<ProductsRepository>();

    try {
      await Future.wait([
        cartRepository.getCartItemsAndSaveToLocal(),
        productsRepository.getLikedProductIdsAndSaveToLocal(),
      ]);
    } catch (e) {
      print("Error during app initialization: $e");
    }
  }
}

void setupStripeKey() {
  final publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'];

  if (publishableKey == null || publishableKey.isEmpty) {
    throw Exception("Stripe Publishable Key is not found in the .env file.");
  }
  Stripe.publishableKey = publishableKey;
  Stripe.merchantIdentifier = 'trizy-merchant';
  Stripe.urlScheme = 'trizy';
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AppRouter appRouter = AppRouter();

    return MaterialApp.router(
      title: 'Trizy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primaryLightColor),
        useMaterial3: true,
      ),
      routerDelegate: appRouter.router.routerDelegate,
      routeInformationParser: appRouter.router.routeInformationParser,
      routeInformationProvider: appRouter.router.routeInformationProvider,
    );
  }
}