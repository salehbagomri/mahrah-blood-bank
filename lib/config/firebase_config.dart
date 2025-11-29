import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// إعدادات Firebase
class FirebaseConfig {
  /// تهيئة Firebase
  static Future<void> initialize() async {
    // تهيئة Firebase Core
    await Firebase.initializeApp(
      // TODO: أضف خيارات Firebase هنا بعد إضافة ملفات الإعداد
      // google-services.json لـ Android
      // GoogleService-Info.plist لـ iOS
    );

    // طلب أذونات الإشعارات
    await _requestNotificationPermissions();
  }

  /// طلب أذونات الإشعارات
  static Future<void> _requestNotificationPermissions() async {
    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ تم منح أذونات الإشعارات');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('⚠️ تم منح أذونات إشعارات مؤقتة');
    } else {
      print('❌ لم يتم منح أذونات الإشعارات');
    }
  }

  /// الحصول على FCM Token
  static Future<String?> getFCMToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      print('📱 FCM Token: $token');
      return token;
    } catch (e) {
      print('❌ خطأ في الحصول على FCM Token: $e');
      return null;
    }
  }
}
