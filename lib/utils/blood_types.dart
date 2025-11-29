/// فصائل الدم والتوافق بينها
library;

// قائمة فصائل الدم
const List<String> BLOOD_TYPES = [
  'A+',
  'A-',
  'B+',
  'B-',
  'AB+',
  'AB-',
  'O+',
  'O-',
];

/// Class للوصول السهل لفصائل الدم
class BloodTypes {
  static const List<String> allTypes = BLOOD_TYPES;
}

// خريطة التوافق: كل فصيلة يمكنها استقبال الدم من الفصائل المذكورة
const Map<String, List<String>> BLOOD_COMPATIBILITY = {
  'A+': ['A+', 'A-', 'O+', 'O-'],
  'A-': ['A-', 'O-'],
  'B+': ['B+', 'B-', 'O+', 'O-'],
  'B-': ['B-', 'O-'],
  'AB+': ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'], // المستقبل العام
  'AB-': ['A-', 'B-', 'AB-', 'O-'],
  'O+': ['O+', 'O-'],
  'O-': ['O-'], // المتبرع العام
};

/// التحقق من توافق فصيلة الدم
/// [recipientType] فصيلة المستقبل (المحتاج)
/// [donorType] فصيلة المتبرع
/// يرجع true إذا كان المتبرع يمكنه التبرع للمستقبل
bool isBloodTypeCompatible(String recipientType, String donorType) {
  if (!BLOOD_TYPES.contains(recipientType) || 
      !BLOOD_TYPES.contains(donorType)) {
    return false;
  }
  
  final compatibleTypes = BLOOD_COMPATIBILITY[recipientType];
  return compatibleTypes?.contains(donorType) ?? false;
}

/// الحصول على قائمة المتبرعين المتوافقين لفصيلة معينة
/// [recipientType] فصيلة المستقبل
/// يرجع قائمة الفصائل التي يمكنها التبرع
List<String> getCompatibleDonorTypes(String recipientType) {
  if (!BLOOD_TYPES.contains(recipientType)) {
    return [];
  }
  
  return BLOOD_COMPATIBILITY[recipientType] ?? [];
}

/// الحصول على قائمة المستقبلين المتوافقين لفصيلة متبرع معينة
/// [donorType] فصيلة المتبرع
/// يرجع قائمة الفصائل التي يمكن للمتبرع التبرع لها
List<String> getCompatibleRecipientTypes(String donorType) {
  if (!BLOOD_TYPES.contains(donorType)) {
    return [];
  }
  
  List<String> recipients = [];
  
  BLOOD_COMPATIBILITY.forEach((recipient, donors) {
    if (donors.contains(donorType)) {
      recipients.add(recipient);
    }
  });
  
  return recipients;
}

/// الحصول على أيقونة فصيلة الدم
String getBloodTypeIcon(String bloodType) {
  return '🩸'; // يمكن استبدالها بأيقونات مخصصة
}

/// الحصول على لون فصيلة الدم (للعرض)
/// يمكن استخدامها لتلوين البطاقات حسب الفصيلة
String getBloodTypeColorHex(String bloodType) {
  // ألوان مختلفة لكل فصيلة للتمييز البصري
  switch (bloodType) {
    case 'A+':
      return '#D32F2F'; // أحمر غامق
    case 'A-':
      return '#E57373'; // أحمر فاتح
    case 'B+':
      return '#1976D2'; // أزرق غامق
    case 'B-':
      return '#64B5F6'; // أزرق فاتح
    case 'AB+':
      return '#7B1FA2'; // بنفسجي غامق
    case 'AB-':
      return '#BA68C8'; // بنفسجي فاتح
    case 'O+':
      return '#388E3C'; // أخضر غامق
    case 'O-':
      return '#81C784'; // أخضر فاتح
    default:
      return '#757575'; // رمادي
  }
}

/// الحصول على وصف فصيلة الدم
String getBloodTypeDescription(String bloodType) {
  switch (bloodType) {
    case 'O-':
      return 'المتبرع العام - يمكنه التبرع لجميع الفصائل';
    case 'AB+':
      return 'المستقبل العام - يمكنه استقبال من جميع الفصائل';
    case 'O+':
      return 'يمكنه التبرع لجميع الفصائل الموجبة';
    case 'AB-':
      return 'يمكنه استقبال من جميع الفصائل السالبة';
    default:
      return 'فصيلة $bloodType';
  }
}
