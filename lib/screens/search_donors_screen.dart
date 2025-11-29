import 'package:flutter/material.dart';
import 'package:mahrah_blood_bank/config/theme.dart';
import 'package:mahrah_blood_bank/widgets/custom_dropdown.dart';
import 'package:mahrah_blood_bank/utils/constants.dart';
import 'package:mahrah_blood_bank/utils/blood_types.dart';

/// شاشة البحث عن المتبرعين
class SearchDonorsScreen extends StatefulWidget {
  const SearchDonorsScreen({super.key});

  @override
  State<SearchDonorsScreen> createState() => _SearchDonorsScreenState();
}

class _SearchDonorsScreenState extends State<SearchDonorsScreen> {
  String? _selectedBloodType;
  String? _selectedDistrict;
  bool _isSearching = false;
  List<dynamic> _searchResults = [];

  Future<void> _searchDonors() async {
    if (_selectedBloodType == null && _selectedDistrict == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'الرجاء اختيار فصيلة الدم أو المديرية على الأقل',
            style: TextStyle(),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      // TODO: تنفيذ البحث الفعلي من قاعدة البيانات
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _searchResults = []; // سيتم ملؤها من قاعدة البيانات
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ: ${e.toString()}',
            style: const TextStyle(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedBloodType = null;
      _selectedDistrict = null;
      _searchResults = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('البحث عن متبرعين'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // قسم الفلترة
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // فصيلة الدم
                CustomDropdown(
                  label: 'فصيلة الدم',
                  hint: 'اختر فصيلة الدم المطلوبة',
                  icon: Icons.water_drop,
                  value: _selectedBloodType,
                  items: BloodTypes.allTypes,
                  onChanged: (value) {
                    setState(() {
                      _selectedBloodType = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // المديرية
                CustomDropdown(
                  label: 'المديرية',
                  hint: 'اختر المديرية',
                  icon: Icons.location_on,
                  value: _selectedDistrict,
                  items: Districts.allDistricts,
                  onChanged: (value) {
                    setState(() {
                      _selectedDistrict = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // أزرار البحث والمسح
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _isSearching ? null : _searchDonors,
                        icon: _isSearching
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(Icons.search),
                        label: Text(
                          _isSearching ? 'جاري البحث...' : 'بحث',
                          style: const TextStyle(),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.defaultBorderRadius,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _clearFilters,
                        icon: const Icon(Icons.clear),
                        label: const Text(
                          'مسح',
                          style: TextStyle(),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textSecondary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.defaultBorderRadius,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // النتائج
          Expanded(
            child: _buildResultsSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection() {
    if (_searchResults.isEmpty && !_isSearching) {
      return _buildEmptyState();
    }

    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final donor = _searchResults[index];
        return _buildDonorCard(donor);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'ابحث عن متبرعين',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
                              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'اختر فصيلة الدم والمديرية للبحث عن متبرعين متاحين',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonorCard(dynamic donor) {
    // TODO: استخدام DonorModel الفعلي
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.primaryRed.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.person,
                    color: AppTheme.primaryRed,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'اسم المتبرع', // TODO: استخدام الاسم الفعلي
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                                              ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryRed,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'A+', // TODO: استخدام الفصيلة الفعلية
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                                                          ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'الغيضة', // TODO: استخدام المديرية الفعلية
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
                  color: AppTheme.secondaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'متاح',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryGreen,
                                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: فتح تطبيق الهاتف
                  },
                  icon: const Icon(Icons.phone, size: 18),
                  label: const Text(
                    'اتصال',
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
                    // TODO: فتح واتساب
                  },
                  icon: const Icon(Icons.chat, size: 18),
                  label: const Text(
                    'واتساب',
                    style: TextStyle(),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
