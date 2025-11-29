import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mahrah_blood_bank/models/user_model.dart';
import 'package:mahrah_blood_bank/services/supabase_service.dart';
import 'package:mahrah_blood_bank/utils/constants.dart';

/// مزود المصادقة - إدارة حالة تسجيل الدخول باستخدام Firebase Auth
class AuthProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  String? _verificationId; // لحفظ verification ID من Firebase

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  /// التحقق من حالة تسجيل الدخول عند بدء التطبيق
  Future<void> checkAuthStatus() async {
    _setLoading(true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(PrefsKeys.isLoggedIn) ?? false;

      if (isLoggedIn) {
        final userId = prefs.getString(PrefsKeys.userId);
        if (userId != null) {
          _currentUser = await SupabaseService.getUserById(userId);
          notifyListeners();
        }
      }
    } catch (e) {
      print('❌ خطأ في التحقق من حالة المصادقة: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// تحديث المستخدم الحالي
  void updateCurrentUser(UserModel user) {
    _currentUser = user;
    _saveAuthState(user);
    notifyListeners();
  }

  /// إرسال رمز OTP إلى رقم الهاتف باستخدام Firebase
  Future<bool> sendOTP(String phoneNumber) async {
    _setLoading(true);
    _clearError();

    try {
      // التأكد من أن الرقم بالصيغة الدولية
      String formattedPhone = phoneNumber;
      if (!formattedPhone.startsWith('+')) {
        formattedPhone = '+967$phoneNumber'; // رمز اليمن
      }

      print('📱 إرسال OTP إلى: $formattedPhone');
      print('🔧 Firebase Auth Settings:');
      print('   - App Verification Disabled: ${_auth.app.options.projectId}');

      // استخدام Completer للانتظار حتى يتم إرسال الكود
      final completer = Completer<bool>();

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        timeout: const Duration(seconds: 60),

        // عند إرسال الكود بنجاح
        codeSent: (String verificationId, int? resendToken) {
          print('✅ تم إرسال الكود بنجاح');
          print('🔑 Verification ID: ${verificationId.substring(0, 20)}...');
          _verificationId = verificationId;
          _setLoading(false);
          if (!completer.isCompleted) {
            completer.complete(true);
          }
        },

        // عند التحقق تلقائياً (بعض الأجهزة)
        verificationCompleted: (PhoneAuthCredential credential) async {
          print('✅ تم التحقق تلقائياً');
          await _signInWithCredential(credential, formattedPhone);
          _setLoading(false);
          if (!completer.isCompleted) {
            completer.complete(true);
          }
        },

        // عند فشل الإرسال
        verificationFailed: (FirebaseAuthException e) {
          print('❌ فشل التحقق: ${e.code} - ${e.message}');
          print('📊 Error details:');
          print('   - Code: ${e.code}');
          print('   - Message: ${e.message}');
          print('   - Plugin: ${e.plugin}');

          String errorMessage = 'فشل إرسال رمز التحقق';

          switch (e.code) {
            case 'invalid-phone-number':
              errorMessage = 'رقم الهاتف غير صحيح';
              break;
            case 'too-many-requests':
              errorMessage = 'تم تجاوز عدد المحاولات. حاول لاحقاً';
              break;
            case 'quota-exceeded':
              errorMessage = 'تم تجاوز الحد المسموح. حاول لاحقاً';
              break;
            case 'operation-not-allowed':
              errorMessage = '''
⚠️ Phone Authentication غير مُفعّل بشكل صحيح!

الأسباب المحتملة:
1. SHA-1 fingerprint لم يُضف في Firebase Console
2. google-services.json قديم (oauth_client فارغ)
3. Phone Authentication غير مُفعّل
4. Test Phone Numbers غير مُضافة

الحل:
1. Firebase Console → Project Settings
2. أضف SHA-1: 62:49:9E:EC:19:C3:76:1D:F9:76:14:67:BC:BC:59:36:F6:26:25:B9
3. حمّل google-services.json الجديد
4. تأكد من أن oauth_client ليس فارغاً
              ''';
              break;
            default:
              errorMessage = 'فشل إرسال رمز التحقق: ${e.message}';
          }

          _setError(errorMessage);
          _setLoading(false);
          if (!completer.isCompleted) {
            completer.complete(false);
          }
        },

        // عند انتهاء المهلة
        codeAutoRetrievalTimeout: (String verificationId) {
          print('⏱️ انتهت مهلة الاسترجاع التلقائي');
          print(
              '🔑 Verification ID (timeout): ${verificationId.substring(0, 20)}...');
          _verificationId ??= verificationId;
        },
      );

      // الانتظار حتى يتم إرسال الكود أو يفشل
      return await completer.future;
    } catch (e) {
      print('❌ خطأ في sendOTP: $e');
      _setError('فشل إرسال رمز التحقق: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// التحقق من رمز OTP وتسجيل الدخول
  /// Returns true if user is new, false if existing user
  Future<bool> verifyOTP(String phoneNumber, String otp) async {
    _setLoading(true);
    _clearError();

    try {
      print('🔐 بدء التحقق من OTP...');
      print('📱 الرقم: $phoneNumber');
      print('🔢 الكود: $otp');
      print('🔑 Verification ID موجود: ${_verificationId != null}');

      if (_verificationId == null) {
        print('❌ Verification ID غير موجود!');
        throw Exception('لم يتم إرسال رمز التحقق. الرجاء المحاولة مرة أخرى.');
      }

      // التأكد من أن الرقم بالصيغة الدولية
      String formattedPhone = phoneNumber;
      if (!formattedPhone.startsWith('+')) {
        formattedPhone = '+967$phoneNumber';
      }

      print('🔐 إنشاء Credential...');

      // إنشاء credential من verification ID والكود
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      print('🔐 تسجيل الدخول في Firebase...');

      // تسجيل الدخول في Firebase
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        print('✅ تم التحقق من OTP بنجاح');
        print('👤 Firebase UID: ${userCredential.user!.uid}');

        try {
          // التحقق من وجود المستخدم في قاعدة البيانات
          print('🔍 البحث عن المستخدم في قاعدة البيانات...');
          UserModel? user =
              await SupabaseService.getUserByPhone(formattedPhone);

          bool isNewUser = user == null;
          print('👤 مستخدم ${isNewUser ? "جديد" : "موجود"}');

          // إذا كان مستخدم موجود، تحديث البيانات
          if (user != null) {
            _currentUser = user;
            await _saveAuthState(user);
            _setLoading(false);
            notifyListeners();
            return false; // مستخدم موجود
          }
        } catch (e) {
          print('⚠️ خطأ في البحث عن المستخدم في Supabase: $e');
          // المستخدم غير موجود في Supabase - اعتباره مستخدم جديد
        }

        // مستخدم جديد - سيتم إنشاؤه في شاشة التسجيل
        _setLoading(false);
        return true; // مستخدم جديد
      }

      throw Exception('فشل التحقق من رمز OTP');
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth Error: ${e.code} - ${e.message}');

      String errorMessage = 'خطأ في التحقق';

      switch (e.code) {
        case 'invalid-verification-code':
          errorMessage = 'رمز التحقق غير صحيح';
          break;
        case 'session-expired':
          errorMessage = 'انتهت صلاحية رمز التحقق. الرجاء طلب رمز جديد';
          _verificationId = null; // مسح verification ID
          break;
        case 'invalid-verification-id':
          errorMessage = 'رمز التحقق غير صالح. الرجاء طلب رمز جديد';
          _verificationId = null;
          break;
        default:
          errorMessage = 'خطأ في التحقق: ${e.message}';
      }

      _setError(errorMessage);
      _setLoading(false);
      throw Exception(errorMessage);
    } catch (e) {
      print('❌ خطأ عام: $e');

      // تجاهل خطأ PigeonUserDetails (مشكلة معروفة في firebase_auth)
      if (e.toString().contains('PigeonUserDetails')) {
        print('⚠️ خطأ داخلي في Firebase Auth - لكن التحقق نجح!');
        _setLoading(false);
        return true; // اعتبار المستخدم جديد
      }

      _setError('خطأ في التحقق: ${e.toString()}');
      _setLoading(false);
      rethrow;
    }
  }

  /// تسجيل الدخول باستخدام Credential
  Future<void> _signInWithCredential(
      PhoneAuthCredential credential, String phoneNumber) async {
    try {
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        // التحقق من وجود المستخدم في قاعدة البيانات
        UserModel? user = await SupabaseService.getUserByPhone(phoneNumber);

        if (user != null) {
          _currentUser = user;
          await _saveAuthState(user);
          notifyListeners();
        }
      }
    } catch (e) {
      print('❌ خطأ في تسجيل الدخول: $e');
    }
  }

  /// إعادة إرسال رمز OTP
  Future<bool> resendOTP(String phoneNumber) async {
    return await sendOTP(phoneNumber);
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    _setLoading(true);

    try {
      await _auth.signOut();
      await _clearAuthState();
      _currentUser = null;
      _verificationId = null;
      notifyListeners();
    } catch (e) {
      print('❌ خطأ في تسجيل الخروج: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// حفظ حالة المصادقة في SharedPreferences
  Future<void> _saveAuthState(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefsKeys.isLoggedIn, true);
    await prefs.setString(PrefsKeys.userId, user.id);
    await prefs.setString(PrefsKeys.userType, user.userType);
    await prefs.setString(PrefsKeys.phoneNumber, user.phone);
  }

  /// مسح حالة المصادقة من SharedPreferences
  Future<void> _clearAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(PrefsKeys.isLoggedIn);
    await prefs.remove(PrefsKeys.userId);
    await prefs.remove(PrefsKeys.userType);
    await prefs.remove(PrefsKeys.phoneNumber);
  }

  /// تعيين حالة التحميل
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// تعيين رسالة خطأ
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// مسح رسالة الخطأ
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
