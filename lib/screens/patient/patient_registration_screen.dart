import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mahrah_blood_bank/config/theme.dart';
import 'package:mahrah_blood_bank/providers/auth_provider.dart';
import 'package:mahrah_blood_bank/providers/patient_provider.dart';
import 'package:mahrah_blood_bank/utils/constants.dart';
import 'package:mahrah_blood_bank/utils/blood_types.dart';
import 'package:mahrah_blood_bank/widgets/custom_button.dart';
import 'package:mahrah_blood_bank/widgets/custom_text_field.dart';
import 'package:mahrah_blood_bank/widgets/custom_dropdown.dart';

/// شاشة تسجيل المريض (اختيارية)
class PatientRegistrationScreen extends StatefulWidget {
  final String phoneNumber;

  const PatientRegistrationScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<PatientRegistrationScreen> createState() =>
      _PatientRegistrationScreenState();
}

class _PatientRegistrationScreenState extends State<PatientRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  String? _selectedGender;
  String? _selectedBloodType;
  String? _selectedDistrict;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _phoneController.text = widget.phoneNumber;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final patientProvider =
          Provider.of<PatientProvider>(context, listen: false);

      if (authProvider.currentUser == null) {
        _showError('خطأ: لم يتم العثور على المستخدم');
        return;
      }

      final success = await patientProvider.registerPatient(
        userId: authProvider.currentUser!.id,
        fullName: _nameController.text.trim(),
        age: int.parse(_ageController.text),
        gender: _selectedGender!,
        bloodType: _selectedBloodType!,
        district: _selectedDistrict!,
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
      );

      if (mounted) {
        if (success) {
          _showSuccess('تم حفظ معلوماتك بنجاح!');
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/home',
              (route) => false,
            );
          }
        } else {
          _showError(patientProvider.errorMessage ?? 'فشل حفظ البيانات');
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('حدث خطأ أثناء الحفظ');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حفظ معلوماتك'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          children: [
            const SizedBox(height: 16),

            // رسالة توضيحية
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'احفظ معلوماتك لتسهيل الطلبات المستقبلية',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // الاسم الكامل
            CustomTextField(
              controller: _nameController,
              label: 'الاسم الكامل',
              hint: 'أدخل اسمك الكامل',
              icon: Icons.person,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال الاسم';
                }
                if (value.length < 3) {
                  return 'الاسم يجب أن يكون 3 أحرف على الأقل';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // العمر
            CustomTextField(
              controller: _ageController,
              label: 'العمر',
              hint: 'أدخل عمرك',
              icon: Icons.cake,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال العمر';
                }
                final age = int.tryParse(value);
                if (age == null || age < 1 || age > 120) {
                  return 'الرجاء إدخال عمر صحيح (1-120)';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // الجنس
            CustomDropdown(
              label: 'الجنس',
              hint: 'اختر الجنس',
              icon: Icons.wc,
              value: _selectedGender == 'male'
                  ? 'ذكر'
                  : _selectedGender == 'female'
                      ? 'أنثى'
                      : null,
              items: const ['ذكر', 'أنثى'],
              onChanged: (value) {
                setState(() {
                  _selectedGender = value == 'ذكر' ? 'male' : 'female';
                });
              },
            ),

            const SizedBox(height: 16),

            // فصيلة الدم
            CustomDropdown(
              label: 'فصيلة الدم',
              hint: 'اختر فصيلة الدم',
              icon: Icons.bloodtype,
              value: _selectedBloodType,
              items: BLOOD_TYPES,
              onChanged: (value) {
                setState(() => _selectedBloodType = value);
              },
            ),

            const SizedBox(height: 16),

            // المديرية
            CustomDropdown(
              label: 'المديرية',
              hint: 'اختر المديرية',
              icon: Icons.location_city,
              value: _selectedDistrict,
              items: DISTRICTS,
              onChanged: (value) {
                setState(() => _selectedDistrict = value);
              },
            ),

            const SizedBox(height: 16),

            // رقم التواصل
            CustomTextField(
              controller: _phoneController,
              label: 'رقم التواصل',
              hint: 'رقم الهاتف',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 16),

            // العنوان (اختياري)
            CustomTextField(
              controller: _addressController,
              label: 'العنوان (اختياري)',
              hint: 'أدخل عنوانك',
              icon: Icons.location_on,
              maxLines: 2,
            ),

            const SizedBox(height: 32),

            // زر الحفظ
            CustomButton(
              text: 'حفظ معلوماتي',
              onPressed: _register,
              isLoading: _isLoading,
            ),

            const SizedBox(height: 16),

            // زر التخطي
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/home',
                        (route) => false,
                      );
                    },
              child: const Text('تخطي - سأسجل لاحقاً'),
            ),
          ],
        ),
      ),
    );
  }
}
