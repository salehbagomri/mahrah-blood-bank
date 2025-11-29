import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mahrah_blood_bank/providers/donor_provider.dart';
import 'package:mahrah_blood_bank/providers/auth_provider.dart';
import 'package:mahrah_blood_bank/models/donor_model.dart';

/// الصفحة الرئيسية للمتبرع
class DonorHomeScreen extends StatefulWidget {
  const DonorHomeScreen({super.key});

  @override
  State<DonorHomeScreen> createState() => _DonorHomeScreenState();
}

class _DonorHomeScreenState extends State<DonorHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DonorDashboardTab(),
    DonorRequestsTab(),
    DonorHistoryTab(),
    DonorProfileTab(),
  ];

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
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notification_important),
            label: 'الطلبات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'السجل',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'الملف الشخصي',
          ),
        ],
      ),
    );
  }
}

// التبويب الأول: لوحة المعلومات
class DonorDashboardTab extends StatelessWidget {
  const DonorDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DonorProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final donor = provider.currentDonor;
        if (donor == null) {
          return const Center(child: Text('لا توجد بيانات'));
        }

        return CustomScrollView(
          slivers: [
            // AppBar
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text('مرحباً ${donor.fullName.split(' ').first}'),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red, Colors.red.shade700],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.favorite,
                      size: 80,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // بطاقة معلومات المتبرع
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // فصيلة الدم - كبيرة
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              donor.bloodType,
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'فصيلة دمك',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // الإحصائيات
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                icon: Icons.favorite,
                                label: 'التبرعات',
                                value: '${donor.donationCount}',
                                color: Colors.red,
                              ),
                              _buildStatItem(
                                icon: Icons.location_on,
                                label: 'المديرية',
                                value: donor.district,
                                color: Colors.blue,
                              ),
                              _buildStatItem(
                                icon: Icons.cake,
                                label: 'العمر',
                                value: '${donor.age ?? 0}',
                                color: Colors.green,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // حالة التوفر
                  Card(
                    color: donor.isAvailable
                        ? Colors.green.shade50
                        : Colors.grey.shade200,
                    child: SwitchListTile(
                      title: Text(
                        donor.isAvailable ? 'متاح للتبرع' : 'غير متاح حالياً',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        donor.isAvailable
                            ? 'سنرسل لك إشعاراً عند الحاجة'
                            : 'لن تصلك إشعارات الطلبات',
                      ),
                      value: donor.isAvailable,
                      onChanged: (value) {
                        provider.updateAvailability(value);
                      },
                      activeThumbColor: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // حالة التبرع
                  _buildDonationStatusCard(donor),
                  const SizedBox(height: 16),

                  // نصائح سريعة
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.lightbulb, color: Colors.blue),
                              SizedBox(width: 8),
                              Text(
                                'نصائح للمتبرع',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildTipItem('اشرب الكثير من الماء قبل التبرع'),
                          _buildTipItem('تناول وجبة خفيفة قبل التبرع'),
                          _buildTipItem('نم جيداً في الليلة السابقة'),
                          _buildTipItem('أحضر بطاقة الهوية معك'),
                        ],
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildDonationStatusCard(DonorModel donor) {
    if (!donor.canDonate) {
      final daysRemaining = donor.daysUntilNextDonation ?? 0;
      return Card(
        color: Colors.orange.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(Icons.schedule, color: Colors.orange, size: 48),
              const SizedBox(height: 12),
              const Text(
                'يمكنك التبرع بعد',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                '$daysRemaining يوم',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'يجب الانتظار 90 يوماً بين كل تبرع',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 48),
            const SizedBox(height: 12),
            Text(
              'أنت جاهز للتبرع! 💪',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'شكراً لك على استعدادك لإنقاذ الأرواح',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 16, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

// التبويب الثاني: الطلبات
class DonorRequestsTab extends StatelessWidget {
  const DonorRequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلبات الدم'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 100, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'لا توجد طلبات حالياً',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'سنرسل لك إشعاراً عند الحاجة لدمك',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// التبويب الثالث: السجل
class DonorHistoryTab extends StatelessWidget {
  const DonorHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل التبرعات'),
        centerTitle: true,
      ),
      body: Consumer<DonorProvider>(
        builder: (context, provider, child) {
          final donor = provider.currentDonor;
          if (donor == null) {
            return const Center(child: Text('لا توجد بيانات'));
          }

          if (donor.donationCount == 0) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 100, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'لم تتبرع بعد',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'ستظهر تبرعاتك هنا',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // إحصائية عامة
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'عدد تبرعاتك',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${donor.donationCount}',
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'شكراً لك! ❤️',
                        style: TextStyle(fontSize: 16),
                      ),
                      if (donor.lastDonationDate != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          'آخر تبرع: ${_formatDate(donor.lastDonationDate!)}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // شهادة تقدير
              if (donor.donationCount >= 3)
                Card(
                  color: Colors.amber.shade50,
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Icons.emoji_events, color: Colors.amber, size: 48),
                        SizedBox(height: 12),
                        Text(
                          'متبرع مميز! 🏆',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'أنت بطل حقيقي! شكراً على مساهماتك',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }
}

// التبويب الرابع: الملف الشخصي
class DonorProfileTab extends StatelessWidget {
  const DonorProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DonorProvider>(
      builder: (context, provider, child) {
        final donor = provider.currentDonor;
        if (donor == null) {
          return const Center(child: Text('لا توجد بيانات'));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 20),
            // صورة المتبرع
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.red.shade100,
                child: Text(
                  donor.fullName[0],
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              donor.fullName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              donor.district,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // المعلومات الشخصية
            Card(
              child: Column(
                children: [
                  _buildInfoTile(
                    icon: Icons.bloodtype,
                    label: 'فصيلة الدم',
                    value: donor.bloodType,
                    color: Colors.red,
                  ),
                  const Divider(height: 1),
                  _buildInfoTile(
                    icon: Icons.cake,
                    label: 'العمر',
                    value: '${donor.age ?? 0} سنة',
                    color: Colors.blue,
                  ),
                  const Divider(height: 1),
                  _buildInfoTile(
                    icon: Icons.wc,
                    label: 'الجنس',
                    value: donor.gender == 'male' ? 'ذكر' : 'أنثى',
                    color: Colors.purple,
                  ),
                  const Divider(height: 1),
                  _buildInfoTile(
                    icon: Icons.monitor_weight,
                    label: 'الوزن',
                    value: '${donor.weight ?? 0} كجم',
                    color: Colors.green,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // وسائل التواصل
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'وسائل التواصل',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (donor.hasWhatsapp)
                    const ListTile(
                      leading: Icon(Icons.phone, color: Colors.green),
                      title: Text('واتساب'),
                      trailing: Icon(Icons.check_circle, color: Colors.green),
                    ),
                  if (donor.hasTelegram)
                    ListTile(
                      leading: const Icon(Icons.telegram, color: Colors.blue),
                      title: const Text('تليجرام'),
                      subtitle: Text('@${donor.telegramUsername ?? ""}'),
                      trailing: const Icon(Icons.check_circle, color: Colors.green),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // زر تسجيل الخروج
            OutlinedButton.icon(
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
                          final authProvider = Provider.of<AuthProvider>(context, listen: false);
                          authProvider.signOut();
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/login',
                            (route) => false,
                          );
                        },
                        child: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label),
      trailing: Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
