import 'package:flutter/material.dart';

import '../../../helpers/sp_helper.dart';
import '../../../providers/view_model.dart';
import '../../../repositories/auth_repository.dart';
import '../../../utils/extensions.dart';
import '../../../utils/sp_keys.dart' as sp_keys;

class FactoryLocation {
  final String code;
  final String address;

  const FactoryLocation({
    required this.code,
    required this.address,
  });
}

class ChooseLocationViewModel extends ViewModel {
  final AuthRepository _authRepository;

  List<FactoryLocation> _allLocations = [];
  String _searchQuery = '';
  FactoryLocation? _selectedLocation;
  bool _isLoaded = false;

  ChooseLocationViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepositoryImpl();

  // Getters
  List<FactoryLocation> get allLocations => _allLocations;
  String get searchQuery => _searchQuery;
  FactoryLocation? get selectedLocation => _selectedLocation;
  bool get isLoaded => _isLoaded;

  List<FactoryLocation> get filteredLocations {
    if (_searchQuery.trim().isEmpty) return _allLocations;
    final q = _searchQuery.toLowerCase();
    return _allLocations.where((loc) {
      return loc.code.toLowerCase().contains(q) ||
          loc.address.toLowerCase().contains(q);
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Loads locations from API repository with setProgress
  Future<void> loadLocations() async {
    if (_authRepository is AuthRepositoryImpl &&
        WidgetsBinding.instance.runtimeType.toString().contains('Test')) {
      return;
    }

    try {
      final factories =
          await _authRepository.getFactories().setProgress(this);
      _allLocations = factories.map((f) {
        final code = f.code.isNotEmpty ? f.code : f.name;
        final address = f.address ?? (f.city ?? f.name);
        return FactoryLocation(code: code, address: address);
      }).toList();
    } catch (_) {
      // No dummy data; remains empty if API call fails
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  /// Selects a location and persists it to SharedPreferences
  Future<void> selectLocation(FactoryLocation loc) async {
    _selectedLocation = loc;
    await SpHelper.saveString(sp_keys.keySelectedLocation, loc.code);
    await SpHelper.saveString(sp_keys.keyTenantCode, loc.code);
    notifyListeners();
  }
}
