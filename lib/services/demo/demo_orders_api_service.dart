import 'package:trizy_app/models/order/check_order_status_response.dart';
import 'package:trizy_app/models/order/get_user_orders_response.dart';
import 'package:trizy_app/models/order/order_details_response.dart';
import 'package:trizy_app/services/demo/demo_data_service.dart';
import 'package:trizy_app/services/orders_api_service.dart';

class DemoOrdersApiService extends OrdersApiService {
  final DemoDataService _demoData = DemoDataService.instance;

  /// Converts an order from the demo JSON into the OrderDetails format
  Map<String, dynamic> _toOrderDetailsJson(Map<String, dynamic> order) {
    final items = (order['items'] as List).map((item) {
      final productId = item['productId'];
      final pId = productId is Map ? productId['_id'] : productId;
      final pTitle = productId is Map ? productId['title'] : 'Product';
      final pImage = productId is Map
          ? (productId['imageURLs'] as List).first
          : 'https://via.placeholder.com/150';

      return {
        'productId': pId,
        'productTitle': pTitle,
        'productImage': pImage,
        'quantity': item['quantity'],
        'price': item['price'],
      };
    }).toList();

    final addr = order['deliveryAddress'];
    return {
      'orderId': order['_id'],
      'amount': order['amount'],
      'currency': order['currency'],
      'status': order['status'],
      'createdAt': order['createdAt'],
      'deliveryAddress': {
        '_id': addr['_id'],
        'fullName': 'Ahmad Demo',
        'phoneNumber': '+966501234567',
        'address': addr['address'],
        'city': addr['city'],
        'state': addr['state'],
        'postalCode': '12345',
        'country': addr['country'],
      },
      'items': items,
    };
  }

  /// Converts an order for CheckOrderStatusResponse
  Map<String, dynamic> _toCheckOrderJson(Map<String, dynamic> order) {
    final items = (order['items'] as List).map((item) {
      final productId = item['productId'];
      final pId = productId is Map ? productId['_id'] : productId;
      return {
        '_id': item['_id'],
        'productId': pId,
        'quantity': item['quantity'],
        'price': item['price'],
      };
    }).toList();

    return {
      '_id': order['_id'],
      'userId': order['userId'],
      'deliveryAddress': order['deliveryAddress']['_id'],
      'paymentIntentId': order['paymentIntentId'],
      'amount': order['amount'],
      'currency': order['currency'],
      'status': order['status'],
      'items': items,
      'createdAt': order['createdAt'],
    };
  }

  @override
  Future<CheckOrderStatusResponse> checkOrderStatus({required String paymentIntentId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final allOrders = (_demoData.orders['orders'] as List);
    final order = allOrders.cast<Map<String, dynamic>>().firstWhere(
      (o) => o['paymentIntentId'] == paymentIntentId,
      orElse: () => <String, dynamic>{},
    );

    if (order.isEmpty) {
      return CheckOrderStatusResponse.fromJson({
        'success': true,
        'message': 'Order not found',
        'order': null,
      });
    }

    return CheckOrderStatusResponse.fromJson({
      'success': true,
      'message': 'Order found',
      'order': _toCheckOrderJson(order),
    });
  }

  @override
  Future<GetUserOrdersResponse> getUserOrders({required int page}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final allOrders = (_demoData.orders['orders'] as List);

    return GetUserOrdersResponse.fromJson({
      'success': true,
      'orders': allOrders,
      'currentPage': page,
      'totalPages': 1,
    });
  }

  @override
  Future<OrderDetailsResponse> getOrderDetails({required String orderId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final allOrders = (_demoData.orders['orders'] as List);
    final order = allOrders.cast<Map<String, dynamic>>().firstWhere(
      (o) => o['_id'] == orderId,
      orElse: () => Map<String, dynamic>.from(allOrders.first),
    );

    return OrderDetailsResponse.fromJson({
      'success': true,
      'order': _toOrderDetailsJson(order),
    });
  }

  @override
  Future<OrderDetailsResponse> getLatestOrderDetails() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final allOrders = (_demoData.orders['orders'] as List);
    final order = Map<String, dynamic>.from(allOrders.last);

    return OrderDetailsResponse.fromJson({
      'success': true,
      'order': _toOrderDetailsJson(order),
    });
  }
}
