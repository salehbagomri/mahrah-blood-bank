import 'package:flutter/material.dart';
import 'package:mahrah_blood_bank/config/theme.dart';
import 'package:mahrah_blood_bank/utils/constants.dart';

/// شاشة اختيار نوع الدخول - مستخدم جديد أو لديه حساب
class AccountTypeScreen extends StatelessWidget {
  const AccountTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryRed.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // الشعار والعنوان
                _buildHeader(),

                const Spacer(),

                // الخيارات
                _buildOptions(context),

                const Spacer(),

                // نص توضيحي
                _buildFooterText(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// بناء الهيدر (الشعار والعنوان)
  Widget _buildHeader() {
    return Column(
      children: [
        // أيقونة قطرة الدم
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppTheme.primaryRed,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryRed.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.water_drop,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),

        // العنوان
        const Text(
          'بنك الدم - المهرة',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryRed,
          ),
        ),
        const SizedBox(height: 8),

        // الوصف
        const Text(
          'معاً ننقذ الأرواح',
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  /// بناء الخيارات
  Widget _buildOptions(BuildContext context) {
    return Column(
      children: [
        // خيار: لدي حساب
        _buildOptionCard(
          context: context,
          icon: Icons.login,
          title: 'لدي حساب',
          description: 'سجل دخول باستخدام رقم هاتفك',
          color: AppTheme.primaryRed,
          onTap: () {
            // الانتقال مباشرة لشاشة إدخال رقم الهاتف
            Navigator.pushNamed(
              context,
              '/phone-input',
              arguments: {'isExistingUser': true},
            );
          },
        ),

        const SizedBox(height: 20),

        // خيار: مستخدم جديد
        _buildOptionCard(
          context: context,
          icon: Icons.person_add,
          title: 'مستخدم جديد',
          description: 'أنشئ حساب جديد وانضم لعائلتنا',
          color: AppTheme.secondaryGreen,
          onTap: () {
            // الانتقال لشاشة اختيار نوع المستخدم
            Navigator.pushNamed(context, '/login');
          },
        ),
      ],
    );
  }

  /// بناء بطاقة خيار
  Widget _buildOptionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
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
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 30,
                color: color,
              ),
            ),
            const SizedBox(width: 20),

            // النص
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
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

            // سهم
            Icon(
              Icons.arrow_back_ios,
              color: color,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// بناء النص التوضيحي في الأسفل
  Widget _buildFooterText() {
    return const Column(
      children: [
        Text(
          'بانضمامك لبنك الدم، أنت تساهم في إنقاذ الأرواح',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
            height: 1.5,
          ),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite,
              size: 16,
              color: AppTheme.primaryRed,
            ),
            SizedBox(width: 8),
            Text(
              'كل قطرة دم تُنقذ حياة',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.primaryRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
