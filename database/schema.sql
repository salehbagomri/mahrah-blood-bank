-- ============================================
-- إنشاء جداول قاعدة بيانات بنك الدم - المهرة
-- ============================================

-- تفعيل UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- 1. جدول المستخدمين (users)
-- ============================================
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone TEXT UNIQUE NOT NULL,
    user_type TEXT NOT NULL CHECK (user_type IN ('donor', 'hospital', 'patient')),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- فهرس للبحث السريع
CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);
CREATE INDEX IF NOT EXISTS idx_users_type ON users(user_type);

-- ============================================
-- 2. جدول المديريات (districts)
-- ============================================
CREATE TABLE IF NOT EXISTS districts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name_ar TEXT UNIQUE NOT NULL,
    name_en TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- إدراج مديريات المهرة
INSERT INTO districts (name_ar, name_en) VALUES
    ('الغيضة', 'Al Ghaydah'),
    ('حات', 'Hat'),
    ('حصوين', 'Haswain'),
    ('الجديد', 'Al Jadid'),
    ('قشن', 'Qishn'),
    ('شحن', 'Shahn'),
    ('المسيلة', 'Al Masilah'),
    ('حوف', 'Hawf'),
    ('سيحوت', 'Sayhut')
ON CONFLICT (name_ar) DO NOTHING;

-- ============================================
-- 3. جدول المتبرعين (donors)
-- ============================================
CREATE TABLE IF NOT EXISTS donors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    blood_type TEXT NOT NULL CHECK (blood_type IN ('O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-')),
    district TEXT NOT NULL,
    age INTEGER,
    gender TEXT CHECK (gender IN ('male', 'female')),
    weight DECIMAL,
    has_chronic_diseases BOOLEAN DEFAULT FALSE,
    chronic_diseases_description TEXT,
    is_available BOOLEAN DEFAULT TRUE,
    last_donation_date TIMESTAMP,
    donation_count INTEGER DEFAULT 0,
    has_whatsapp BOOLEAN DEFAULT FALSE,
    has_telegram BOOLEAN DEFAULT FALSE,
    telegram_username TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- فهارس للبحث
CREATE INDEX IF NOT EXISTS idx_donors_blood_type ON donors(blood_type);
CREATE INDEX IF NOT EXISTS idx_donors_district ON donors(district);
CREATE INDEX IF NOT EXISTS idx_donors_available ON donors(is_available);

-- ============================================
-- 4. جدول المستشفيات (hospitals)
-- ============================================
CREATE TABLE IF NOT EXISTS hospitals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    hospital_name TEXT NOT NULL,
    district TEXT NOT NULL,
    contact_person TEXT NOT NULL,
    is_verified BOOLEAN DEFAULT FALSE,
    verified_at TIMESTAMP,
    verified_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- فهارس
CREATE INDEX IF NOT EXISTS idx_hospitals_district ON hospitals(district);
CREATE INDEX IF NOT EXISTS idx_hospitals_verified ON hospitals(is_verified);

-- ============================================
-- 5. جدول طلبات الدم (blood_requests)
-- ============================================
CREATE TABLE IF NOT EXISTS blood_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    requester_id UUID REFERENCES users(id) ON DELETE CASCADE,
    requester_type TEXT NOT NULL CHECK (requester_type IN ('hospital', 'patient')),
    blood_type TEXT NOT NULL CHECK (blood_type IN ('O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-')),
    district TEXT NOT NULL,
    urgency_level TEXT DEFAULT 'normal' CHECK (urgency_level IN ('normal', 'urgent')),
    patient_name TEXT NOT NULL,
    description TEXT,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'completed', 'cancelled')),
    completed_at TIMESTAMP,
    cancelled_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- فهارس
CREATE INDEX IF NOT EXISTS idx_requests_status ON blood_requests(status);
CREATE INDEX IF NOT EXISTS idx_requests_blood_type ON blood_requests(blood_type);
CREATE INDEX IF NOT EXISTS idx_requests_district ON blood_requests(district);
CREATE INDEX IF NOT EXISTS idx_requests_urgency ON blood_requests(urgency_level);
CREATE INDEX IF NOT EXISTS idx_requests_created ON blood_requests(created_at DESC);

-- ============================================
-- 6. جدول التبرعات (donations)
-- ============================================
CREATE TABLE IF NOT EXISTS donations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    donor_id UUID REFERENCES donors(id) ON DELETE CASCADE,
    request_id UUID REFERENCES blood_requests(id) ON DELETE SET NULL,
    donation_date TIMESTAMP DEFAULT NOW(),
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- فهارس
CREATE INDEX IF NOT EXISTS idx_donations_donor ON donations(donor_id);
CREATE INDEX IF NOT EXISTS idx_donations_request ON donations(request_id);
CREATE INDEX IF NOT EXISTS idx_donations_date ON donations(donation_date DESC);

-- ============================================
-- 7. جدول الإشعارات (notifications)
-- ============================================
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('new_request', 'request_match', 'request_completed', 'general')),
    related_id UUID,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

-- فهارس
CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_created ON notifications(created_at DESC);

-- ============================================
-- دوال SQL
-- ============================================

-- دالة تسجيل تبرع جديد
CREATE OR REPLACE FUNCTION record_donation(donor_id UUID, request_id UUID DEFAULT NULL)
RETURNS VOID AS $$
BEGIN
    -- إدراج التبرع
    INSERT INTO donations (donor_id, request_id, donation_date)
    VALUES (donor_id, request_id, NOW());
    
    -- تحديث عداد التبرعات وتاريخ آخر تبرع
    UPDATE donors
    SET 
        donation_count = donation_count + 1,
        last_donation_date = NOW(),
        is_available = FALSE,
        updated_at = NOW()
    WHERE id = donor_id;
    
    -- إذا كان هناك طلب مرتبط، تحديث حالته
    IF request_id IS NOT NULL THEN
        UPDATE blood_requests
        SET 
            status = 'completed',
            completed_at = NOW(),
            updated_at = NOW()
        WHERE id = request_id;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- دالة حساب الأيام حتى التبرع القادم
CREATE OR REPLACE FUNCTION days_until_next_donation(donor_id UUID)
RETURNS INTEGER AS $$
DECLARE
    last_donation TIMESTAMP;
    days_passed INTEGER;
BEGIN
    SELECT last_donation_date INTO last_donation
    FROM donors
    WHERE id = donor_id;
    
    IF last_donation IS NULL THEN
        RETURN 0; -- يمكن التبرع الآن
    END IF;
    
    days_passed := EXTRACT(DAY FROM (NOW() - last_donation));
    
    IF days_passed >= 90 THEN
        RETURN 0; -- يمكن التبرع الآن
    ELSE
        RETURN 90 - days_passed; -- الأيام المتبقية
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- Triggers لتحديث updated_at تلقائياً
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- تطبيق trigger على الجداول
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_donors_updated_at BEFORE UPDATE ON donors
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_hospitals_updated_at BEFORE UPDATE ON hospitals
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_blood_requests_updated_at BEFORE UPDATE ON blood_requests
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- Row Level Security (RLS)
-- ============================================

-- تفعيل RLS على الجداول
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE donors ENABLE ROW LEVEL SECURITY;
ALTER TABLE hospitals ENABLE ROW LEVEL SECURITY;
ALTER TABLE blood_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE donations ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- سياسات القراءة (الكل يمكنه القراءة)
CREATE POLICY "Enable read access for all users" ON users FOR SELECT USING (true);
CREATE POLICY "Enable read access for all users" ON donors FOR SELECT USING (true);
CREATE POLICY "Enable read access for all users" ON hospitals FOR SELECT USING (true);
CREATE POLICY "Enable read access for all users" ON blood_requests FOR SELECT USING (true);
CREATE POLICY "Enable read access for all users" ON districts FOR SELECT USING (true);

-- سياسات الكتابة (المستخدم يمكنه تعديل بياناته فقط)
CREATE POLICY "Users can insert their own data" ON users FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can update their own data" ON users FOR UPDATE USING (true);

CREATE POLICY "Donors can insert their own data" ON donors FOR INSERT WITH CHECK (true);
CREATE POLICY "Donors can update their own data" ON donors FOR UPDATE USING (true);

CREATE POLICY "Hospitals can insert their own data" ON hospitals FOR INSERT WITH CHECK (true);
CREATE POLICY "Hospitals can update their own data" ON hospitals FOR UPDATE USING (true);

CREATE POLICY "Users can insert blood requests" ON blood_requests FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can update their own requests" ON blood_requests FOR UPDATE USING (true);

CREATE POLICY "Users can insert donations" ON donations FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can read their notifications" ON notifications FOR SELECT USING (true);
CREATE POLICY "System can insert notifications" ON notifications FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can update their notifications" ON notifications FOR UPDATE USING (true);

-- ============================================
-- بيانات تجريبية (اختياري)
-- ============================================

-- يمكنك إضافة بيانات تجريبية هنا للاختبار
-- مثال: متبرعين تجريبيين، مستشفيات، إلخ

-- ============================================
-- انتهى
-- ============================================

-- عرض ملخص الجداول المنشأة
SELECT 
    tablename,
    schemaname
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;
