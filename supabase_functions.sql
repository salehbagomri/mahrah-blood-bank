# SQL Function للتبرع

قم بتشغيل هذا الكود في Supabase SQL Editor:

```sql
-- دالة لتسجيل تبرع جديد
CREATE OR REPLACE FUNCTION record_donation(donor_id UUID)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE donors
  SET 
    last_donation_date = NOW(),
    donation_count = donation_count + 1,
    updated_at = NOW()
  WHERE id = donor_id;
END;
$$;
```

هذه الدالة ستقوم بـ:
1. تحديث تاريخ آخر تبرع إلى الآن
2. زيادة عدد التبرعات بمقدار 1
3. تحديث وقت التعديل

**ملاحظة:** يجب تشغيل هذا الكود في Supabase قبل استخدام ميزة تسجيل التبرع في التطبيق.
