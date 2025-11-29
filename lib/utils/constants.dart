/// الثوابت العامة للتطبيق
library;

// مديريات محافظة المهرة
const List<String> DISTRICTS = [
  'الغيضة',
  'سيحوت',
  'حصوين',
  'قشن',
  'حوف',
  'شحن',
  'المسيلة',
  'حات',
  'الحدبين',
];

/// Class للوصول السهل للمديريات
class Districts {
  static const List<String> allDistricts = DISTRICTS;
}

// أنواع المستخدمين
class UserType {
  static const String donor = 'donor'; // متبرع
  static const String hospital = 'hospital'; // مستشفى
  static const String patient = 'patient'; // محتاج لدم
}

// مستويات الأولوية
class UrgencyLevel {
  static const String urgent = 'urgent'; // عاجل
  static const String normal = 'normal'; // عادي
}

// حالات الطلب
class RequestStatus {
  static const String active = 'active'; // نشط
  static const String completed = 'completed'; // مكتمل
  static const String cancelled = 'cancelled'; // ملغي
}

// الجنس
class Gender {
  static const String male = 'male'; // ذكر
  static const String female = 'female'; // أنثى
}

// مفاتيح SharedPreferences
class PrefsKeys {
  static const String isLoggedIn = 'is_logged_in';
  static const String userId = 'user_id';
  static const String userType = 'user_type';
  static const String phoneNumber = 'phone_number';
  static const String hasSeenOnboarding = 'has_seen_onboarding';
}

// الثوابت الرقمية
class AppConstants {
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 16.0;
  static const double cardElevation = 2.0;
  static const double buttonHeight = 56.0;
  
  // الحد الأدنى للوزن للتبرع (كجم)
  static const double minDonorWeight = 50.0;
  
  // الحد الأدنى للعمر للتبرع (سنة)
  static const int minDonorAge = 18;
  
  // الحد الأقصى للعمر للتبرع (سنة)
  static const int maxDonorAge = 65;
  
  // الفترة بين التبرعات (أيام)
  static const int daysBetweenDonations = 90;
  
  // مدة شاشة Splash (ثواني)
  static const int splashDuration = 2;
}

// رسائل الخطأ
class ErrorMessages {
  static const String networkError = 'خطأ في الاتصال بالإنترنت';
  static const String serverError = 'خطأ في الخادم، يرجى المحاولة لاحقاً';
  static const String invalidPhone = 'رقم الهاتف غير صحيح';
  static const String invalidOtp = 'رمز التحقق غير صحيح';
  static const String requiredField = 'هذا الحقل مطلوب';
  static const String unknownError = 'حدث خطأ غير متوقع';
}

// رسائل النجاح
class SuccessMessages {
  static const String otpSent = 'تم إرسال رمز التحقق';
  static const String loginSuccess = 'تم تسجيل الدخول بنجاح';
  static const String registrationSuccess = 'تم التسجيل بنجاح';
  static const String profileUpdated = 'تم تحديث الملف الشخصي';
  static const String requestCreated = 'تم إنشاء الطلب بنجاح';
}
