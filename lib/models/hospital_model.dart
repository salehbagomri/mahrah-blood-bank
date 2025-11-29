/// نموذج المستشفى
class HospitalModel {
  final String id;
  final String userId;
  final String hospitalName;
  final String district;
  final String? contactPerson;
  final bool isVerified;
  final DateTime createdAt;

  HospitalModel({
    required this.id,
    required this.userId,
    required this.hospitalName,
    required this.district,
    this.contactPerson,
    this.isVerified = false,
    required this.createdAt,
  });

  /// إنشاء من JSON
  factory HospitalModel.fromJson(Map<String, dynamic> json) {
    return HospitalModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      hospitalName: json['hospital_name'] as String,
      district: json['district'] as String,
      contactPerson: json['contact_person'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'hospital_name': hospitalName,
      'district': district,
      'contact_person': contactPerson,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// نسخ مع تعديلات
  HospitalModel copyWith({
    String? id,
    String? userId,
    String? hospitalName,
    String? district,
    String? contactPerson,
    bool? isVerified,
    DateTime? createdAt,
  }) {
    return HospitalModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      hospitalName: hospitalName ?? this.hospitalName,
      district: district ?? this.district,
      contactPerson: contactPerson ?? this.contactPerson,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'HospitalModel(id: $id, hospitalName: $hospitalName, district: $district, isVerified: $isVerified)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HospitalModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
