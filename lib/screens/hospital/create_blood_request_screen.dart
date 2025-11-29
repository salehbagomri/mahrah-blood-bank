import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/blood_request_model.dart';
import '../../providers/blood_request_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/patient_provider.dart';
import '../../utils/blood_types.dart';
import '../../services/supabase_service.dart';
import '../common/donors_list_screen.dart';

class CreateBloodRequestScreen extends StatefulWidget {
  final String requesterType; // 'hospital' or 'patient'

  const CreateBloodRequestScreen({
    super.key,
    required this.requesterType,
  });

  @override
  State<CreateBloodRequestScreen> createState() =>
      _CreateBloodRequestScreenState();
}

class _CreateBloodRequestScreenState extends State<CreateBloodRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supabaseService = SupabaseService();

  final _patientNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedBloodType;
  String? _selectedDistrict;
  String _urgencyLevel = 'normal';
  List<String> _districts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDistricts();
    });
  }

  Future<void> _loadDistricts() async {
    final districts = await SupabaseService.getDistricts();
    if (mounted) {
      setState(() {
        _districts = districts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلب دم جديد'),
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
                    // رسالة توضيحية
                    Card(
                      color: Colors.red.shade50,
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.bloodtype, color: Colors.red, size: 32),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'سنقوم بإشعار جميع المتبرعين المتطابقين في منطقتك',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // فصيلة الدم
                    DropdownButtonFormField<String>(
                      initialValue: _selectedBloodType,
                      decoration: InputDecoration(
                        labelText: 'فصيلة الدم المطلوبة *',
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

                    // اسم المريض
                    TextFormField(
                      controller: _patientNameController,
                      decoration: InputDecoration(
                        labelText: 'اسم المريض *',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'الرجاء إدخال اسم المريض';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // درجة الإلحاح
                    Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'درجة الإلحاح *',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          RadioListTile<String>(
                            title: const Text('عادي'),
                            subtitle: const Text('الحاجة غير عاجلة'),
                            value: 'normal',
                            groupValue: _urgencyLevel,
                            onChanged: (value) {
                              setState(() {
                                _urgencyLevel = value!;
                              });
                            },
                          ),
                          RadioListTile<String>(
                            title: const Text('عاجل',
                                style: TextStyle(color: Colors.red)),
                            subtitle: const Text('الحاجة عاجلة جداً'),
                            value: 'urgent',
                            groupValue: _urgencyLevel,
                            onChanged: (value) {
                              setState(() {
                                _urgencyLevel = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // الوصف
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'وصف الحالة (اختياري)',
                        prefixIcon: const Icon(Icons.description),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: 'أي تفاصيل إضافية عن الحالة...',
                      ),
                    ),
                    const SizedBox(height: 24),

                    // تحذير العاجل
                    if (_urgencyLevel == 'urgent')
                      Card(
                        color: Colors.red.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(Icons.warning, color: Colors.red),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'سيتم إشعار المتبرعين في المديريات المجاورة أيضاً',
                                  style: TextStyle(color: Colors.red.shade900),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),

                    // زر الإرسال
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
                        'إرسال الطلب',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final requestProvider =
          Provider.of<BloodRequestProvider>(context, listen: false);

      final request = BloodRequestModel(
        id: const Uuid().v4(),
        requesterId: authProvider.currentUser!.id,
        requesterType: widget.requesterType,
        bloodType: _selectedBloodType!,
        district: _selectedDistrict!,
        urgencyLevel: _urgencyLevel,
        patientName: _patientNameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        createdAt: DateTime.now(),
      );

      final success = await requestProvider.createRequest(request);

      if (success && mounted) {
        // عرض المتبرعين المتطابقين
        await requestProvider.findMatchingDonors(
          _selectedBloodType!,
          _selectedDistrict!,
        );

        if (mounted) {
          Navigator.of(context).pop();

          // إذا كان المستخدم patient، تحقق من التسجيل
          if (widget.requesterType == 'patient') {
            final patientProvider =
                Provider.of<PatientProvider>(context, listen: false);

            // تحميل بيانات المريض
            if (authProvider.currentUser != null) {
              await patientProvider
                  .loadPatientData(authProvider.currentUser!.id);
            }

            // إذا لم يكن مسجلاً، اعرض dialog التسجيل الاختياري
            if (patientProvider.currentPatient == null) {
              _showOptionalRegistrationDialog();
              return;
            }
          }

          // عرض المتبرعين المتطابقين
          showDialog(
            context: context,
            builder: (context) => _MatchingDonorsDialog(
              bloodType: _selectedBloodType!,
              district: _selectedDistrict!,
            ),
          );
        }
      } else {
        throw Exception('فشل إنشاء الطلب');
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

  void _showOptionalRegistrationDialog() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final phoneNumber = authProvider.currentUser?.phone ?? '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Expanded(child: Text('تم إنشاء الطلب بنجاح!')),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('طلبك قيد المعالجة وسنتواصل معك قريباً.'),
            SizedBox(height: 16),
            Text(
              'هل تريد حفظ معلوماتك لتسهيل الطلبات المستقبلية؟',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/home',
                (route) => false,
              );
            },
            child: const Text('لا، شكراً'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(
                context,
                '/patient-registration',
                arguments: phoneNumber,
              );
            },
            child: const Text('نعم، احفظ معلوماتي'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

// Dialog لعرض المتبرعين المتطابقين
class _MatchingDonorsDialog extends StatelessWidget {
  final String bloodType;
  final String district;

  const _MatchingDonorsDialog({
    required this.bloodType,
    required this.district,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<BloodRequestProvider>(
      builder: (context, provider, child) {
        final donors = provider.matchingDonors;

        return AlertDialog(
          title: const Text('تم إنشاء الطلب بنجاح! ✅'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'تم العثور على ${donors.length} متبرع متطابق',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (donors.isEmpty)
                  const Text(
                    'لا يوجد متبرعين متاحين حالياً في منطقتك.\n\n'
                    'سيتم إشعارك عند توفر متبرعين.',
                    textAlign: TextAlign.center,
                  )
                else
                  const Text(
                    'تم إرسال إشعارات لجميع المتبرعين المتطابقين',
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
          actions: [
            if (donors.isNotEmpty)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DonorsListScreen(
                        donors: donors,
                        bloodType: bloodType,
                      ),
                    ),
                  );
                },
                child: const Text('عرض المتبرعين'),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('حسناً'),
            ),
          ],
        );
      },
    );
  }
}
