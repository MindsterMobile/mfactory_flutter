import 'package:flutter/foundation.dart';

import '../../../models/api_response_models.dart';
import '../../../models/user_role.dart';
import '../../../providers/view_model.dart';
import '../../../repositories/auth_repository.dart';
import '../../../services/api_service.dart';
import '../../../utils/app_build_methods.dart';
import '../../../utils/extensions.dart';

class LoginViewModel extends ViewModel {
  final AuthRepository _authRepository;

  UserRole _selectedRole = UserRole.supervisor;
  bool _obscurePassword = true;
  String? _errorMessage;
  List<FactoryLocationData> _factories = [];

  LoginViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepositoryImpl();

  // Getters
  UserRole get selectedRole => _selectedRole;
  bool get obscurePassword => _obscurePassword;
  String? get errorMessage => _errorMessage;
  List<FactoryLocationData> get factories => _factories;
  bool get hasFactories => _factories.isNotEmpty;

  void setSelectedRole(UserRole role) {
    if (_selectedRole == role) return;
    _selectedRole = role;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  /// Live API Login with AuthRepository
  Future<bool> login({
    required String employeeId,
    required String password,
  }) async {
    final trimmedUser = employeeId.trim();
    final trimmedPass = password.trim();

    if (trimmedUser.isEmpty || trimmedPass.isEmpty) {
      showToast('Please enter employee ID and password');
      _errorMessage = 'Please enter employee ID and password';
      notifyListeners();
      return false;
    }

    try {
      _errorMessage = null;

      final TokenResponseData tokenData = await _authRepository
          .login(
            username: trimmedUser,
            password: trimmedPass,
          )
          .setProgress(this);

      if (tokenData.role == 1) {
        _selectedRole = UserRole.worker;
      } else {
        _selectedRole = UserRole.supervisor;
      }

      // Check if factory locations exist for tenant
      try {
        _factories = await _authRepository.getFactories().setProgress(this);
      } catch (e) {
        debugPrint('Error fetching factories during login: $e');
        _factories = [];
      }

      notifyListeners();
      return true;
    } catch (e) {
      final msg = ApiService.extractErrorMessage(e);
      showToast(msg);
      _errorMessage = msg;
      notifyListeners();
      return false;
    }
  }

  /// Alias for backward compatibility with existing screen references
  Future<bool> mockLogin({
    required String employeeId,
    required String password,
  }) =>
      login(employeeId: employeeId, password: password);
}

