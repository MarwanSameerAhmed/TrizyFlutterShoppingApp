import 'dart:convert';
import 'package:flutter/services.dart';

/// Central service that loads demo data from the JSON asset file.
/// All demo API services read from this shared data source.
class DemoDataService {
  static DemoDataService? _instance;
  Map<String, dynamic>? _data;

  DemoDataService._();

  static DemoDataService get instance {
    _instance ??= DemoDataService._();
    return _instance!;
  }

  Future<void> load() async {
    if (_data != null) return;
    final jsonString = await rootBundle.loadString('assets/demo_data.json');
    _data = json.decode(jsonString);
  }

  Map<String, dynamic> get data {
    if (_data == null) {
      throw Exception('Demo data not loaded. Call load() first.');
    }
    return _data!;
  }

  Map<String, dynamic> get products => data['products'];
  Map<String, dynamic> get categories => data['categories'];
  Map<String, dynamic> get deals => data['deals'];
  Map<String, dynamic> get reviews => data['reviews'];
  Map<String, dynamic> get cart => data['cart'];
  Map<String, dynamic> get orders => data['orders'];
  Map<String, dynamic> get trendingSearches => data['trending_searches'];
  Map<String, dynamic> get user => data['user'];
}
