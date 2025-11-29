-- إنشاء جدول المرضى (Patients)
CREATE TABLE IF NOT EXISTS patients (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL,
  age INTEGER NOT NULL CHECK (age > 0 AND age <= 120),
  gender TEXT NOT NULL CHECK (gender IN ('male', 'female')),
  blood_type TEXT NOT NULL,
  district TEXT NOT NULL,
  phone TEXT NOT NULL,
  address TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id)
);

-- إنشاء فهرس لتسريع البحث بواسطة user_id
CREATE INDEX IF NOT EXISTS idx_patients_user_id ON patients(user_id);

-- إنشاء فهرس لتسريع البحث بواسطة فصيلة الدم
CREATE INDEX IF NOT EXISTS idx_patients_blood_type ON patients(blood_type);

-- إنشاء فهرس لتسريع البحث بواسطة المديرية
CREATE INDEX IF NOT EXISTS idx_patients_district ON patients(district);

-- تفعيل Row Level Security
ALTER TABLE patients ENABLE ROW LEVEL SECURITY;

-- سياسة: السماح بالقراءة للجميع (للمتبرعين والمستشفيات)
CREATE POLICY "Allow read access to all authenticated users"
  ON patients
  FOR SELECT
  TO authenticated
  USING (true);

-- سياسة: المستخدمون يمكنهم إدخال بياناتهم
CREATE POLICY "Users can insert their own patient data"
  ON patients
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

-- سياسة: المستخدمون يمكنهم تحديث بياناتهم فقط
CREATE POLICY "Users can update their own patient data"
  ON patients
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- دالة لتحديث updated_at تلقائياً
CREATE OR REPLACE FUNCTION update_patients_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger لتحديث updated_at عند التعديل
DROP TRIGGER IF EXISTS patients_updated_at_trigger ON patients;
CREATE TRIGGER patients_updated_at_trigger
  BEFORE UPDATE ON patients
  FOR EACH ROW
  EXECUTE FUNCTION update_patients_updated_at();

-- تعليق على الجدول
COMMENT ON TABLE patients IS 'جدول بيانات المرضى الذين يطلبون الدم';
COMMENT ON COLUMN patients.user_id IS 'معرف المستخدم من جدول users (UUID)';
COMMENT ON COLUMN patients.full_name IS 'الاسم الكامل للمريض';
COMMENT ON COLUMN patients.age IS 'عمر المريض (1-120)';
COMMENT ON COLUMN patients.gender IS 'الجنس: male أو female';
COMMENT ON COLUMN patients.blood_type IS 'فصيلة الدم';
COMMENT ON COLUMN patients.district IS 'المديرية';
COMMENT ON COLUMN patients.phone IS 'رقم التواصل';
COMMENT ON COLUMN patients.address IS 'العنوان (اختياري)';
