import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:mahrah_blood_bank/config/theme.dart';
import 'package:mahrah_blood_bank/config/supabase_config.dart';
import 'package:mahrah_blood_bank/config/firebase_config.dart';
import 'package:mahrah_blood_bank/providers/auth_provider.dart';
import 'package:mahrah_blood_bank/providers/donor_provider.dart';
import 'package:mahrah_blood_bank/providers/hospital_provider.dart';
import 'package:mahrah_blood_bank/providers/patient_provider.dart';
import 'package:mahrah_blood_bank/providers/blood_request_provider.dart';
import 'package:mahrah_blood_bank/services/notification_service.dart';
import 'package:mahrah_blood_bank/screens/splash_screen.dart';
import 'package:mahrah_blood_bank/screens/onboarding_screen.dart';
import 'package:mahrah_blood_bank/screens/account_type_screen.dart';
import 'package:mahrah_blood_bank/screens/login_screen.dart';
import 'package:mahrah_blood_bank/screens/phone_input_screen.dart';
import 'package:mahrah_blood_bank/screens/main_navigation_screen.dart';
import 'package:mahrah_blood_bank/screens/donor/donor_registration_screen.dart';
import 'package:mahrah_blood_bank/screens/donor/donor_home_screen.dart';
import 'package:mahrah_blood_bank/screens/patient/patient_registration_screen.dart';
import 'package:mahrah_blood_bank/screens/hospital/hospital_registration_screen.dart';
import 'package:mahrah_blood_bank/screens/hospital/create_blood_request_screen.dart';

void main() async {
  // تأكد من تهيئة Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // تعيين اتجاه الشاشة (عمودي فقط)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // تهيئة Supabase
  try {
    await SupabaseConfig.initialize();
    print('✅ تم تهيئة Supabase بنجاح');
  } catch (e) {
    print('❌ خطأ في تهيئة Supabase: $e');
    print('⚠️ تأكد من إضافة URL و Anon Key في ملف supabase_config.dart');
  }

  // تهيئة Firebase
  try {
    await FirebaseConfig.initialize();
    print('✅ تم تهيئة Firebase بنجاح');
  } catch (e) {
    print('❌ خطأ في تهيئة Firebase: $e');
    print(
        '⚠️ تأكد من إضافة ملفات google-services.json و GoogleService-Info.plist');
  }

  // تهيئة خدمة الإشعارات
  try {
    await NotificationService.initialize();
    print('✅ تم تهيئة خدمة الإشعارات بنجاح');
  } catch (e) {
    print('❌ خطأ في تهيئة خدمة الإشعارات: $e');
  }

  // تشغيل التطبيق
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // مزود المصادقة
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..checkAuthStatus(),
        ),
        // مزود المتبرع
        ChangeNotifierProvider(
          create: (_) => DonorProvider(),
        ),
        // مزود المستشفى
        ChangeNotifierProvider(
          create: (_) => HospitalProvider(),
        ),
        // مزود المريض
        ChangeNotifierProvider(
          create: (_) => PatientProvider(),
        ),
        // مزود طلبات الدم
        ChangeNotifierProvider(
          create: (_) => BloodRequestProvider(),
        ),
      ],
      child: MaterialApp(
        // إعدادات التطبيق
        title: 'بنك الدم - المهرة',
        debugShowCheckedModeBanner: false,

        // الثيم مع خط IBM Plex Sans Arabic
        theme: ThemeData(
          // استخدام IBM Plex Sans Arabic كخط افتراضي (محلي)
          fontFamily: 'IBM Plex Sans Arabic',
          // نسخ باقي إعدادات الثيم
          primaryColor: AppTheme.primaryRed,
          scaffoldBackgroundColor: AppTheme.backgroundColor,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppTheme.primaryRed,
            secondary: AppTheme.secondaryGreen,
          ),
          // AppBar مع الخط العربي
          appBarTheme: AppTheme.lightTheme.appBarTheme.copyWith(
            titleTextStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'IBM Plex Sans Arabic',
            ),
          ),
          // الأزرار مع الخط العربي
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: AppTheme.lightTheme.elevatedButtonTheme.style!.copyWith(
              textStyle: WidgetStateProperty.all(
                const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: AppTheme.lightTheme.outlinedButtonTheme.style!.copyWith(
              textStyle: WidgetStateProperty.all(
                const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: AppTheme.lightTheme.textButtonTheme.style!.copyWith(
              textStyle: WidgetStateProperty.all(
                const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
              ),
            ),
          ),
          cardTheme: AppTheme.lightTheme.cardTheme,
          inputDecorationTheme: AppTheme.lightTheme.inputDecorationTheme,
          dividerTheme: AppTheme.lightTheme.dividerTheme,
        ),

        // دعم RTL
        locale: const Locale('ar'),
        supportedLocales: const [
          Locale('ar'), // العربية
          Locale('en'), // English (fallback)
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        // الشاشة الأولى
        home: const SplashScreen(),

        // المسارات
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/account-type': (context) => const AccountTypeScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const MainNavigationScreen(),
          '/donor-registration': (context) => const DonorRegistrationScreen(),
          '/donor-home': (context) => const DonorHomeScreen(),
        },

        // مسارات ديناميكية
        onGenerateRoute: (settings) {
          if (settings.name == '/phone-input') {
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => PhoneInputScreen(
                userType: args?['userType'],
                isExistingUser: args?['isExistingUser'] ?? false,
              ),
            );
          }
          if (settings.name == '/hospital-registration') {
            return MaterialPageRoute(
              builder: (context) => const HospitalRegistrationScreen(),
            );
          }
          if (settings.name == '/create-blood-request') {
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => CreateBloodRequestScreen(
                requesterType: args?['requesterType'] ?? 'patient',
              ),
            );
          }
          if (settings.name == '/patient-registration') {
            final phoneNumber = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => PatientRegistrationScreen(
                phoneNumber: phoneNumber,
              ),
            );
          }
          return null;
        },

        // بناء التطبيق مع RTL
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox(),
          );
        },
      ),
    );
  }
}
