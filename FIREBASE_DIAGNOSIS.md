# 🔍 تشخيص مشكلة Firebase Phone Authentication

## ❌ المشكلة الحالية:

```
SMS unable to be sent until this region enabled by the app developer
operation-not-allowed
```

---

## ✅ ما تم عمله حتى الآن:

1. ✅ إضافة SHA-1 fingerprint
2. ✅ تحديث google-services.json
3. ✅ إضافة Test Phone Number (+967777616167 → 770727)
4. ❌ ما زالت المشكلة موجودة

---

## 🔍 التشخيص المحتمل:

### السبب 1: Phone Authentication غير مُفعّل بالكامل

**الحل:**
1. Firebase Console → Authentication → Sign-in method
2. تأكد من أن **Phone** مُفعّل (Enabled)
3. اضغط على Phone → تأكد من:
   - Status: **Enabled** ✅
   - Test phone numbers موجودة

### السبب 2: اليمن محظور في Firebase

Firebase يحظر بعض الدول افتراضياً. **Test Numbers** يجب أن تعمل حتى لو كانت الدولة محظورة، لكن قد تحتاج:

**الحل:**
1. Firebase Console → Authentication → Settings
2. تبويب **"Authorized domains"**
3. تأكد من وجود `localhost` و domain تطبيقك

### السبب 3: Google Play Integrity API

الخطأ يظهر:
```
IntegrityService : requestIntegrityToken
Failed to initialize reCAPTCHA config
```

**الحل:**
1. Firebase Console → Project Settings
2. تأكد من إضافة SHA-1 في **جميع** build types:
   - Debug SHA-1: `62:49:9E:EC:19:C3:76:1D:F9:76:14:67:BC:BC:59:36:F6:26:25:B9`
   - Release SHA-1 (إذا كان لديك)

### السبب 4: google-services.json قديم

الملف الحالي لا يحتوي على `oauth_client` entries!

**الحل:**
1. Firebase Console → Project Settings → Your apps
2. بعد إضافة SHA-1، **حمّل google-services.json جديد**
3. استبدل الملف في `android/app/google-services.json`
4. **مهم:** تأكد من أن الملف الجديد يحتوي على `oauth_client` section

---

## 🎯 الخطوات التالية:

### 1. تحقق من Phone Authentication:
```
Firebase Console → Authentication → Sign-in method → Phone
- Status: Enabled ✅
- Test numbers: +967777616167 → 770727 ✅
```

### 2. حمّل google-services.json جديد:
```
Firebase Console → Project Settings → General → Your apps → Android
- Download google-services.json
- Replace android/app/google-services.json
```

### 3. تحقق من الملف الجديد:
يجب أن يحتوي على:
```json
"oauth_client": [
  {
    "client_id": "...",
    "client_type": 3
  }
]
```

### 4. أعد البناء:
```bash
flutter clean
flutter pub get
flutter run -d 22101320G
```

---

## 🔧 حل بديل: استخدام رقم وهمي آخر

جرب إضافة رقم أمريكي للاختبار:
```
+1 650-555-1234 → 123456
```

الأرقام الأمريكية عادة تعمل بدون مشاكل في Firebase.

---

## 📊 Logs للتشخيص:

عند التشغيل التالي، راقب:
```
✅ تم إرسال الكود بنجاح  ← يجب أن تظهر
❌ فشل التحقق: operation-not-allowed  ← المشكلة
```

إذا ظهر `operation-not-allowed` مرة أخرى، المشكلة في إعدادات Firebase نفسها.

---

**الخطوة الأهم: حمّل google-services.json جديد بعد إضافة SHA-1!** 🔑
