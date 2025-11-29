import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mahrah_blood_bank/config/theme.dart';
import 'package:mahrah_blood_bank/widgets/custom_button.dart';
import 'package:mahrah_blood_bank/utils/constants.dart';
import 'package:mahrah_blood_bank/providers/auth_provider.dart';
import 'package:mahrah_blood_bank/screens/otp_verification_screen.dart';

/// شاشة إدخال رقم الهاتف
class PhoneInputScreen extends StatefulWidget {
  final String? userType;
  final bool isExistingUser;

  const PhoneInputScreen({
    super.key,
    this.userType,
    this.isExistingUser = false,
  });

  @override
  State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  /// التحقق من صحة رقم الهاتف اليمني
  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال رقم الهاتف';
    }

    // إزالة المسافات والرموز
    final cleanNumber = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // التحقق من أن الرقم يبدأ بـ 7 ويتكون من 9 أرقام
    if (!RegExp(r'^7[0-9]{8}$').hasMatch(cleanNumber)) {
      return 'رقم الهاتف غير صحيح (يجب أن يبدأ بـ 7 ويتكون من 9 أرقام)';
    }

    return null;
  }

  /// إرسال رمز OTP
  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final phoneNumber = _phoneController.text.trim();

      print('📱 محاولة إرسال OTP إلى: +967$phoneNumber');

      // إرسال OTP والانتظار حتى ينجح
      final success = await authProvider.sendOTP(phoneNumber);

      if (!mounted) return;

      if (success) {
        print('✅ تم إرسال OTP بنجاح - الانتقال لشاشة التحقق');

        // الانتقال لشاشة التحقق فقط إذا نجح الإرسال
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPVerificationScreen(
              phoneNumber: phoneNumber,
              userType: widget.userType ?? 'donor',
            ),
          ),
        );
      } else {
        print('❌ فشل إرسال OTP');

        // عرض رسالة خطأ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.errorMessage ?? 'فشل إرسال رمز التحقق',
              style: const TextStyle(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      print('❌ خطأ في _sendOTP: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ: ${e.toString()}',
            style: const TextStyle(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل الدخول'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),

                // أيقونة الهاتف
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRed.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.phone_android,
                    size: 50,
                    color: AppTheme.primaryRed,
                  ),
                ),
                const SizedBox(height: 32),

                // العنوان
                const Text(
                  'أدخل رقم هاتفك',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // الوصف
                const Text(
                  'سنرسل لك رمز التحقق عبر رسالة نصية',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 48),

                // حقل رقم الهاتف
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      AppConstants.defaultBorderRadius,
                    ),
                    border: Border.all(
                      color: AppTheme.dividerColor,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // كود الدولة
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryRed.withOpacity(0.1),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(
                              AppConstants.defaultBorderRadius,
                            ),
                            bottomRight: Radius.circular(
                              AppConstants.defaultBorderRadius,
                            ),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              '🇾🇪',
                              style: TextStyle(fontSize: 24),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '+967',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // حقل الإدخال
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          textDirection: TextDirection.ltr,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(9),
                          ],
                          decoration: const InputDecoration(
                            hintText: '7XXXXXXXX',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.normal,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          validator: _validatePhoneNumber,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ملاحظة
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      AppConstants.defaultBorderRadius,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppTheme.secondaryGreen,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'تأكد من إدخال رقم هاتف صحيح وفعال',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // زر الإرسال
                CustomButton(
                  text: _isLoading ? 'جاري الإرسال...' : 'إرسال رمز التحقق',
                  onPressed: _isLoading ? null : _sendOTP,
                  icon: Icons.send,
                ),
                const SizedBox(height: 24),

                // نوع الحساب المختار
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.isExistingUser
                          ? 'تسجيل دخول'
                          : 'نوع الحساب: ${_getUserTypeText(widget.userType ?? "donor")}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryRed,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getUserTypeText(String userType) {
    switch (userType) {
      case UserType.donor:
        return 'متبرع';
      case UserType.hospital:
        return 'مستشفى';
      case UserType.patient:
        return 'محتاج لدم';
      default:
        return userType;
    }
  }
}
