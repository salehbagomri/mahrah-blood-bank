import 'package:flutter/material.dart';
import 'package:mahrah_blood_bank/config/theme.dart';
import 'package:mahrah_blood_bank/widgets/custom_button.dart';
import 'package:mahrah_blood_bank/utils/constants.dart';

/// شاشة تسجيل الدخول
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? _selectedUserType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مرحباً بك'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              // العنوان
              const Text(
                'اختر نوع الحساب',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // الوصف
              const Text(
                'اختر نوع حسابك للمتابعة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              // بطاقات اختيار نوع الحساب
              Expanded(
                child: ListView(
                  children: [
                    _buildUserTypeCard(
                      type: UserType.donor,
                      icon: Icons.water_drop,
                      title: 'متبرع',
                      description: 'أريد التبرع بالدم ومساعدة المحتاجين',
                      color: AppTheme.primaryRed,
                    ),
                    const SizedBox(height: 16),
                    _buildUserTypeCard(
                      type: UserType.hospital,
                      icon: Icons.local_hospital,
                      title: 'مستشفى / مركز صحي',
                      description: 'نحتاج إلى متبرعين بالدم لمرضانا',
                      color: AppTheme.secondaryGreen,
                    ),
                    const SizedBox(height: 16),
                    _buildUserTypeCard(
                      type: UserType.patient,
                      icon: Icons.person,
                      title: 'محتاج لدم',
                      description: 'أبحث عن متبرع بالدم',
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),

              // زر المتابعة
              CustomButton(
                text: 'متابعة',
                onPressed: _selectedUserType != null
                    ? () {
                        _showPhoneInputDialog();
                      }
                    : null,
                icon: Icons.arrow_back,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeCard({
    required String type,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    final isSelected = _selectedUserType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedUserType = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          border: Border.all(
            color: isSelected ? color : AppTheme.dividerColor,
            width: isSelected ? 3 : 1,
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
            // الأيقونة
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(width: 16),

            // النص
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // علامة الاختيار
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }

  void _showPhoneInputDialog() {
    // الانتقال لشاشة إدخال رقم الهاتف
    Navigator.pushNamed(
      context,
      '/phone-input',
      arguments: {
        'userType': _selectedUserType!,
        'isExistingUser': false,
      },
    );
  }
}
