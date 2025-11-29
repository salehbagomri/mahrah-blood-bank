import 'package:flutter/foundation.dart';
import '../models/blood_request_model.dart';
import '../models/donor_model.dart';
import '../services/supabase_service.dart';

/// مزود حالة طلبات الدم
class BloodRequestProvider with ChangeNotifier {
  List<BloodRequestModel> _requests = [];
  List<BloodRequestModel> _myRequests = [];
  List<DonorModel> _matchingDonors = [];
  bool _isLoading = false;
  String? _error;

  List<BloodRequestModel> get requests => _requests;
  List<BloodRequestModel> get myRequests => _myRequests;
  List<DonorModel> get matchingDonors => _matchingDonors;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final SupabaseService _supabaseService = SupabaseService();

  /// إنشاء طلب جديد
  Future<bool> createRequest(BloodRequestModel request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _supabaseService.insertBloodRequest(request);
      if (result != null) {
        _requests.insert(0, BloodRequestModel.fromJson(result));
        _myRequests.insert(0, BloodRequestModel.fromJson(result));
        _isLoading = false;
        notifyListeners();
        
        // إرسال الإشعارات للمتبرعين (سيتم في المرحلة القادمة)
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

  /// جلب جميع الطلبات النشطة
  Future<void> loadActiveRequests() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _supabaseService.getActiveBloodRequests();
      _requests = data.map((item) => BloodRequestModel.fromJson(item)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// جلب طلباتي
  Future<void> loadMyRequests(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _supabaseService.getMyBloodRequests(userId);
      _myRequests = data.map((item) => BloodRequestModel.fromJson(item)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// البحث عن متبرعين متطابقين
  Future<void> findMatchingDonors(String bloodType, String district) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _supabaseService.findMatchingDonors(bloodType, district);
      _matchingDonors = data.map((item) => DonorModel.fromJson(item)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تحديث حالة الطلب
  Future<bool> updateRequestStatus(String requestId, String status) async {
    try {
      final success = await _supabaseService.updateRequestStatus(requestId, status);
      if (success) {
        // تحديث القوائم المحلية
        _requests = _requests.map((req) {
          if (req.id == requestId) {
            return req.copyWith(status: status);
          }
          return req;
        }).toList().cast<BloodRequestModel>();
        
        _myRequests = _myRequests.map((req) {
          if (req.id == requestId) {
            return req.copyWith(status: status);
          }
          return req;
        }).toList().cast<BloodRequestModel>();
        
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
}
