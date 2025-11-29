# 🔥 حل نهائي لمشكلة Firebase Phone Auth

## ❌ المشكلة المكتشفة:

**التطبيق يستخدم مشروعين Firebase مختلفين!**

```
google-services.json: project_number = 738636158998
Logs: cloudProjectNumber = 551503664846  ← مختلف!
```

---

## ✅ الحل:

### الخيار 1: استخدام المشروع القديم (551503664846)

1. اذهب إلى Firebase Console للمشروع القديم
2. Project Settings → Your apps → Android
3. Download google-services.json
4. استبدل الملف في `android/app/google-services.json`
5. في هذا المشروع:
   - أضف SHA-1: `62:49:9E:EC:19:C3:76:1D:F9:76:14:67:BC:BC:59:36:F6:26:25:B9`
   - فعّل Phone Authentication
   - أضف Test Number: `+967777616167` → `770727`

### الخيار 2: استخدام المشروع الجديد (mahrah-blood-bank)

1. احذف التطبيق من الجهاز تماماً
2. في `android/app/build.gradle`، تأكد من `applicationId`:
   ```gradle
   applicationId "com.bagomri.mahrahbloodbank"
   ```
3. `flutter clean`
4. `flutter run -d 22101320G`
5. في Firebase Console (mahrah-blood-bank):
   - أضف SHA-1
   - فعّل Phone Authentication  
   - أضف Test Number

---

## 🎯 التوصية:

**استخدم المشروع القديم (551503664846)** لأن التطبيق مرتبط به بالفعل:

1. افتح Firebase Console
2. ابحث عن المشروع الذي `project_number = 551503664846`
3. حمّل `google-services.json` منه
4. استبدل الملف الحالي
5. أضف SHA-1 و Test Numbers في هذا المشروع
6. `flutter clean && flutter run`

---

**هذا هو السبب الحقيقي للمشكلة!** 🔑
