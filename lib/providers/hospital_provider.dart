import 'package:flutter/foundation.dart';
import '../models/hospital_model.dart';
import '../services/supabase_service.dart';

/// مزود حالة المستشفى
class HospitalProvider with ChangeNotifier {
  HospitalModel? _currentHospital;
  bool _isLoading = false;
  String? _error;

  HospitalModel? get currentHospital => _currentHospital;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final SupabaseService _supabaseService = SupabaseService();

  /// تسجيل مستشفى جديد
  Future<bool> registerHospital(HospitalModel hospital) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _supabaseService.insertHospital(hospital);
      if (result != null) {
        _currentHospital = HospitalModel.fromJson(result);
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

  /// تحميل بيانات المستشفى
  Future<void> loadHospitalData(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _supabaseService.getHospitalByUserId(userId);
      if (data != null) {
        _currentHospital = HospitalModel.fromJson(data);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
