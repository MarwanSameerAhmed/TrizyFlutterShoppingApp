import 'package:trizy_app/models/review/create_review_request.dart';
import 'package:trizy_app/models/review/get_reviewable_products_response.dart';
import 'package:trizy_app/models/review/get_reviews_response.dart';
import 'package:trizy_app/models/review/review_operation_response.dart';
import 'package:trizy_app/services/demo/demo_data_service.dart';
import 'package:trizy_app/services/review_api_service.dart';
import 'package:uuid/uuid.dart';

class DemoReviewApiService extends ReviewApiService {
  final DemoDataService _demoData = DemoDataService.instance;
  final _uuid = const Uuid();

  @override
  Future<ReviewOperationResponse> createReview({required CreateReviewRequest request}) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final reviews = _demoData.reviews['reviews'] as List;
    reviews.add({
      '_id': 'rev_${_uuid.v4().substring(0, 8)}',
      'productId': request.productId,
      'userId': {
        '_id': 'user_001',
        'userFirstName': 'Ahmad',
        'userLastName': 'Demo',
      },
      'orderId': request.orderId,
      'rating': request.rating,
      'comment': request.comment,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });

    return ReviewOperationResponse.fromJson({
      'success': true,
      'message': 'Review created successfully',
    });
  }

  @override
  Future<ReviewOperationResponse> deleteReview({required String reviewId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final reviews = _demoData.reviews['reviews'] as List;
    reviews.removeWhere((r) => r['_id'] == reviewId);

    return ReviewOperationResponse.fromJson({
      'success': true,
      'message': 'Review deleted successfully',
    });
  }

  @override
  Future<GetReviewsResponse> getProductReviews({required String productId, required int page}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final allReviews = (_demoData.reviews['reviews'] as List);
    final productReviews = allReviews
        .where((r) => r['productId'] == productId)
        .toList();

    double avgRating = 0.0;
    if (productReviews.isNotEmpty) {
      final totalRating = productReviews.fold<double>(
        0.0,
        (sum, r) => sum + (r['rating'] as num).toDouble(),
      );
      avgRating = totalRating / productReviews.length;
    }

    return GetReviewsResponse.fromJson({
      'success': true,
      'reviews': productReviews,
      'pagination': {
        'currentPage': page,
        'totalPages': 1,
      },
      'averageRating': avgRating,
      'totalReviews': productReviews.length,
    });
  }

  @override
  Future<GetReviewableProductsResponse> getReviewableProducts({required String orderId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final allOrders = (_demoData.orders['orders'] as List);
    final order = allOrders.cast<Map<String, dynamic>>().firstWhere(
      (o) => o['_id'] == orderId,
      orElse: () => <String, dynamic>{},
    );

    List<Map<String, dynamic>> reviewableProducts = [];
    if (order.isNotEmpty) {
      final items = order['items'] as List;
      for (var item in items) {
        final productId = item['productId'];
        if (productId is Map) {
          reviewableProducts.add({
            '_id': productId['_id'],
            'imageURLs': productId['imageURLs'],
            'title': productId['title'],
          });
        } else {
          final allProducts = (_demoData.products['products'] as List);
          final product = allProducts.cast<Map<String, dynamic>>().firstWhere(
            (p) => p['_id'] == productId,
            orElse: () => <String, dynamic>{},
          );
          if (product.isNotEmpty) {
            reviewableProducts.add({
              '_id': product['_id'],
              'imageURLs': product['imageURLs'],
              'title': product['title'],
            });
          }
        }
      }
    }

    return GetReviewableProductsResponse.fromJson({
      'success': true,
      'reviewableProducts': reviewableProducts,
    });
  }
}
