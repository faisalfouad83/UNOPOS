# دليل تشغيل UNOPOS خطوة بخطوة (Windows + Android)

هذا الدليل يشرح كيف تشغّل التطبيق من الصفر على جهاز Windows حقيقي، وكيف تشغله على Android (جوال حقيقي أو محاكي/Emulator).

---

## أولاً: تحميل الكود

1. ثبّت **Git** إذا ما كان مثبت: https://git-scm.com/download/win
2. افتح Terminal (أو Git Bash) وسوي:
   ```bash
   git clone https://github.com/faisalfouad83/UNOPOS.git
   cd UNOPOS
   git checkout claude/unopos-pos-saas-flutter-ful666
   ```

---

## ثانياً: تثبيت أدوات التطوير (تسوى مرة وحدة بس)

### 1. تثبيت Flutter SDK
1. حمّل Flutter من هنا: https://docs.flutter.dev/get-started/install/windows
2. فك الضغط بمجلد ثابت، مثلاً `C:\src\flutter` (تجنب المجلدات اللي تحتاج صلاحيات أدمن زي `Program Files`).
3. أضف `C:\src\flutter\bin` إلى متغير النظام `PATH`:
   - دور على "Environment Variables" بقائمة Start.
   - تحت "User variables"، عدّل `Path` وأضف المسار.
4. افتح Terminal جديد وتأكد:
   ```bash
   flutter --version
   ```

### 2. تثبيت Visual Studio (لازم لبناء تطبيق Windows)
1. حمّل **Visual Studio 2022 Community** (مجاني): https://visualstudio.microsoft.com/downloads/
2. أثناء التثبيت، فعّل الحزمة (Workload) اسمها:
   **"Desktop development with C++"**
3. بعد التثبيت، فعّل دعم Windows بفلاتر:
   ```bash
   flutter config --enable-windows-desktop
   ```

### 3. تثبيت Android Studio (لازم لبناء تطبيق Android)
1. حمّل Android Studio: https://developer.android.com/studio
2. أثناء أول تشغيل، خله يثبت لك:
   - Android SDK
   - Android SDK Platform-Tools
   - Android Virtual Device (اذا تريد تجرب بمحاكي)
3. وافق على تراخيص Android:
   ```bash
   flutter doctor --android-licenses
   ```
   اكتب `y` لكل سؤال يطلعلك.

### 4. تأكد كل شي تمام
```bash
flutter doctor -v
```
لازم تشوف علامة ✓ صح جنب:
- Flutter
- Windows toolchain (Visual Studio)
- Android toolchain

إذا فيه أي ✗ (خطأ)، اقرا الرسالة اللي تحته، عادةً تكول لك بالضبط شنو ناقص.

---

## ثالثاً: تجهيز المشروع (كل مرة تسحب تحديثات جديدة من GitHub)

جوه مجلد المشروع `UNOPOS`:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

**شنو تسوي هذي الأوامر؟**
- `flutter pub get`: تحمّل كل المكتبات اللي التطبيق يحتاجها.
- `build_runner build`: تولّد أكواد قاعدة البيانات (Drift) والملفات المساعدة تلقائياً. **لازم تسويها بعد أي تعديل بملفات القاعدة أو الموديلات.**

---

## رابعاً: تشغيل التطبيق على Windows

### للتجربة السريعة (Debug mode):
```bash
flutter run -d windows
```
بيفتحلك التطبيق مباشرة بنافذة، وأي تعديل بالكود تكدر تشوفه بالحال (Hot Reload بزر `r`).

### لبناء نسخة نهائية (.exe) تكدر توزعها:
```bash
flutter build windows --release
```
الملف التنفيذي يطلع بالمسار:
```
build\windows\x64\runner\Release\unopos.exe
```
هذا المجلد فيه كل الملفات اللي التطبيق يحتاجها (dll, exe, بيانات) — انسخ **المجلد كامل** إذا تريد تنقله لجهاز ثاني، مو الملف .exe بروحه.

---

## خامساً: تشغيل التطبيق على Android

### الخيار أ) جهاز أندرويد حقيقي
1. بجهازك: روح Settings > About Phone > اضغط 7 مرات على "Build Number" لين يفعّل "Developer Options".
2. روح Settings > Developer Options > فعّل **USB Debugging**.
3. وصل الجهاز بالكمبيوتر بكيبل USB.
4. بالكمبيوتر، تأكد الجهاز انظبط:
   ```bash
   flutter devices
   ```
   لازم يطلعلك اسم جهازك بالقائمة.

### الخيار ب) محاكي Android (Emulator) — إذا ما عندك جهاز حقيقي
1. افتح Android Studio > Device Manager > Create Device.
2. اختار جهاز (مثلاً Pixel 7) واختار نسخة أندرويد (يفضل أحدث نسخة مثبتة).
3. شغّل المحاكي (زر ▶️).
4. تأكد فلاتر يشوفه:
   ```bash
   flutter devices
   ```

### تشغيل التطبيق:
```bash
flutter run -d <device-id>
```
(`device-id` تحصله من نتيجة `flutter devices`، أو بس اكتب `flutter run` وهو يسألك تختار من قائمة إذا فيه أكثر من جهاز متصل).

### لبناء APK نهائي تنصبه على أي جهاز:
```bash
flutter build apk --release
```
الملف يطلع بالمسار:
```
build\app\outputs\flutter-apk\app-release.apk
```
انقل هذا الملف لأي جهاز أندرويد وثبته عادي (لازم تفعّل "تثبيت من مصادر غير معروفة" بإعدادات الجهاز).

---

## ملاحظات مهمة

- **أول مرة** تشغل `flutter build windows` أو `flutter build apk`، التطبيق يحتاج يحمّل مكتبة SQLite من الإنترنت — تأكد جهازك متصل بالنت عادي (مو بيئة مقيدة زي اللي أنا أشتغل بيها).
- **قاعدة البيانات محلية بالكامل** — كل جهاز (Windows أو Android) يحفظ بياناته بروحه، ما فيه مزامنة بينهم لين نربطها بـ Supabase/Firebase بالمستقبل.
- إذا صار خطأ غريب بعد سحب تحديثات جديدة، جرب:
  ```bash
  flutter clean
  flutter pub get
  dart run build_runner build --delete-conflicting-outputs
  ```
- لتشغيل الاختبارات والتأكد كلشي شغال زين:
  ```bash
  flutter analyze
  flutter test
  ```
