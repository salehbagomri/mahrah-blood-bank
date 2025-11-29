import 'package:firebase_messaging/firebase_messaging.dart';

/// خدمة الإشعارات باستخدام Firebase Cloud Messaging
class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// تهيئة خدمة الإشعارات
  static Future<void> initialize() async {
    // طلب الأذونات
    await _requestPermissions();

    // الحصول على FCM Token
    final token = await _messaging.getToken();
    if (token != null) {
      print('📱 FCM Token: $token');
      // TODO: حفظ الـ token في قاعدة البيانات مع بيانات المستخدم
    }

    // الاستماع لتحديثات الـ token
    _messaging.onTokenRefresh.listen((newToken) {
      print('🔄 FCM Token Updated: $newToken');
      // TODO: تحديث الـ token في قاعدة البيانات
    });

    // معالجة الإشعارات عندما يكون التطبيق في المقدمة
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // معالجة الإشعارات عندما يتم فتح التطبيق من إشعار
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // معالجة الإشعارات عندما يكون التطبيق مغلق تماماً
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  /// طلب أذونات الإشعارات
  static Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
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

  /// معالجة الإشعارات في المقدمة
  static void _handleForegroundMessage(RemoteMessage message) {
    print('📨 إشعار جديد في المقدمة:');
    print('العنوان: ${message.notification?.title}');
    print('المحتوى: ${message.notification?.body}');
    print('البيانات: ${message.data}');

    // TODO: عرض إشعار محلي أو حوار للمستخدم
  }

  /// معالجة النقر على الإشعار
  static void _handleNotificationTap(RemoteMessage message) {
    print('👆 تم النقر على إشعار:');
    print('العنوان: ${message.notification?.title}');
    print('البيانات: ${message.data}');

    // TODO: التنقل إلى الشاشة المناسبة بناءً على نوع الإشعار
    // مثال: إذا كان إشعار طلب دم جديد، انتقل إلى شاشة الطلبات
  }

  /// الاشتراك في موضوع (Topic)
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      print('✅ تم الاشتراك في موضوع: $topic');
    } catch (e) {
      print('❌ خطأ في الاشتراك في الموضوع: $e');
    }
  }

  /// إلغاء الاشتراك من موضوع
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      print('✅ تم إلغاء الاشتراك من موضوع: $topic');
    } catch (e) {
      print('❌ خطأ في إلغاء الاشتراك من الموضوع: $e');
    }
  }

  /// الاشتراك في إشعارات فصيلة دم معينة
  static Future<void> subscribeToBloodType(String bloodType) async {
    final topic = 'blood_type_${bloodType.replaceAll('+', 'plus').replaceAll('-', 'minus')}';
    await subscribeToTopic(topic);
  }

  /// الاشتراك في إشعارات مديرية معينة
  static Future<void> subscribeToDistrict(String district) async {
    final topic = 'district_$district';
    await subscribeToTopic(topic);
  }

  /// الحصول على FCM Token
  static Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      print('❌ خطأ في الحصول على FCM Token: $e');
      return null;
    }
  }
}

/// معالج الإشعارات في الخلفية (يجب أن يكون دالة عامة)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📨 إشعار في الخلفية:');
  print('العنوان: ${message.notification?.title}');
  print('المحتوى: ${message.notification?.body}');
}
