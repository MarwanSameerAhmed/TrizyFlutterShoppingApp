import 'package:trizy_app/models/deal/deals_response.dart';
import 'package:trizy_app/services/deals_api_service.dart';
import 'package:trizy_app/services/demo/demo_data_service.dart';

class DemoDealsApiService extends DealsApiService {
  final DemoDataService _demoData = DemoDataService.instance;

  @override
  Future<DealsResponse> getDeals() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return DealsResponse.fromJson(_demoData.deals);
  }
}
