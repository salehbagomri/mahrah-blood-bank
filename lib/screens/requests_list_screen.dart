import 'package:flutter/material.dart';
import 'package:mahrah_blood_bank/config/theme.dart';
import 'package:mahrah_blood_bank/utils/constants.dart';

/// شاشة عرض طلبات الدم
class RequestsListScreen extends StatefulWidget {
  const RequestsListScreen({super.key});

  @override
  State<RequestsListScreen> createState() => _RequestsListScreenState();
}

class _RequestsListScreenState extends State<RequestsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<dynamic> _activeRequests = [];
  List<dynamic> _completedRequests = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: تحميل الطلبات من قاعدة البيانات
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _activeRequests = []; // سيتم ملؤها من قاعدة البيانات
        _completedRequests = [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلبات الدم'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryRed,
          labelColor: AppTheme.primaryRed,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(
              icon: Icon(Icons.pending_actions),
              text: 'الطلبات النشطة',
            ),
            Tab(
              icon: Icon(Icons.check_circle),
              text: 'المكتملة',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRequestsList(_activeRequests, isActive: true),
          _buildRequestsList(_completedRequests, isActive: false),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: فتح شاشة إنشاء طلب جديد
          _showCreateRequestDialog();
        },
        backgroundColor: AppTheme.primaryRed,
        icon: const Icon(Icons.add),
        label: const Text(
          'طلب جديد',
          style: TextStyle(),
        ),
      ),
    );
  }

  Widget _buildRequestsList(List<dynamic> requests, {required bool isActive}) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (requests.isEmpty) {
      return _buildEmptyState(isActive);
    }

    return RefreshIndicator(
      onRefresh: _loadRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return _buildRequestCard(request, isActive: isActive);
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isActive) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.inbox : Icons.check_circle_outline,
              size: 80,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              isActive ? 'لا توجد طلبات نشطة' : 'لا توجد طلبات مكتملة',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
                              ),
            ),
            const SizedBox(height: 8),
            Text(
              isActive
                  ? 'اضغط على زر "طلب جديد" لإنشاء طلب دم'
                  : 'الطلبات المكتملة ستظهر هنا',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(dynamic request, {required bool isActive}) {
    // TODO: استخدام RequestModel الفعلي
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(
          color: isActive ? AppTheme.primaryRed : AppTheme.secondaryGreen,
          width: 2,
        ),
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
          // الرأس
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryRed,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'A+', // TODO: استخدام الفصيلة الفعلية
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                                      ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مطلوب متبرع بالدم',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                                              ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppTheme.textSecondary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'منذ ساعتين', // TODO: استخدام الوقت الفعلي
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                                                      ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.warning,
                      size: 14,
                      color: Colors.red,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'عاجل',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                                              ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),

          // التفاصيل
          _buildDetailRow(
            icon: Icons.local_hospital,
            label: 'المستشفى',
            value: 'مستشفى الغيضة العام', // TODO: استخدام القيمة الفعلية
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            icon: Icons.location_on,
            label: 'المديرية',
            value: 'الغيضة', // TODO: استخدام القيمة الفعلية
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            icon: Icons.person,
            label: 'مقدم الطلب',
            value: 'أحمد محمد', // TODO: استخدام القيمة الفعلية
          ),

          if (isActive) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: عرض تفاصيل الطلب
                    },
                    icon: const Icon(Icons.info_outline, size: 18),
                    label: const Text(
                      'التفاصيل',
                      style: TextStyle(),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryRed,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: الاستجابة للطلب
                    },
                    icon: const Icon(Icons.phone, size: 18),
                    label: const Text(
                      'استجب',
                      style: TextStyle(),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryGreen,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
                      ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
                          ),
          ),
        ),
      ],
    );
  }

  void _showCreateRequestDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'قريباً',
          style: TextStyle(),
        ),
        content: const Text(
          'سيتم إضافة ميزة إنشاء طلب دم جديد قريباً',
          style: TextStyle(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'حسناً',
              style: TextStyle(),
            ),
          ),
        ],
      ),
    );
  }
}
