## 🔍 تحقق من google-services.json

**الملف الحالي فارغ من OAuth clients!**

```json
"oauth_client": []  ← المشكلة هنا!
```

**يجب أن يكون:**
```json
"oauth_client": [
  {
    "client_id": "738636158998-xxxxx.apps.googleusercontent.com",
    "client_type": 3
  }
]
```

---

## ✅ الخطوات:

1. Firebase Console → mahrah-blood-bank
2. Project Settings → Your apps → Android
3. Add SHA-1: `62:49:9E:EC:19:C3:76:1D:F9:76:14:67:BC:BC:59:36:F6:26:25:B9`
4. **Download google-services.json** (الجديد!)
5. استبدل `android/app/google-services.json`
6. تحقق أن `oauth_client` ليس فارغاً
7. `flutter clean && flutter run`

---

**بدون OAuth client، Phone Auth لن يعمل أبداً!** 🔑
