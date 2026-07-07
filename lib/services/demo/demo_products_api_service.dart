import 'package:trizy_app/models/like/get_liked_products_response.dart';
import 'package:trizy_app/models/product/like_response.dart';
import 'package:trizy_app/models/product/products_response.dart';
import 'package:trizy_app/models/product/single_product_response.dart';
import 'package:trizy_app/models/trendingsearch/trending_search_response.dart';
import 'package:trizy_app/services/demo/demo_data_service.dart';
import 'package:trizy_app/services/products_api_service.dart';
import '../../models/product/product_query_params.dart';

class DemoProductsApiService extends ProductsApiService {
  final DemoDataService _demoData = DemoDataService.instance;

  // In-memory liked products for demo
  final Set<String> _likedProductIds = {};

  @override
  Future<ProductsResponse> getProductsByCategory({
    required String categoryId,
    required int page,
    ProductQueryParams? queryParameters,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final allProducts = (_demoData.products['products'] as List);

    // Filter by category
    final filtered = allProducts.where((p) {
      final cat = p['category'];
      if (cat is Map<String, dynamic>) {
        return cat['_id'] == categoryId;
      }
      return p['category'] == categoryId;
    }).toList();

    // Get subCategories for this category
    final allCategories = (_demoData.categories['categories'] as List);
    final subCategories = allCategories
        .where((cat) => cat['parentCategory'] == categoryId)
        .map((cat) => {
              '_id': cat['_id'],
              'name': cat['name'],
              'description': cat['description'],
            })
        .toList();

    // If no products for this exact category, check child categories
    List<dynamic> finalProducts = filtered;
    if (filtered.isEmpty) {
      final childCategoryIds = subCategories.map((c) => c['_id']).toSet();
      finalProducts = allProducts.where((p) {
        final cat = p['category'];
        if (cat is Map<String, dynamic>) {
          return childCategoryIds.contains(cat['_id']);
        }
        return false;
      }).toList();
    }

    return ProductsResponse.fromJson({
      'success': true,
      'products': finalProducts,
      'pagination': {
        'currentPage': page,
        'totalPages': 1,
        'totalProducts': finalProducts.length,
      },
      'subCategories': subCategories,
    });
  }

  @override
  Future<ProductsResponse> searchProducts({
    required String query,
    String? categoryId,
    required int page,
    ProductQueryParams? queryParameters,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final allProducts = (_demoData.products['products'] as List);
    final queryLower = query.toLowerCase();

    final filtered = allProducts.where((p) {
      final title = (p['title'] as String).toLowerCase();
      final description = (p['description'] as String).toLowerCase();
      final tags = (p['tags'] as List).map((t) => t.toString().toLowerCase());
      final matchesQuery = title.contains(queryLower) ||
          description.contains(queryLower) ||
          tags.any((tag) => tag.contains(queryLower));

      if (categoryId != null) {
        final cat = p['category'];
        final catId = cat is Map<String, dynamic> ? cat['_id'] : cat;
        return matchesQuery && catId == categoryId;
      }
      return matchesQuery;
    }).toList();

    return ProductsResponse.fromJson({
      'success': true,
      'products': filtered,
      'pagination': {
        'currentPage': page,
        'totalPages': 1,
        'totalProducts': filtered.length,
      },
    });
  }

  @override
  Future<SingleProductResponse> getSingleProduct({required String productId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final allProducts = (_demoData.products['products'] as List);
    final product = allProducts.firstWhere(
      (p) => p['_id'] == productId,
      orElse: () => allProducts.first,
    );

    return SingleProductResponse.fromJson({
      'success': true,
      'product': product,
    });
  }

  @override
  Future<ProductsResponse> getLikedProducts({required int page}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final allProducts = (_demoData.products['products'] as List);

    final liked = allProducts
        .where((p) => _likedProductIds.contains(p['_id']))
        .toList();

    return ProductsResponse.fromJson({
      'success': true,
      'products': liked,
      'pagination': {
        'currentPage': page,
        'totalPages': 1,
        'totalProducts': liked.length,
      },
    });
  }

  @override
  Future<ProductsResponse> getBestOfProducts({required String period}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final allProducts = (_demoData.products['products'] as List);

    // Sort by averageRating descending
    final sorted = List<dynamic>.from(allProducts)
      ..sort((a, b) => (b['averageRating'] as num).compareTo(a['averageRating'] as num));

    final bestOf = sorted.take(6).toList();

    return ProductsResponse.fromJson({
      'success': true,
      'products': bestOf,
      'pagination': {
        'currentPage': 1,
        'totalPages': 1,
        'totalProducts': bestOf.length,
      },
    });
  }

  @override
  Future<LikeResponse> likeProduct({required String productId}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _likedProductIds.add(productId);
    return LikeResponse.fromJson({
      'success': true,
      'message': 'Product liked successfully',
    });
  }

  @override
  Future<LikeResponse> removeLike({required String productId}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _likedProductIds.remove(productId);
    return LikeResponse.fromJson({
      'success': true,
      'message': 'Product unliked successfully',
    });
  }

  @override
  Future<GetLikedProductsResponse> getLikedProductIds() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return GetLikedProductsResponse.fromJson({
      'success': true,
      'likedProductIds': _likedProductIds.toList(),
    });
  }

  @override
  Future<TrendingSearchResponse> getTrendingSearches() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return TrendingSearchResponse.fromJson(_demoData.trendingSearches);
  }
}
