import '../helpers/sp_helper.dart';
import '../models/api_response_models.dart';
import '../services/api_service.dart';
import '../utils/sp_keys.dart' as sp_keys;

abstract class AuthRepository {
  Future<TokenResponseData> login({
    required String username,
    required String password,
    String? deviceToken,
  });
  Future<void> logout();
  Future<List<FactoryLocationData>> getFactories();
  Future<UserOutData> getCurrentUser();
  Future<UserOutData> uploadProfileImage(dynamic file);
}

class AuthRepositoryImpl implements AuthRepository {
  final ApiService _apiService;

  AuthRepositoryImpl({ApiService? apiService})
      : _apiService = apiService ?? ApiService.instance;

  @override
  Future<TokenResponseData> login({
    required String username,
    required String password,
    String? deviceToken,
  }) async {
    final tokenData = await _apiService.login(
      username: username,
      password: password,
      deviceToken: deviceToken,
    );

    // Persist user session to SharedPreferences
    await SpHelper.saveString(sp_keys.keyToken, tokenData.accessToken);
    await SpHelper.saveString(sp_keys.keyUserName, tokenData.name);
    await SpHelper.saveString(sp_keys.keyUserId, tokenData.userId.toString());
    await SpHelper.saveString(sp_keys.keyEmployeeCode, tokenData.employeeCode);
    await SpHelper.saveString(sp_keys.keyRoleId, tokenData.role.toString());

    if (tokenData.role == 1) {
      await SpHelper.saveString(sp_keys.keyRole, 'worker');
    } else {
      await SpHelper.saveString(sp_keys.keyRole, 'supervisor');
    }

    return tokenData;
  }

  @override
  Future<void> logout() async {
    await _apiService.clearAuth();
  }

  @override
  Future<List<FactoryLocationData>> getFactories() async {
    return await _apiService.getFactories();
  }

  @override
  Future<UserOutData> getCurrentUser() async {
    final user = await _apiService.getCurrentUser();
    if (user.name.isNotEmpty) {
      await SpHelper.saveString(sp_keys.keyUserName, user.name);
    }
    if (user.employeeCode.isNotEmpty) {
      await SpHelper.saveString(sp_keys.keyEmployeeCode, user.employeeCode);
    }
    if (user.fullProfileImageUrl != null && user.fullProfileImageUrl!.isNotEmpty) {
      await SpHelper.saveString(sp_keys.keyProfileImageUrl, user.fullProfileImageUrl!);
    }
    return user;
  }

  @override
  Future<UserOutData> uploadProfileImage(dynamic file) async {
    return await _apiService.uploadProfileImage(file);
  }
}
