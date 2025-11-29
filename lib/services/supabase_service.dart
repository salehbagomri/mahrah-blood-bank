import 'package:mahrah_blood_bank/config/supabase_config.dart';
import 'package:mahrah_blood_bank/models/user_model.dart';
import 'package:mahrah_blood_bank/models/donor_model.dart';
import 'package:mahrah_blood_bank/models/hospital_model.dart';

/// خدمة Supabase للتعامل مع قاعدة البيانات
class SupabaseService {
  // الحصول على عميل Supabase
  static final _client = SupabaseConfig.client;

  // ==================== المستخدمين ====================

  /// إنشاء مستخدم جديد
  static Future<UserModel?> createUser({
    required String phone,
    required String userType,
  }) async {
    try {
      final response = await _client
          .from('users')
          .insert({
            'phone': phone,
            'user_type': userType,
          })
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('❌ خطأ في إنشاء المستخدم: $e');

      // إذا كان الخطأ بسبب وجود المستخدم مسبقاً (duplicate key)
      if (e.toString().contains('duplicate key') ||
          e.toString().contains('23505') ||
          e.toString().contains('users_phone_key')) {
        print('ℹ️ المستخدم موجود مسبقاً، جلب البيانات...');
        // محاولة جلب المستخدم الموجود
        return await getUserByPhone(phone);
      }

      return null;
    }
  }

  /// الحصول على مستخدم بواسطة ID
  static Future<UserModel?> getUserById(String userId) async {
    try {
      final response =
          await _client.from('users').select().eq('id', userId).single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('❌ خطأ في جلب المستخدم: $e');
      return null;
    }
  }

  /// الحصول على مستخدم بواسطة رقم الهاتف
  static Future<UserModel?> getUserByPhone(String phone) async {
    try {
      final response =
          await _client.from('users').select().eq('phone', phone).maybeSingle();

      if (response == null) return null;
      return UserModel.fromJson(response);
    } catch (e) {
      print('❌ خطأ في جلب المستخدم: $e');
      return null;
    }
  }

  // ==================== المتبرعين ====================

  /// إنشاء متبرع جديد
  static Future<DonorModel?> createDonor(DonorModel donor) async {
    try {
      final response =
          await _client.from('donors').insert(donor.toJson()).select().single();

      return DonorModel.fromJson(response);
    } catch (e) {
      print('❌ خطأ في إنشاء المتبرع: $e');
      return null;
    }
  }

  /// الحصول على متبرع بواسطة user_id
  static Future<DonorModel?> getDonorByUserId(String userId) async {
    try {
      final response =
          await _client.from('donors').select().eq('user_id', userId).single();

      return DonorModel.fromJson(response);
    } catch (e) {
      print('❌ خطأ في جلب المتبرع: $e');
      return null;
    }
  }

  /// البحث عن متبرعين
  static Future<List<DonorModel>> searchDonors({
    String? bloodType,
    String? district,
    bool? isAvailable,
  }) async {
    try {
      var query = _client.from('donors').select();

      if (bloodType != null) {
        query = query.eq('blood_type', bloodType);
      }
      if (district != null) {
        query = query.eq('district', district);
      }
      if (isAvailable != null) {
        query = query.eq('is_available', isAvailable);
      }

      final response = await query;
      return (response as List)
          .map((json) => DonorModel.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ خطأ في البحث عن المتبرعين: $e');
      return [];
    }
  }

  /// تحديث بيانات المتبرع
  static Future<bool> updateDonor(DonorModel donor) async {
    try {
      await _client.from('donors').update(donor.toJson()).eq('id', donor.id);
      return true;
    } catch (e) {
      print('❌ خطأ في تحديث المتبرع: $e');
      return false;
    }
  }

  /// تحديث حالة توفر المتبرع
  static Future<bool> updateDonorAvailability(
      String donorId, bool isAvailable) async {
    try {
      await _client
          .from('donors')
          .update({'is_available': isAvailable}).eq('id', donorId);
      return true;
    } catch (e) {
      print('❌ خطأ في تحديث حالة التوفر: $e');
      return false;
    }
  }

  /// تسجيل تبرع جديد
  static Future<bool> recordDonation(String donorId) async {
    try {
      // استدعاء دالة SQL في Supabase
      await _client.rpc('record_donation', params: {'donor_id': donorId});
      return true;
    } catch (e) {
      print('❌ خطأ في تسجيل التبرع: $e');
      return false;
    }
  }

  // ==================== المستشفيات ====================

  /// إنشاء مستشفى جديد
  Future<Map<String, dynamic>?> insertHospital(HospitalModel hospital) async {
    try {
      final response = await _client
          .from('hospitals')
          .insert(hospital.toJson())
          .select()
          .single();
      return response;
    } catch (e) {
      print('❌ خطأ في إدراج المستشفى: $e');
      return null;
    }
  }

  /// الحصول على مستشفى بواسطة user_id
  Future<Map<String, dynamic>?> getHospitalByUserId(String userId) async {
    try {
      final response = await _client
          .from('hospitals')
          .select()
          .eq('user_id', userId)
          .single();
      return response;
    } catch (e) {
      print('❌ خطأ في جلب بيانات المستشفى: $e');
      return null;
    }
  }

  // ==================== طلبات الدم ====================

  /// إنشاء طلب دم جديد
  Future<Map<String, dynamic>?> insertBloodRequest(dynamic request) async {
    try {
      final response = await _client
          .from('blood_requests')
          .insert(request.toJson())
          .select()
          .single();
      return response;
    } catch (e) {
      print('❌ خطأ في إنشاء الطلب: $e');
      return null;
    }
  }

  /// الحصول على جميع الطلبات النشطة
  Future<List<Map<String, dynamic>>> getActiveBloodRequests() async {
    try {
      final response = await _client
          .from('blood_requests')
          .select()
          .eq('status', 'active')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ خطأ في جلب الطلبات: $e');
      return [];
    }
  }

  /// الحصول على طلباتي
  Future<List<Map<String, dynamic>>> getMyBloodRequests(String userId) async {
    try {
      final response = await _client
          .from('blood_requests')
          .select()
          .eq('requester_id', userId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ خطأ في جلب طلباتي: $e');
      return [];
    }
  }

  /// البحث عن متبرعين متطابقين
  Future<List<Map<String, dynamic>>> findMatchingDonors(
    String bloodType,
    String district,
  ) async {
    try {
      // الحصول على الفصائل المتوافقة
      final compatibleTypes = _getCompatibleBloodTypes(bloodType);

      final response = await _client
          .from('donors')
          .select()
          .filter('blood_type', 'in', '(${compatibleTypes.join(',')})')
          .eq('district', district)
          .eq('is_available', true)
          .eq('has_chronic_diseases', false)
          .order('donation_count', ascending: true); // الأقل تبرعاً أولاً

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ خطأ في البحث عن المتبرعين: $e');
      return [];
    }
  }

  /// تحديث حالة طلب الدم
  Future<bool> updateRequestStatus(String requestId, String status) async {
    try {
      await _client
          .from('blood_requests')
          .update({'status': status}).eq('id', requestId);
      return true;
    } catch (e) {
      print('❌ خطأ في تحديث حالة الطلب: $e');
      return false;
    }
  }

  /// الحصول على الفصائل المتوافقة
  List<String> _getCompatibleBloodTypes(String bloodType) {
    // خريطة التوافق
    const compatibility = {
      'O-': ['O-'],
      'O+': ['O-', 'O+'],
      'A-': ['O-', 'A-'],
      'A+': ['O-', 'O+', 'A-', 'A+'],
      'B-': ['O-', 'B-'],
      'B+': ['O-', 'O+', 'B-', 'B+'],
      'AB-': ['O-', 'A-', 'B-', 'AB-'],
      'AB+': ['O-', 'O+', 'A-', 'A+', 'B-', 'B+', 'AB-', 'AB+'],
    };

    return compatibility[bloodType] ?? [bloodType];
  }

  // ==================== المديريات ====================

  /// الحصول على قائمة المديريات من القاعدة
  static Future<List<String>> getDistricts() async {
    try {
      final response = await _client
          .from('districts')
          .select('name_ar')
          .eq('is_active', true)
          .order('name_ar');

      return (response as List)
          .map((item) => item['name_ar'] as String)
          .toList();
    } catch (e) {
      print('❌ خطأ في جلب المديريات: $e');
      return [];
    }
  }

  // ==================== المرضى ====================

  /// إنشاء مريض جديد
  static Future<dynamic> createPatient({
    required String userId,
    required String fullName,
    required int age,
    required String gender,
    required String bloodType,
    required String district,
    required String phone,
    String? address,
  }) async {
    try {
      final response = await _client
          .from('patients')
          .insert({
            'user_id': userId,
            'full_name': fullName,
            'age': age,
            'gender': gender,
            'blood_type': bloodType,
            'district': district,
            'phone': phone,
            'address': address,
          })
          .select()
          .single();

      print('✅ تم إنشاء المريض: $fullName');
      return response;
    } catch (e) {
      print('❌ خطأ في إنشاء المريض: $e');
      return null;
    }
  }

  /// الحصول على مريض بواسطة user_id
  static Future<dynamic> getPatientByUserId(String userId) async {
    try {
      final response = await _client
          .from('patients')
          .select()
          .eq('user_id', userId)
          .single();

      return response;
    } catch (e) {
      print('❌ خطأ في جلب المريض: $e');
      return null;
    }
  }

  /// تحديث بيانات المريض
  static Future<bool> updatePatient(
      String patientId, Map<String, dynamic> updates) async {
    try {
      updates['updated_at'] = DateTime.now().toIso8601String();

      await _client.from('patients').update(updates).eq('id', patientId);

      print('✅ تم تحديث بيانات المريض');
      return true;
    } catch (e) {
      print('❌ خطأ في تحديث المريض: $e');
      return false;
    }
  }
}
