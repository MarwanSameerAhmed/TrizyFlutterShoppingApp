import 'package:trizy_app/models/cart/request/add_item_to_cart_request.dart';
import 'package:trizy_app/models/cart/response/add_item_to_cart_on_feed_response.dart';
import 'package:trizy_app/models/cart/response/cart_operation_response.dart';
import 'package:trizy_app/models/cart/response/get_cart_items_response.dart';
import 'package:trizy_app/models/cart/response/get_cart_response.dart';
import 'package:trizy_app/services/cart_api_service.dart';
import 'package:trizy_app/services/demo/demo_data_service.dart';

class DemoCartApiService extends CartApiService {
  final DemoDataService _demoData = DemoDataService.instance;

  // In-memory cart state for demo
  late List<Map<String, dynamic>> _cartItems;
  bool _initialized = false;

  void _initCart() {
    if (!_initialized) {
      _cartItems = List<Map<String, dynamic>>.from(
        (_demoData.cart['items'] as List).map((item) => Map<String, dynamic>.from(item)),
      );
      _initialized = true;
    }
  }

  Map<String, dynamic> _buildCartJson() {
    _initCart();
    double totalWeight = 0;
    for (var item in _cartItems) {
      totalWeight += (item['cargoWeight'] as num) * (item['quantity'] as num);
    }
    double cargoFee = totalWeight > 5 ? 12.99 : (totalWeight > 0 ? 5.99 : 0);

    return {
      'ownerId': 'user_001',
      'items': _cartItems,
      'updatedAt': DateTime.now().toIso8601String(),
      'cargoFee': cargoFee,
    };
  }

  @override
  Future<GetCartResponse> getUserCart() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _initCart();
    return GetCartResponse.fromJson({
      'success': true,
      'cart': _buildCartJson(),
      'cargoFeeThreshold': 200.0,
    });
  }

  @override
  Future<CartOperationResponse> addItemToCart({required AddItemToCartRequest request}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _initCart();

    final existingIndex = _cartItems.indexWhere((item) => item['productId'] == request.productId);
    if (existingIndex != -1) {
      _cartItems[existingIndex]['quantity'] = (_cartItems[existingIndex]['quantity'] as int) + request.quantity;
    } else {
      final allProducts = (_demoData.products['products'] as List);
      final product = allProducts.firstWhere(
        (p) => p['_id'] == request.productId,
        orElse: () => null,
      );

      if (product != null) {
        _cartItems.add({
          'productId': request.productId,
          'title': product['title'],
          'imageURL': (product['imageURLs'] as List).first,
          'cargoWeight': product['cargoWeight'],
          'stockCount': product['stockCount'],
          'price': product['salePrice'] ?? product['price'],
          'quantity': request.quantity,
        });
      }
    }

    return CartOperationResponse.fromJson({
      'success': true,
      'message': 'Item added to cart',
      'cart': _buildCartJson(),
      'cargoFeeThreshold': 200.0,
    });
  }

  @override
  Future<CartOperationResponse> deleteItemFromCart({required String productId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _initCart();
    _cartItems.removeWhere((item) => item['productId'] == productId);

    return CartOperationResponse.fromJson({
      'success': true,
      'message': 'Item removed from cart',
      'cart': _buildCartJson(),
      'cargoFeeThreshold': 200.0,
    });
  }

  @override
  Future<CartOperationResponse> decrementItemQuantity({required String productId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _initCart();

    final index = _cartItems.indexWhere((item) => item['productId'] == productId);
    if (index != -1) {
      final currentQty = _cartItems[index]['quantity'] as int;
      if (currentQty > 1) {
        _cartItems[index]['quantity'] = currentQty - 1;
      } else {
        _cartItems.removeAt(index);
      }
    }

    return CartOperationResponse.fromJson({
      'success': true,
      'message': 'Item quantity decremented',
      'cart': _buildCartJson(),
      'cargoFeeThreshold': 200.0,
    });
  }

  @override
  Future<AddItemToCartOnFeedResponse> addItemOnFeed({required String productId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _initCart();

    final existingIndex = _cartItems.indexWhere((item) => item['productId'] == productId);
    if (existingIndex != -1) {
      _cartItems[existingIndex]['quantity'] = (_cartItems[existingIndex]['quantity'] as int) + 1;
    } else {
      final allProducts = (_demoData.products['products'] as List);
      final product = allProducts.firstWhere(
        (p) => p['_id'] == productId,
        orElse: () => null,
      );

      if (product != null) {
        _cartItems.add({
          'productId': productId,
          'title': product['title'],
          'imageURL': (product['imageURLs'] as List).first,
          'cargoWeight': product['cargoWeight'],
          'stockCount': product['stockCount'],
          'price': product['salePrice'] ?? product['price'],
          'quantity': 1,
        });
      }
    }

    return AddItemToCartOnFeedResponse.fromJson({
      'success': true,
      'message': 'Item added to cart from feed',
    });
  }

  @override
  Future<GetCartItemsResponse> getCartItemIds() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _initCart();
    final productIds = _cartItems.map((item) => item['productId'] as String).toList();

    return GetCartItemsResponse.fromJson({
      'success': true,
      'productIds': productIds,
    });
  }
}
