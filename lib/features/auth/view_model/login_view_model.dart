import 'package:shared_preferences/shared_preferences.dart';
// import '../../../models/api_response_models.dart';
import '../../../models/user_role.dart';
import '../../../providers/view_model.dart';
// import '../../../services/api_service.dart';
import '../../../utils/sp_keys.dart' as sp_keys;

class LoginViewModel extends ViewModel {
  UserRole _selectedRole = UserRole.supervisor;
  bool _obscurePassword = true;
  bool _rememberMe = true;
  String? _selectedBranch = 'Kozhikode Factory Unit';
  String? _errorMessage;

  // Getters
  UserRole get selectedRole => _selectedRole;
  bool get obscurePassword => _obscurePassword;
  bool get rememberMe => _rememberMe;
  String? get selectedBranch => _selectedBranch;
  String? get errorMessage => _errorMessage;

  final List<String> availableBranches = const [
    'Kozhikode Factory Unit',
    'Mumbai SEZ Unit',
    'Sharjah Production Facility',
    'Bangalore Jewellery Works',
  ];

  void setSelectedRole(UserRole role) {
    if (_selectedRole == role) return;
    _selectedRole = role;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  void setSelectedBranch(String? branch) {
    if (branch != null) {
      _selectedBranch = branch;
      notifyListeners();
    }
  }

  /// Live API Login with POST /api/v1/auth/login
  Future<bool> login({
    required String employeeId,
    required String password,
  }) async {
    final trimmedUser = employeeId.trim();
    final trimmedPass = password.trim();

    if (trimmedUser.isEmpty || trimmedPass.isEmpty) {
      _errorMessage = 'Please enter employee ID and password';
      notifyListeners();
      return false;
    }

    try {
      _errorMessage = null;
      showLoading();

      // UI simulation as per Figma
      await Future.delayed(const Duration(milliseconds: 500));

      // For the time being UI demo (as API not done): Always login to Supervisor
      _selectedRole = UserRole.supervisor;

      /*
      // ================= LIVE API INTEGRATION (COMMENTED OUT) =================
      final TokenResponseData tokenData = await ApiService.instance.login(
        username: trimmedUser,
        password: trimmedPass,
      );

      // Save user session into SharedPreferences
      final sp = await SharedPreferences.getInstance();
      await sp.setString(sp_keys.keyToken, tokenData.accessToken);
      await sp.setString(sp_keys.keyUserName, tokenData.name);
      await sp.setString(sp_keys.keyUserId, tokenData.userId.toString());
      await sp.setString(sp_keys.keyEmployeeCode, tokenData.employeeCode);
      await sp.setString(sp_keys.keyRoleId, tokenData.role.toString());

      if (tokenData.role == 1) {
        _selectedRole = UserRole.worker;
        await sp.setString(sp_keys.keyRole, 'worker');
      } else {
        _selectedRole = UserRole.supervisor;
        await sp.setString(sp_keys.keyRole, 'supervisor');
      }
      // ========================================================================
      */

      // Save mock session for UI consistency
      final sp = await SharedPreferences.getInstance();
      await sp.setString(sp_keys.keyUserName, 'Supervisor UM001');
      await sp.setString(sp_keys.keyUserId, trimmedUser.isNotEmpty ? trimmedUser : 'UM001');
      await sp.setString(sp_keys.keyEmployeeCode, trimmedUser.isNotEmpty ? trimmedUser : 'UM001');
      await sp.setString(sp_keys.keyRole, 'supervisor');

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      notifyListeners();
      return false;
    } finally {
      hideLoading();
    }
  }

  /// Alias for backward compatibility with existing screen references
  Future<bool> mockLogin({
    required String employeeId,
    required String password,
  }) =>
      login(employeeId: employeeId, password: password);
}
