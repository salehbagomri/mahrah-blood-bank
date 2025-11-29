/// نموذج المتبرع
class DonorModel {
  final String id;
  final String userId;
  final String fullName;
  final String bloodType;
  final String district;
  final DateTime? birthDate;
  final String? gender;
  final double? weight;
  final bool isAvailable;
  final DateTime? lastDonationDate;
  final bool hasChronicDiseases;
  final bool hasWhatsapp;
  final bool hasTelegram;
  final String? telegramUsername;
  final int donationCount;
  final DateTime createdAt;

  DonorModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.bloodType,
    required this.district,
    this.birthDate,
    this.gender,
    this.weight,
    this.isAvailable = true,
    this.lastDonationDate,
    this.hasChronicDiseases = false,
    this.hasWhatsapp = false,
    this.hasTelegram = false,
    this.telegramUsername,
    this.donationCount = 0,
    required this.createdAt,
  });

  /// إنشاء من JSON
  factory DonorModel.fromJson(Map<String, dynamic> json) {
    return DonorModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String,
      bloodType: json['blood_type'] as String,
      district: json['district'] as String,
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'] as String)
          : null,
      gender: json['gender'] as String?,
      weight: json['weight'] != null
          ? (json['weight'] as num).toDouble()
          : null,
      isAvailable: json['is_available'] as bool? ?? true,
      lastDonationDate: json['last_donation_date'] != null
          ? DateTime.parse(json['last_donation_date'] as String)
          : null,
      hasChronicDiseases: json['has_chronic_diseases'] as bool? ?? false,
      hasWhatsapp: json['has_whatsapp'] as bool? ?? false,
      hasTelegram: json['has_telegram'] as bool? ?? false,
      telegramUsername: json['telegram_username'] as String?,
      donationCount: json['donation_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'blood_type': bloodType,
      'district': district,
      'birth_date': birthDate?.toIso8601String(),
      'gender': gender,
      'weight': weight,
      'is_available': isAvailable,
      'last_donation_date': lastDonationDate?.toIso8601String(),
      'has_chronic_diseases': hasChronicDiseases,
      'has_whatsapp': hasWhatsapp,
      'has_telegram': hasTelegram,
      'telegram_username': telegramUsername,
      'donation_count': donationCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// نسخ مع تعديلات
  DonorModel copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? bloodType,
    String? district,
    DateTime? birthDate,
    String? gender,
    double? weight,
    bool? isAvailable,
    DateTime? lastDonationDate,
    bool? hasChronicDiseases,
    bool? hasWhatsapp,
    bool? hasTelegram,
    String? telegramUsername,
    int? donationCount,
    DateTime? createdAt,
  }) {
    return DonorModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      bloodType: bloodType ?? this.bloodType,
      district: district ?? this.district,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      isAvailable: isAvailable ?? this.isAvailable,
      lastDonationDate: lastDonationDate ?? this.lastDonationDate,
      hasChronicDiseases: hasChronicDiseases ?? this.hasChronicDiseases,
      hasWhatsapp: hasWhatsapp ?? this.hasWhatsapp,
      hasTelegram: hasTelegram ?? this.hasTelegram,
      telegramUsername: telegramUsername ?? this.telegramUsername,
      donationCount: donationCount ?? this.donationCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// حساب العمر
  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  /// التحقق من إمكانية التبرع الشاملة
  bool get canDonate {
    if (!isAvailable) return false;
    if (hasChronicDiseases) return false;
    
    // التحقق من العمر
    final currentAge = age;
    if (currentAge == null || currentAge < 18 || currentAge > 65) return false;
    
    // التحقق من الوزن
    if (weight == null || weight! < 50) return false;
    
    // يجب أن يمر 90 يوماً على آخر تبرع
    if (lastDonationDate != null) {
      final daysSinceLastDonation = DateTime.now().difference(lastDonationDate!).inDays;
      if (daysSinceLastDonation < 90) return false;
    }
    
    return true;
  }

  /// الأيام المتبقية للتبرع القادم
  int? get daysUntilNextDonation {
    if (lastDonationDate == null) return null;
    final daysSinceLastDonation = DateTime.now().difference(lastDonationDate!).inDays;
    final daysRemaining = 90 - daysSinceLastDonation;
    return daysRemaining > 0 ? daysRemaining : 0;
  }

  @override
  String toString() {
    return 'DonorModel(id: $id, fullName: $fullName, bloodType: $bloodType, district: $district, isAvailable: $isAvailable)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DonorModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
