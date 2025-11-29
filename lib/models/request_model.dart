/// نموذج طلب الدم
class BloodRequestModel {
  final String id;
  final String requesterId;
  final String requesterType; // 'hospital' or 'patient'
  final String bloodType;
  final String district;
  final String urgencyLevel; // 'urgent' or 'normal'
  final String? patientName;
  final String? description;
  final String status; // 'active', 'completed', 'cancelled'
  final DateTime createdAt;

  BloodRequestModel({
    required this.id,
    required this.requesterId,
    required this.requesterType,
    required this.bloodType,
    required this.district,
    this.urgencyLevel = 'normal',
    this.patientName,
    this.description,
    this.status = 'active',
    required this.createdAt,
  });

  /// إنشاء من JSON
  factory BloodRequestModel.fromJson(Map<String, dynamic> json) {
    return BloodRequestModel(
      id: json['id'] as String,
      requesterId: json['requester_id'] as String,
      requesterType: json['requester_type'] as String,
      bloodType: json['blood_type'] as String,
      district: json['district'] as String,
      urgencyLevel: json['urgency_level'] as String? ?? 'normal',
      patientName: json['patient_name'] as String?,
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'active',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requester_id': requesterId,
      'requester_type': requesterType,
      'blood_type': bloodType,
      'district': district,
      'urgency_level': urgencyLevel,
      'patient_name': patientName,
      'description': description,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// نسخ مع تعديلات
  BloodRequestModel copyWith({
    String? id,
    String? requesterId,
    String? requesterType,
    String? bloodType,
    String? district,
    String? urgencyLevel,
    String? patientName,
    String? description,
    String? status,
    DateTime? createdAt,
  }) {
    return BloodRequestModel(
      id: id ?? this.id,
      requesterId: requesterId ?? this.requesterId,
      requesterType: requesterType ?? this.requesterType,
      bloodType: bloodType ?? this.bloodType,
      district: district ?? this.district,
      urgencyLevel: urgencyLevel ?? this.urgencyLevel,
      patientName: patientName ?? this.patientName,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// التحقق من كون الطلب عاجل
  bool get isUrgent => urgencyLevel == 'urgent';

  /// التحقق من كون الطلب نشط
  bool get isActive => status == 'active';

  /// الحصول على نص حالة الطلب بالعربية
  String get statusText {
    switch (status) {
      case 'active':
        return 'نشط';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  /// الحصول على نص مستوى الأولوية بالعربية
  String get urgencyText {
    switch (urgencyLevel) {
      case 'urgent':
        return 'عاجل';
      case 'normal':
        return 'عادي';
      default:
        return urgencyLevel;
    }
  }

  /// حساب الوقت منذ إنشاء الطلب
  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);
    
    if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} ${difference.inDays == 1 ? 'يوم' : 'أيام'}';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ${difference.inHours == 1 ? 'ساعة' : 'ساعات'}';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} ${difference.inMinutes == 1 ? 'دقيقة' : 'دقائق'}';
    } else {
      return 'الآن';
    }
  }

  @override
  String toString() {
    return 'BloodRequestModel(id: $id, bloodType: $bloodType, district: $district, urgencyLevel: $urgencyLevel, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BloodRequestModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
