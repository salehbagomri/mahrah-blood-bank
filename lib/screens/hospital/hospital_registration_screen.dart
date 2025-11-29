import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/hospital_model.dart';
import '../../providers/hospital_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';

class HospitalRegistrationScreen extends StatefulWidget {
  const HospitalRegistrationScreen({super.key});

  @override
  State<HospitalRegistrationScreen> createState() =>
      _HospitalRegistrationScreenState();
}

class _HospitalRegistrationScreenState
    extends State<HospitalRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supabaseService = SupabaseService();

  final _hospitalNameController = TextEditingController();
  final _contactPersonController = TextEditingController();

  String? _selectedDistrict;
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
        title: const Text('تسجيل مستشفى/مركز صحي'),
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
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Icon(Icons.local_hospital,
                                color: Colors.blue, size: 48),
                            const SizedBox(height: 12),
                            const Text(
                              'تسجيل مؤسسة صحية',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'سيتم مراجعة طلبك من قبل الإدارة قبل الموافقة',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey.shade700),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // اسم المستشفى
                    TextFormField(
                      controller: _hospitalNameController,
                      decoration: InputDecoration(
                        labelText: 'اسم المستشفى/المركز الصحي *',
                        prefixIcon: const Icon(Icons.business),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: 'مثال: مستشفى الغيضة العام',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'الرجاء إدخال اسم المستشفى';
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

                    // اسم الشخص المسؤول
                    TextFormField(
                      controller: _contactPersonController,
                      decoration: InputDecoration(
                        labelText: 'اسم الشخص المسؤول *',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: 'الاسم الكامل للشخص المسؤول',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'الرجاء إدخال اسم المسؤول';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // ملاحظة
                    Card(
                      color: Colors.orange.shade50,
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.info, color: Colors.orange),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'سيتم التواصل معك على رقم الهاتف المسجل للتحقق من المعلومات',
                                style: TextStyle(fontSize: 13),
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
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'إرسال طلب التسجيل',
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
      final hospitalProvider =
          Provider.of<HospitalProvider>(context, listen: false);

      final hospital = HospitalModel(
        id: const Uuid().v4(),
        userId: authProvider.currentUser!.id,
        hospitalName: _hospitalNameController.text.trim(),
        district: _selectedDistrict!,
        contactPerson: _contactPersonController.text.trim(),
        isVerified: false, // سيتم الموافقة من الإدارة
        createdAt: DateTime.now(),
      );

      final success = await hospitalProvider.registerHospital(hospital);

      if (success && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.pending, color: Colors.orange, size: 32),
                SizedBox(width: 12),
                Text('تم إرسال الطلب'),
              ],
            ),
            content: const Text(
              'شكراً لك! تم إرسال طلب التسجيل بنجاح.\n\n'
              'سيتم مراجعة طلبك من قبل الإدارة والتواصل معك قريباً.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('حسناً'),
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
    _hospitalNameController.dispose();
    _contactPersonController.dispose();
    super.dispose();
  }
}
