import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:trizy_app/repositories/address_repository.dart';
import 'package:trizy_app/repositories/ai_suggestions_repository.dart';
import 'package:trizy_app/repositories/cart_repository.dart';
import 'package:trizy_app/repositories/categories_repository.dart';
import 'package:trizy_app/repositories/deals_repository.dart';
import 'package:trizy_app/repositories/orders_repository.dart';
import 'package:trizy_app/repositories/payment_repository.dart';
import 'package:trizy_app/repositories/products_repository.dart';
import 'package:trizy_app/repositories/review_repository.dart';
import 'package:trizy_app/repositories/subscription_repository.dart';
import 'package:trizy_app/repositories/trial_product_repository.dart';
import 'package:trizy_app/repositories/trial_repository.dart';
import 'package:trizy_app/repositories/user_profile_repository.dart';
import 'package:trizy_app/services/address_api_service.dart';
import 'package:trizy_app/services/ai_suggestion_api_service.dart';
import 'package:trizy_app/services/cart_api_service.dart';
import 'package:trizy_app/services/categories_api_service.dart';
import 'package:trizy_app/services/deals_api_service.dart';
import 'package:trizy_app/services/demo/demo_cart_api_service.dart';
import 'package:trizy_app/services/demo/demo_categories_api_service.dart';
import 'package:trizy_app/services/demo/demo_deals_api_service.dart';
import 'package:trizy_app/services/demo/demo_orders_api_service.dart';
import 'package:trizy_app/services/demo/demo_products_api_service.dart';
import 'package:trizy_app/services/demo/demo_review_api_service.dart';
import 'package:trizy_app/services/demo/demo_user_profile_api_service.dart';
import 'package:trizy_app/services/orders_api_service.dart';
import 'package:trizy_app/services/payment_api_service.dart';
import 'package:trizy_app/services/products_api_service.dart';
import 'package:trizy_app/services/review_api_service.dart';
import 'package:trizy_app/services/subscription_api_service.dart';
import 'package:trizy_app/services/trial_api_service.dart';
import 'package:trizy_app/services/trial_product_api_service.dart';
import 'package:trizy_app/services/user_profile_api_service.dart';
import '../data/db/app_database.dart';
import '../repositories/auth_repository.dart';
import '../repositories/local/local_product_repository.dart';
//import '../services/analytics_service.dart';
import '../services/auth_api_service.dart';
import '../services/local/local_product_service.dart';
import '../utils/api_endpoints.dart';
import '../utils/networking_manager.dart';

final getIt = GetIt.instance;

/// Set this to true to use demo data from JSON instead of real API calls.
/// When you have a real backend, set this to false.
const bool useDemoData = true;

void setupLocator() {

  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());
  getIt.registerLazySingleton<LocalProductRepository>(() => LocalProductRepository(getIt<AppDatabase>()));
  getIt.registerLazySingleton<LocalProductService>(() => LocalProductService(getIt<LocalProductRepository>()));


  getIt.registerLazySingleton<NetworkingManager>(() => NetworkingManager(
    baseUrl: kIsWeb
        ? ApiEndpoints.baseDevWebUrl
        : (Platform.isAndroid ? ApiEndpoints.baseDevAndroidUrl : ApiEndpoints.baseDeviOSUrl),
  ));

  // Auth (always uses real service since demo mode auto-authenticates)
  getIt.registerLazySingleton<AuthApiService>(() => AuthApiService());
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepository(getIt<AuthApiService>()));

  if (useDemoData) {
    // === DEMO MODE: Use demo services that read from JSON ===
    getIt.registerLazySingleton<DealsApiService>(() => DemoDealsApiService());
    getIt.registerLazySingleton<CategoriesApiService>(() => DemoCategoriesApiService());
    getIt.registerLazySingleton<ProductsApiService>(() => DemoProductsApiService());
    getIt.registerLazySingleton<CartApiService>(() => DemoCartApiService());
    getIt.registerLazySingleton<OrdersApiService>(() => DemoOrdersApiService());
    getIt.registerLazySingleton<ReviewApiService>(() => DemoReviewApiService());
    getIt.registerLazySingleton<UserProfileApiService>(() => DemoUserProfileApiService());
  } else {
    // === PRODUCTION MODE: Use real API services ===
    getIt.registerLazySingleton<DealsApiService>(() => DealsApiService());
    getIt.registerLazySingleton<CategoriesApiService>(() => CategoriesApiService());
    getIt.registerLazySingleton<ProductsApiService>(() => ProductsApiService());
    getIt.registerLazySingleton<CartApiService>(() => CartApiService());
    getIt.registerLazySingleton<OrdersApiService>(() => OrdersApiService());
    getIt.registerLazySingleton<ReviewApiService>(() => ReviewApiService());
    getIt.registerLazySingleton<UserProfileApiService>(() => UserProfileApiService());
  }

  // Repositories (same for both modes - they use the registered API services above)
  getIt.registerLazySingleton<DealsRepository>(() => DealsRepository(getIt<DealsApiService>()));
  getIt.registerLazySingleton<CategoriesRepository>(() => CategoriesRepository(getIt<CategoriesApiService>()));
  getIt.registerLazySingleton<ProductsRepository>(() => ProductsRepository(getIt<ProductsApiService>()));
  getIt.registerLazySingleton<CartRepository>(() => CartRepository(getIt<CartApiService>()));
  getIt.registerLazySingleton<OrdersRepository>(() => OrdersRepository(getIt<OrdersApiService>()));
  getIt.registerLazySingleton<ReviewRepository>(() => ReviewRepository(getIt<ReviewApiService>()));
  getIt.registerLazySingleton<UserProfileRepository>(() => UserProfileRepository(getIt<UserProfileApiService>()));

  // Services that don't have demo equivalents (will fail gracefully in demo mode)
  getIt.registerLazySingleton<AddressApiService>(() => AddressApiService());
  getIt.registerLazySingleton<AddressRepository>(() => AddressRepository(getIt<AddressApiService>()));
  getIt.registerLazySingleton<PaymentApiService>(() => PaymentApiService());
  getIt.registerLazySingleton<PaymentRepository>(() => PaymentRepository(getIt<PaymentApiService>()));
  getIt.registerLazySingleton<SubscriptionApiService>(() => SubscriptionApiService());
  getIt.registerLazySingleton<SubscriptionRepository>(() => SubscriptionRepository(getIt<SubscriptionApiService>()));
  getIt.registerLazySingleton<TrialProductApiService>(() => TrialProductApiService());
  getIt.registerLazySingleton<TrialProductsRepository>(() => TrialProductsRepository(getIt<TrialProductApiService>()));
  getIt.registerLazySingleton<TrialApiService>(() => TrialApiService());
  getIt.registerLazySingleton<TrialRepository>(() => TrialRepository(getIt<TrialApiService>()));
  getIt.registerLazySingleton<AiSuggestionApiService>(() => AiSuggestionApiService());
  getIt.registerLazySingleton<AiSuggestionsRepository>(() => AiSuggestionsRepository(getIt<AiSuggestionApiService>()));
  //getIt.registerLazySingleton<AnalyticsService>(() => AnalyticsService());

}