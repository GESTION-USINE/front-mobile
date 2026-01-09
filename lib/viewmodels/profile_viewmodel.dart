import 'package:flutter/material.dart';
import 'package:flutter_mvvm_template/core/base/base_viewmodel.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class ProfileViewModel extends BaseViewModel {
  final UserService _userService;

  ProfileViewModel(this._userService);

  User? _profile;
  bool _isLoading = false;
  String? _error;

  User? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load current user profile
  Future<void> loadProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _userService.getMyProfile();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _profile = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh profile
  Future<void> refreshProfile() async {
    await loadProfile();
  }

  /// Clear profile data
  void clearProfile() {
    _profile = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
