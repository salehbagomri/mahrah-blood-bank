import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/donor_model.dart';

class DonorsListScreen extends StatelessWidget {
  final List<DonorModel> donors;
  final String bloodType;

  const DonorsListScreen({
    super.key,
    required this.donors,
    required this.bloodType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المتبرعون المتاحون'),
        centerTitle: true,
      ),
      body: donors.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 100, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'لا يوجد متبرعين متاحين حالياً',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: donors.length,
              itemBuilder: (context, index) {
                final donor = donors[index];
                return _DonorCard(donor: donor);
              },
            ),
    );
  }
}

class _DonorCard extends StatelessWidget {
  final DonorModel donor;

  const _DonorCard({required this.donor});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // فصيلة الدم
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    donor.bloodType,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        donor.fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            donor.district,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // حالة التوفر
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'متاح',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // معلومات إضافية
            Row(
              children: [
                _buildInfoChip(
                  icon: Icons.favorite,
                  label: '${donor.donationCount} تبرع',
                  color: Colors.red,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  icon: Icons.cake,
                  label: '${donor.age ?? 0} سنة',
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // أزرار التواصل
            Row(
              children: [
                // زر الاتصال
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _makePhoneCall(donor.userId),
                    icon: const Icon(Icons.phone),
                    label: const Text('اتصال'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // زر واتساب
                if (donor.hasWhatsapp)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _openWhatsApp(donor.userId),
                      icon: const Icon(Icons.message),
                      label: const Text('واتساب'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                // زر تليجرام
                if (donor.hasTelegram && donor.telegramUsername != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _openTelegram(donor.telegramUsername!),
                      icon: const Icon(Icons.send),
                      label: const Text('تليجرام'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _openWhatsApp(String phone) async {
    // إزالة أي رموز أو مسافات
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri whatsappUri = Uri.parse('https://wa.me/$cleanPhone');
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openTelegram(String username) async {
    final Uri telegramUri = Uri.parse('https://t.me/$username');
    if (await canLaunchUrl(telegramUri)) {
      await launchUrl(telegramUri, mode: LaunchMode.externalApplication);
    }
  }
}
