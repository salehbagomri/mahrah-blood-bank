-- =====================================================
-- قاعدة بيانات بنك الدم - محافظة المهرة
-- Supabase SQL Schema
-- =====================================================

-- تفعيل امتداد UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- جدول المستخدمين الأساسي
-- =====================================================
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  phone VARCHAR(15) UNIQUE NOT NULL,
  user_type VARCHAR(20) NOT NULL CHECK (user_type IN ('donor', 'hospital', 'patient')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_active BOOLEAN DEFAULT true
);

-- فهرس على رقم الهاتف للبحث السريع
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_user_type ON users(user_type);

-- =====================================================
-- جدول المتبرعين
-- =====================================================
CREATE TABLE IF NOT EXISTS donors (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  full_name VARCHAR(100) NOT NULL,
  blood_type VARCHAR(3) NOT NULL CHECK (blood_type IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')),
  district VARCHAR(50) NOT NULL,
  birth_date DATE,
  gender VARCHAR(10) CHECK (gender IN ('male', 'female')),
  weight DECIMAL(5,2),
  is_available BOOLEAN DEFAULT true,
  last_donation_date DATE,
  has_chronic_diseases BOOLEAN DEFAULT false,
  has_whatsapp BOOLEAN DEFAULT false,
  has_telegram BOOLEAN DEFAULT false,
  telegram_username VARCHAR(50),
  donation_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id)
);

-- فهارس للبحث السريع
CREATE INDEX idx_donors_blood_type ON donors(blood_type);
CREATE INDEX idx_donors_district ON donors(district);
CREATE INDEX idx_donors_is_available ON donors(is_available);
CREATE INDEX idx_donors_user_id ON donors(user_id);

-- =====================================================
-- جدول المستشفيات
-- =====================================================
CREATE TABLE IF NOT EXISTS hospitals (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  hospital_name VARCHAR(200) NOT NULL,
  district VARCHAR(50) NOT NULL,
  contact_person VARCHAR(100),
  is_verified BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id)
);

-- فهارس
CREATE INDEX idx_hospitals_district ON hospitals(district);
CREATE INDEX idx_hospitals_is_verified ON hospitals(is_verified);
CREATE INDEX idx_hospitals_user_id ON hospitals(user_id);

-- =====================================================
-- جدول طلبات الدم
-- =====================================================
CREATE TABLE IF NOT EXISTS blood_requests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  requester_id UUID REFERENCES users(id) ON DELETE CASCADE,
  requester_type VARCHAR(20) CHECK (requester_type IN ('hospital', 'patient')),
  blood_type VARCHAR(3) NOT NULL CHECK (blood_type IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')),
  district VARCHAR(50) NOT NULL,
  urgency_level VARCHAR(20) DEFAULT 'normal' CHECK (urgency_level IN ('urgent', 'normal')),
  patient_name VARCHAR(100),
  description TEXT,
  status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'completed', 'cancelled')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- فهارس للبحث السريع
CREATE INDEX idx_blood_requests_blood_type ON blood_requests(blood_type);
CREATE INDEX idx_blood_requests_district ON blood_requests(district);
CREATE INDEX idx_blood_requests_status ON blood_requests(status);
CREATE INDEX idx_blood_requests_urgency ON blood_requests(urgency_level);
CREATE INDEX idx_blood_requests_requester_id ON blood_requests(requester_id);
CREATE INDEX idx_blood_requests_created_at ON blood_requests(created_at DESC);

-- =====================================================
-- جدول المديريات
-- =====================================================
CREATE TABLE IF NOT EXISTS districts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name_ar VARCHAR(100) NOT NULL UNIQUE,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- إدراج مديريات محافظة المهرة
INSERT INTO districts (name_ar) VALUES
  ('الغيضة'),
  ('سيحوت'),
  ('حصوين'),
  ('قشن'),
  ('حوف'),
  ('شحن'),
  ('المسيلة'),
  ('حات'),
  ('الحدبين')
ON CONFLICT (name_ar) DO NOTHING;

-- =====================================================
-- دالة لتحديث updated_at تلقائياً
-- =====================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- تطبيق الدالة على جدول طلبات الدم
CREATE TRIGGER update_blood_requests_updated_at
  BEFORE UPDATE ON blood_requests
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- سياسات الأمان (Row Level Security)
-- =====================================================

-- تفعيل RLS على جميع الجداول
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE donors ENABLE ROW LEVEL SECURITY;
ALTER TABLE hospitals ENABLE ROW LEVEL SECURITY;
ALTER TABLE blood_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE districts ENABLE ROW LEVEL SECURITY;

-- سياسة قراءة المستخدمين (يمكن للجميع قراءة بياناتهم فقط)
CREATE POLICY "Users can read own data"
  ON users FOR SELECT
  USING (auth.uid()::text = id::text);

-- سياسة إنشاء مستخدم جديد
CREATE POLICY "Anyone can create user"
  ON users FOR INSERT
  WITH CHECK (true);

-- سياسة قراءة المتبرعين (يمكن للجميع القراءة)
CREATE POLICY "Anyone can read donors"
  ON donors FOR SELECT
  USING (true);

-- سياسة إنشاء متبرع (المستخدم المصادق فقط)
CREATE POLICY "Authenticated users can create donor"
  ON donors FOR INSERT
  WITH CHECK (auth.uid()::text = user_id::text);

-- سياسة تحديث المتبرع (صاحب الحساب فقط)
CREATE POLICY "Donors can update own data"
  ON donors FOR UPDATE
  USING (auth.uid()::text = user_id::text);

-- سياسة قراءة المستشفيات (يمكن للجميع القراءة)
CREATE POLICY "Anyone can read hospitals"
  ON hospitals FOR SELECT
  USING (true);

-- سياسة إنشاء مستشفى
CREATE POLICY "Authenticated users can create hospital"
  ON hospitals FOR INSERT
  WITH CHECK (auth.uid()::text = user_id::text);

-- سياسة قراءة طلبات الدم (يمكن للجميع القراءة)
CREATE POLICY "Anyone can read blood requests"
  ON blood_requests FOR SELECT
  USING (true);

-- سياسة إنشاء طلب دم
CREATE POLICY "Authenticated users can create blood request"
  ON blood_requests FOR INSERT
  WITH CHECK (auth.uid()::text = requester_id::text);

-- سياسة تحديث طلب الدم (صاحب الطلب فقط)
CREATE POLICY "Requesters can update own requests"
  ON blood_requests FOR UPDATE
  USING (auth.uid()::text = requester_id::text);

-- سياسة قراءة المديريات (يمكن للجميع القراءة)
CREATE POLICY "Anyone can read districts"
  ON districts FOR SELECT
  USING (true);

-- =====================================================
-- نهاية السكريبت
-- =====================================================

COMMENT ON TABLE users IS 'جدول المستخدمين الأساسي';
COMMENT ON TABLE donors IS 'جدول المتبرعين بالدم';
COMMENT ON TABLE hospitals IS 'جدول المستشفيات والمراكز الصحية';
COMMENT ON TABLE blood_requests IS 'جدول طلبات الدم';
COMMENT ON TABLE districts IS 'جدول مديريات محافظة المهرة';
