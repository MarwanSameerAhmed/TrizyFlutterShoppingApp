import 'package:trizy_app/models/user/user_profile_response.dart';
import 'package:trizy_app/services/demo/demo_data_service.dart';
import 'package:trizy_app/services/user_profile_api_service.dart';

class DemoUserProfileApiService extends UserProfileApiService {
  final DemoDataService _demoData = DemoDataService.instance;

  @override
  Future<UserProfileResponse> getUserProfile() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final user = _demoData.user;

    return UserProfileResponse.fromJson({
      'success': true,
      'data': {
        'userFirstName': user['userFirstName'],
        'userLastName': user['userLastName'],
        'email': user['email'],
        'hasActiveSubscription': user['isSubscriber'],
      },
    });
  }
}
