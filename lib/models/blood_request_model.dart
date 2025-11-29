
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
  
  // بيانات إضافية (من join)
  final String? requesterName;
  final String? requesterPhone;

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
    DateTime? createdAt,
    this.requesterName,
    this.requesterPhone,
  }) : createdAt = createdAt ?? DateTime.now();

  factory BloodRequestModel.fromJson(Map<String, dynamic> json) {
    return BloodRequestModel(
      id: json['id'],
      requesterId: json['requester_id'],
      requesterType: json['requester_type'],
      bloodType: json['blood_type'],
      district: json['district'],
      urgencyLevel: json['urgency_level'] ?? 'normal',
      patientName: json['patient_name'],
      description: json['description'],
      status: json['status'] ?? 'active',
      createdAt: DateTime.parse(json['created_at']),
      requesterName: json['requester_name'],
      requesterPhone: json['requester_phone'],
    );
  }

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

  bool get isUrgent => urgencyLevel == 'urgent';
  bool get isActive => status == 'active';
  
  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);
    
    if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else {
      return 'منذ ${difference.inDays} يوم';
    }
  }

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
    String? requesterName,
    String? requesterPhone,
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
      requesterName: requesterName ?? this.requesterName,
      requesterPhone: requesterPhone ?? this.requesterPhone,
    );
  }
}
