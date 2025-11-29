import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mahrah_blood_bank/config/theme.dart';
import 'package:mahrah_blood_bank/providers/auth_provider.dart';
import 'package:mahrah_blood_bank/providers/donor_provider.dart';
import 'package:mahrah_blood_bank/utils/constants.dart';

/// شاشة الملف الشخصي
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final donorProvider = Provider.of<DonorProvider>(context);
    final donor = donorProvider.currentDonor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // بطاقة المعلومات الشخصية
            _buildProfileCard(donor),
            const SizedBox(height: 16),

            // حالة التوفر (للمتبرعين فقط)
            if (donor != null) ...[
              _buildAvailabilityCard(context, donor),
              const SizedBox(height: 16),
            ],

            // الإعدادات والخيارات
            _buildSettingsSection(context),
            const SizedBox(height: 16),

            // معلومات التطبيق
            _buildAboutSection(context),
            const SizedBox(height: 16),

            // زر تسجيل الخروج
            _buildLogoutButton(context, authProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(donor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryRed, Color(0xFFE91E63)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryRed.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // الصورة الرمزية
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.person,
              size: 40,
              color: AppTheme.primaryRed,
            ),
          ),
          const SizedBox(height: 16),

          // الاسم
          Text(
            donor?.fullName ?? 'متبرع',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),

          // فصيلة الدم والمديرية
          if (donor != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.water_drop,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        donor.bloodType,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        donor.district,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvailabilityCard(BuildContext context, donor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            donor.isAvailable ? Icons.check_circle : Icons.cancel,
            color: donor.isAvailable
                ? AppTheme.secondaryGreen
                : AppTheme.textSecondary,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'حالة التوفر للتبرع',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  donor.isAvailable ? 'متاح للتبرع' : 'غير متاح حالياً',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: donor.isAvailable
                        ? AppTheme.secondaryGreen
                        : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: donor.isAvailable,
            onChanged: (value) async {
              final donorProvider =
                  Provider.of<DonorProvider>(context, listen: false);
              await donorProvider.updateAvailability(value);
            },
            activeThumbColor: AppTheme.secondaryGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.edit,
            title: 'تعديل الملف الشخصي',
            onTap: () {
              _showComingSoonDialog(context);
            },
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            icon: Icons.history,
            title: 'سجل التبرعات',
            onTap: () {
              _showComingSoonDialog(context);
            },
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            icon: Icons.notifications,
            title: 'الإشعارات',
            onTap: () {
              _showComingSoonDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.info,
            title: 'عن التطبيق',
            onTap: () {
              _showAboutDialog(context);
            },
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            icon: Icons.privacy_tip,
            title: 'سياسة الخصوصية',
            onTap: () {
              _showComingSoonDialog(context);
            },
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            icon: Icons.help,
            title: 'المساعدة والدعم',
            onTap: () {
              _showComingSoonDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryRed),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_back_ios,
        size: 16,
        color: AppTheme.textSecondary,
      ),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider authProvider) {
    return OutlinedButton.icon(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('تسجيل الخروج'),
            content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () {
                  authProvider.signOut();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/account-type',
                    (route) => false,
                  );
                },
                child: const Text(
                  'تسجيل الخروج',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
      icon: const Icon(Icons.logout, color: Colors.red),
      label: const Text(
        'تسجيل الخروج',
        style: TextStyle(color: Colors.red),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.red),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('قريباً'),
        content: const Text('هذه الميزة ستكون متاحة قريباً'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('عن التطبيق'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'بنك الدم - محافظة المهرة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('الإصدار: 1.0.0'),
            SizedBox(height: 16),
            Text(
              'تطبيق مجاني لربط المتبرعين بالدم مع المحتاجين في محافظة المهرة، اليمن.',
            ),
            SizedBox(height: 16),
            Text(
              'صُنع بـ ❤️ لأهالي المهرة',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }
}
