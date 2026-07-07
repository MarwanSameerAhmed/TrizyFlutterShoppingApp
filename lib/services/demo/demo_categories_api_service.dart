import 'package:trizy_app/models/category/categories_response.dart';
import 'package:trizy_app/services/categories_api_service.dart';
import 'package:trizy_app/services/demo/demo_data_service.dart';

class DemoCategoriesApiService extends CategoriesApiService {
  final DemoDataService _demoData = DemoDataService.instance;

  @override
  Future<CategoriesResponse> getRootCategories() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final allCategories = _demoData.categories;

    final rootCategories = (allCategories['categories'] as List)
        .where((cat) => cat['parentCategory'] == null)
        .toList();

    return CategoriesResponse.fromJson({
      'success': true,
      'categories': rootCategories,
    });
  }

  @override
  Future<CategoriesResponse> getChildCategories(String rootCategoryId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final allCategories = _demoData.categories;

    final childCategories = (allCategories['categories'] as List)
        .where((cat) => cat['parentCategory'] == rootCategoryId)
        .toList();

    return CategoriesResponse.fromJson({
      'success': true,
      'categories': childCategories,
    });
  }
}
