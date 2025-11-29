/// نموذج المستخدم الأساسي
class UserModel {
  final String id;
  final String phone;
  final String userType; // 'donor', 'hospital', 'patient'
  final DateTime createdAt;
  final bool isActive;

  UserModel({
    required this.id,
    required this.phone,
    required this.userType,
    required this.createdAt,
    this.isActive = true,
  });

  /// إنشاء من JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      phone: json['phone'] as String,
      userType: json['user_type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'user_type': userType,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  /// نسخ مع تعديلات
  UserModel copyWith({
    String? id,
    String? phone,
    String? userType,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      userType: userType ?? this.userType,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, phone: $phone, userType: $userType, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.id == id &&
        other.phone == phone &&
        other.userType == userType &&
        other.createdAt == createdAt &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        phone.hashCode ^
        userType.hashCode ^
        createdAt.hashCode ^
        isActive.hashCode;
  }
}
