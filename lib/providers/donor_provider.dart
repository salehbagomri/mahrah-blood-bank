import 'package:flutter/foundation.dart';
import 'package:mahrah_blood_bank/models/donor_model.dart';
import 'package:mahrah_blood_bank/services/supabase_service.dart';

/// مزود حالة المتبرع
class DonorProvider with ChangeNotifier {
  DonorModel? _currentDonor;
  bool _isLoading = false;
  String? _error;

  DonorModel? get currentDonor => _currentDonor;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// تسجيل متبرع جديد
  Future<bool> registerDonor(DonorModel donor) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await SupabaseService.createDonor(donor);
      if (result != null) {
        _currentDonor = result;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// تحميل بيانات المتبرع
  Future<void> loadDonorData(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await SupabaseService.getDonorByUserId(userId);
      if (data != null) {
        _currentDonor = data;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تحديث حالة التوفر
  Future<bool> updateAvailability(bool isAvailable) async {
    try {
      if (_currentDonor == null) return false;

      final success = await SupabaseService.updateDonorAvailability(
        _currentDonor!.id,
        isAvailable,
      );

      if (success) {
        _currentDonor = _currentDonor!.copyWith(isAvailable: isAvailable);
        notifyListeners();
      }

      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// تحديث بيانات المتبرع
  Future<bool> updateDonor(DonorModel updatedDonor) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await SupabaseService.updateDonor(updatedDonor);
      if (success) {
        _currentDonor = updatedDonor;
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// تسجيل تبرع جديد
  Future<bool> recordDonation() async {
    try {
      if (_currentDonor == null) return false;

      final success = await SupabaseService.recordDonation(_currentDonor!.id);

      if (success) {
        _currentDonor = _currentDonor!.copyWith(
          lastDonationDate: DateTime.now(),
          donationCount: _currentDonor!.donationCount + 1,
        );
        notifyListeners();
      }

      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clear() {
    _currentDonor = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
