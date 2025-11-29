import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:mahrah_blood_bank/models/donor_model.dart';
import 'package:mahrah_blood_bank/providers/donor_provider.dart';
import 'package:mahrah_blood_bank/providers/auth_provider.dart';
import 'package:mahrah_blood_bank/utils/constants.dart';
import 'package:mahrah_blood_bank/utils/blood_types.dart';
import 'package:mahrah_blood_bank/services/supabase_service.dart';

/// شاشة تسجيل متبرع جديد
class DonorRegistrationScreen extends StatefulWidget {
  const DonorRegistrationScreen({super.key});

  @override
  State<DonorRegistrationScreen> createState() =>
      _DonorRegistrationScreenState();
}

class _DonorRegistrationScreenState extends State<DonorRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _telegramController = TextEditingController();

  // القيم المختارة
  String? _selectedBloodType;
  String? _selectedDistrict;
  String? _selectedGender;
  DateTime? _selectedBirthDate;
  bool _hasChronicDiseases = false;
  bool _hasWhatsapp = true;
  bool _hasTelegram = false;

  List<String> _districts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // تأخير تحميل المديريات حتى بعد اكتمال البناء
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDistricts();
    });
  }

  Future<void> _loadDistricts() async {
    final districts = await SupabaseService.getDistricts();
    if (mounted) {
      if (districts.isEmpty) {
        // استخدام القائمة الافتراضية من Constants
        setState(() {
          _districts = DISTRICTS;
        });
      } else {
        setState(() {
          _districts = districts;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل متبرع جديد'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // رسالة ترحيبية
                    Card(
                      color: Colors.red.shade50,
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(Icons.favorite, color: Colors.red, size: 48),
                            SizedBox(height: 8),
                            Text(
                              'شكراً لك على قرارك النبيل! 💙',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'تبرعك بالدم قد ينقذ حياة إنسان',
                              style: TextStyle(fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // الاسم الكامل
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'الاسم الكامل *',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'الرجاء إدخال الاسم الكامل';
                        }
                        if (value.trim().split(' ').length < 2) {
                          return 'الرجاء إدخال الاسم الكامل (الأول والأخير)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // فصيلة الدم
                    DropdownButtonFormField<String>(
                      initialValue: _selectedBloodType,
                      decoration: InputDecoration(
                        labelText: 'فصيلة الدم *',
                        prefixIcon:
                            const Icon(Icons.bloodtype, color: Colors.red),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: BLOOD_TYPES.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(
                            type,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedBloodType = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'الرجاء اختيار فصيلة الدم';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // المديرية
                    DropdownButtonFormField<String>(
                      initialValue: _selectedDistrict,
                      decoration: InputDecoration(
                        labelText: 'المديرية *',
                        prefixIcon: const Icon(Icons.location_on),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: _districts.map((district) {
                        return DropdownMenuItem(
                          value: district,
                          child: Text(district),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDistrict = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'الرجاء اختيار المديرية';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // تاريخ الميلاد
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime(2000),
                          firstDate: DateTime(1950),
                          lastDate: DateTime.now()
                              .subtract(const Duration(days: 365 * 18)),
                          locale: const Locale('ar'),
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedBirthDate = picked;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'تاريخ الميلاد *',
                          prefixIcon: const Icon(Icons.cake),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _selectedBirthDate != null
                              ? DateFormat('yyyy/MM/dd')
                                  .format(_selectedBirthDate!)
                              : 'اختر تاريخ الميلاد',
                          style: TextStyle(
                            color: _selectedBirthDate != null
                                ? Colors.black
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    if (_selectedBirthDate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, right: 16),
                        child: Text(
                          'العمر: ${_calculateAge(_selectedBirthDate!)} سنة',
                          style: TextStyle(
                            color: _calculateAge(_selectedBirthDate!) >= 18
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // الجنس
                    DropdownButtonFormField<String>(
                      initialValue: _selectedGender,
                      decoration: InputDecoration(
                        labelText: 'الجنس *',
                        prefixIcon: const Icon(Icons.wc),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'male', child: Text('ذكر')),
                        DropdownMenuItem(value: 'female', child: Text('أنثى')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'الرجاء اختيار الجنس';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // الوزن
                    TextFormField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'الوزن (كجم) *',
                        prefixIcon: const Icon(Icons.monitor_weight),
                        suffix: const Text('كجم'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال الوزن';
                        }
                        final weight = double.tryParse(value);
                        if (weight == null || weight < 50) {
                          return 'يجب أن يكون الوزن 50 كجم على الأقل';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // الأمراض المزمنة
                    Card(
                      child: CheckboxListTile(
                        title: const Text('هل تعاني من أمراض مزمنة؟'),
                        subtitle: const Text(
                          'مثل: السكري، الضغط، أمراض القلب، الكبد، الكلى',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: _hasChronicDiseases,
                        onChanged: (value) {
                          setState(() {
                            _hasChronicDiseases = value ?? false;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // وسائل التواصل
                    const Text(
                      'وسائل التواصل:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Card(
                      child: Column(
                        children: [
                          CheckboxListTile(
                            title: const Text('واتساب'),
                            subtitle: const Text('سنستخدم رقم هاتفك المسجل'),
                            secondary:
                                const Icon(Icons.phone, color: Colors.green),
                            value: _hasWhatsapp,
                            onChanged: (value) {
                              setState(() {
                                _hasWhatsapp = value ?? false;
                              });
                            },
                          ),
                          const Divider(height: 1),
                          CheckboxListTile(
                            title: const Text('تليجرام'),
                            secondary:
                                const Icon(Icons.telegram, color: Colors.blue),
                            value: _hasTelegram,
                            onChanged: (value) {
                              setState(() {
                                _hasTelegram = value ?? false;
                              });
                            },
                          ),
                          if (_hasTelegram)
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: TextFormField(
                                controller: _telegramController,
                                decoration: InputDecoration(
                                  labelText: 'اسم المستخدم في تليجرام',
                                  prefixText: '@',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // تحذير الأمراض المزمنة
                    if (_hasChronicDiseases)
                      Card(
                        color: Colors.orange.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(Icons.warning, color: Colors.orange),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'تنبيه: يُفضل استشارة الطبيب قبل التبرع',
                                  style:
                                      TextStyle(color: Colors.orange.shade900),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),

                    // زر التسجيل
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'تسجيل كمتبرع',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedBirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار تاريخ الميلاد')),
      );
      return;
    }

    final age = _calculateAge(_selectedBirthDate!);
    if (age < 18) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('عذراً، يجب أن يكون عمرك 18 سنة على الأقل'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final donorProvider = Provider.of<DonorProvider>(context, listen: false);

      final donor = DonorModel(
        id: const Uuid().v4(),
        userId: authProvider.currentUser!.id,
        fullName: _nameController.text.trim(),
        bloodType: _selectedBloodType!,
        district: _selectedDistrict!,
        birthDate: _selectedBirthDate,
        gender: _selectedGender,
        weight: double.parse(_weightController.text),
        hasChronicDiseases: _hasChronicDiseases,
        hasWhatsapp: _hasWhatsapp,
        hasTelegram: _hasTelegram,
        telegramUsername: _hasTelegram ? _telegramController.text.trim() : null,
        createdAt: DateTime.now(),
      );

      final success = await donorProvider.registerDonor(donor);

      if (success && mounted) {
        // نجح التسجيل
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 32),
                SizedBox(width: 12),
                Text('تم التسجيل بنجاح!'),
              ],
            ),
            content: const Text(
              'شكراً لك! أصبحت الآن متبرعاً مسجلاً في بنك الدم.\n\n'
              'سنرسل لك إشعاراً عند الحاجة لفصيلة دمك.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed('/donor-home');
                },
                child: const Text('الانتقال للصفحة الرئيسية'),
              ),
            ],
          ),
        );
      } else {
        throw Exception('فشل التسجيل');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _telegramController.dispose();
    super.dispose();
  }
}
