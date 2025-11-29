import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mahrah_blood_bank/config/theme.dart';
import 'package:mahrah_blood_bank/providers/auth_provider.dart';
import 'package:mahrah_blood_bank/providers/donor_provider.dart';
import 'package:mahrah_blood_bank/utils/constants.dart';

/// الشاشة الرئيسية للمتبرع
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadDonorData();
  }

  Future<void> _loadDonorData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final donorProvider = Provider.of<DonorProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      await donorProvider.loadDonorData(authProvider.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final donorProvider = Provider.of<DonorProvider>(context);
    final user = authProvider.currentUser;
    final donor = donorProvider.currentDonor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('بنك الدم - المهرة'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: فتح شاشة الإشعارات
            },
            tooltip: 'الإشعارات',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDonorData,
        child: donorProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // بطاقة الترحيب
                    _buildWelcomeCard(donor?.fullName ?? 'متبرع'),

                    const SizedBox(height: 16),

                    // بطاقة معلومات المتبرع
                    if (donor != null) ...[
                      _buildDonorInfoCard(donor),
                      const SizedBox(height: 16),
                    ],

                    // بطاقة حالة التبرع
                    if (donor != null) ...[
                      _buildDonationStatusCard(donor),
                      const SizedBox(height: 16),
                    ],

                    // الإحصائيات
                    if (donor != null) ...[
                      _buildStatisticsSection(donor),
                      const SizedBox(height: 16),
                    ],

                    // إجراءات سريعة
                    _buildQuickActions(),
                  ],
                ),
              ),
      ),
    );
  }

  /// بطاقة الترحيب
  Widget _buildWelcomeCard(String name) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'صباح الخير';
    } else if (hour < 17) {
      greeting = 'مساء الخير';
    } else {
      greeting = 'مساء الخير';
    }

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
            color: AppTheme.primaryRed.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                                      ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'شكراً لك على إنقاذ الأرواح 🩸',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                                      ),
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite,
              size: 30,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// بطاقة معلومات المتبرع
  Widget _buildDonorInfoCard(donor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'معلوماتك الأساسية',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
                          ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.water_drop,
                  label: 'فصيلة الدم',
                  value: donor.bloodType,
                  color: AppTheme.primaryRed,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.location_on,
                  label: 'المديرية',
                  value: donor.district,
                  color: AppTheme.secondaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.cake,
                  label: 'العمر',
                  value: donor.age != null ? '${donor.age} سنة' : 'غير محدد',
                  color: Colors.orange,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.monitor_weight,
                  label: 'الوزن',
                  value: donor.weight != null ? '${donor.weight} كجم' : 'غير محدد',
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
                      ),
        ),
      ],
    );
  }

  /// بطاقة حالة التبرع
  Widget _buildDonationStatusCard(donor) {
    final canDonate = donor.canDonate;
    final daysUntilNext = donor.daysUntilNextDonation;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: canDonate
            ? AppTheme.secondaryGreen.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(
          color: canDonate ? AppTheme.secondaryGreen : Colors.orange,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            canDonate ? Icons.check_circle : Icons.schedule,
            size: 48,
            color: canDonate ? AppTheme.secondaryGreen : Colors.orange,
          ),
          const SizedBox(height: 12),
          Text(
            canDonate ? 'جاهز للتبرع!' : 'غير جاهز للتبرع حالياً',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: canDonate ? AppTheme.secondaryGreen : Colors.orange,
                          ),
          ),
          const SizedBox(height: 8),
          Text(
            canDonate
                ? 'يمكنك التبرع بالدم الآن'
                : daysUntilNext != null
                    ? 'يمكنك التبرع بعد $daysUntilNext يوم'
                    : 'تحقق من شروط التبرع',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
                          ),
          ),
          if (!canDonate && !donor.isAvailable) ...[
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final donorProvider =
                    Provider.of<DonorProvider>(context, listen: false);
                await donorProvider.updateAvailability(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryGreen,
              ),
              child: const Text(
                'تفعيل حالة التوفر',
                style: TextStyle(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// قسم الإحصائيات
  Widget _buildStatisticsSection(donor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'إحصائياتك',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
                      ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.water_drop,
                label: 'عدد التبرعات',
                value: '${donor.donationCount}',
                color: AppTheme.primaryRed,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.people,
                label: 'أرواح تم إنقاذها',
                value: '${donor.donationCount * 3}',
                color: AppTheme.secondaryGreen,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
                          ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
                          ),
          ),
        ],
      ),
    );
  }

  /// الإجراءات السريعة
  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'إجراءات سريعة',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
                      ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.search,
                label: 'ابحث عن متبرعين',
                color: AppTheme.primaryRed,
                onTap: () {
                  // سيتم التنقل عبر Bottom Navigation
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.add_circle,
                label: 'طلب دم جديد',
                color: AppTheme.secondaryGreen,
                onTap: () {
                  // سيتم التنقل عبر Bottom Navigation
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          border: Border.all(color: color, width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
                              ),
            ),
          ],
        ),
      ),
    );
  }
}
