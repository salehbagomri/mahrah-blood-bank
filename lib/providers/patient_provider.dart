import 'package:flutter/foundation.dart';
import 'package:mahrah_blood_bank/models/patient_model.dart';
import 'package:mahrah_blood_bank/services/supabase_service.dart';

/// مزود بيانات المريض
class PatientProvider with ChangeNotifier {
  PatientModel? _currentPatient;
  bool _isLoading = false;
  String? _errorMessage;

  PatientModel? get currentPatient => _currentPatient;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// تحميل بيانات المريض
  Future<void> loadPatientData(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentPatient = await SupabaseService.getPatientByUserId(userId);
      print('✅ تم تحميل بيانات المريض: ${_currentPatient?.fullName}');
    } catch (e) {
      _errorMessage = 'فشل تحميل بيانات المريض';
      print('❌ خطأ في تحميل بيانات المريض: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تسجيل مريض جديد
  Future<bool> registerPatient({
    required String userId,
    required String fullName,
    required int age,
    required String gender,
    required String bloodType,
    required String district,
    required String phone,
    String? address,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final patient = await SupabaseService.createPatient(
        userId: userId,
        fullName: fullName,
        age: age,
        gender: gender,
        bloodType: bloodType,
        district: district,
        phone: phone,
        address: address,
      );

      if (patient != null) {
        _currentPatient = patient;
        print('✅ تم تسجيل المريض: ${patient.fullName}');
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'فشل تسجيل المريض';
        return false;
      }
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء التسجيل';
      print('❌ خطأ في تسجيل المريض: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تحديث بيانات المريض
  Future<bool> updatePatient({
    required String patientId,
    String? fullName,
    int? age,
    String? gender,
    String? bloodType,
    String? district,
    String? phone,
    String? address,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (age != null) updates['age'] = age;
      if (gender != null) updates['gender'] = gender;
      if (bloodType != null) updates['blood_type'] = bloodType;
      if (district != null) updates['district'] = district;
      if (phone != null) updates['phone'] = phone;
      if (address != null) updates['address'] = address;

      final success = await SupabaseService.updatePatient(patientId, updates);

      if (success && _currentPatient != null) {
        // تحديث البيانات المحلية
        _currentPatient = _currentPatient!.copyWith(
          fullName: fullName,
          age: age,
          gender: gender,
          bloodType: bloodType,
          district: district,
          phone: phone,
          address: address,
        );
        print('✅ تم تحديث بيانات المريض');
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'فشل تحديث البيانات';
        return false;
      }
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء التحديث';
      print('❌ خطأ في تحديث المريض: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// مسح البيانات
  void clearPatient() {
    _currentPatient = null;
    _errorMessage = null;
    notifyListeners();
  }
}
