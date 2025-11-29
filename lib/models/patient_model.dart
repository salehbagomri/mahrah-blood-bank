/// نموذج بيانات المريض
class PatientModel {
  final String id;
  final String userId; // FK to users table
  final String fullName;
  final int age;
  final String gender; // 'male' or 'female'
  final String bloodType;
  final String district;
  final String phone;
  final String? address;
  final DateTime createdAt;
  final DateTime updatedAt;

  PatientModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.age,
    required this.gender,
    required this.bloodType,
    required this.district,
    required this.phone,
    this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  /// من JSON
  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String,
      age: json['age'] as int,
      gender: json['gender'] as String,
      bloodType: json['blood_type'] as String,
      district: json['district'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'age': age,
      'gender': gender,
      'blood_type': bloodType,
      'district': district,
      'phone': phone,
      'address': address,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// نسخ مع تعديلات
  PatientModel copyWith({
    String? id,
    String? userId,
    String? fullName,
    int? age,
    String? gender,
    String? bloodType,
    String? district,
    String? phone,
    String? address,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PatientModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      bloodType: bloodType ?? this.bloodType,
      district: district ?? this.district,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'PatientModel(id: $id, fullName: $fullName, bloodType: $bloodType, district: $district)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PatientModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
