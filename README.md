# Hassadi Libya Rates Board

تطبيق Flutter كامل لشاشة أسعار الصرف الليبية، مصمم للهواتف والأجهزة اللوحية وشاشات Android TV.

## المميزات

- لوحة Full Screen بطابع شاشة أسعار الصرافة.
- العملة الرئيسية الافتراضية: LYD.
- تبديل بين السعر الرسمي والسوق الموازي.
- تحديث يدوي وتلقائي مع اختيار الفاصل الزمني (الافتراضي 5 دقائق لتقليل استهلاك API).
- كشف تغير السعر وإظهار نسبة التغير.
- تخزين آخر بيانات ناجحة محليًا.
- اختيار العملة الرئيسية وإعادة حساب الأسعار مقابلها.
- وضع تلفزيون مع إبقاء الشاشة مضاءة.
- زر عرض الشاشة على التلفزيون يفتح Cast / Wireless Display في Android.
- عربي / English.
- مجموعة عملات رئيسية شائعة في ليبيا.
- مصدر رسمي مباشر من مصرف ليبيا المركزي.
- دعم Fulus API للسوق الموازي عند تمرير `FULUS_API_TOKEN`.
- fallback عام من Prices.ly للدولار واليورو عند غياب Fulus.
- لا توجد أسرار أو API tokens داخل المستودع.

## المصادر

مصرف ليبيا المركزي:
https://cbl.gov.ly/currency-exchange-rates/

Fulus:
https://fulus.ly/
https://fulus.ly/help

Prices.ly:
https://prices.ly/en/
https://prices.ly/en/about/

> أسعار السوق الموازي استرشادية وقد تختلف عن سعر التنفيذ الفعلي.

## تشغيل Ubuntu / Termux

المسار المقترح:

```text
/root/projects/libya_rates_board
```

بعد نسخ المشروع:

```bash
cd /root/projects/libya_rates_board
flutter pub get
flutter analyze
flutter test
```

للتشغيل مع Fulus:

```bash
flutter run --dart-define=FULUS_API_TOKEN=YOUR_TOKEN
```

## GitHub Actions

أضف Secret باسم:

```text
FULUS_API_TOKEN
```

ثم شغل:

`Actions -> Build Libya Rates Board APK`

يتم بناء APK فقط ورفعه كـ Artifact، وعند إنشاء tag يبدأ بـ `v` يضاف APK إلى GitHub Release.

## حماية الأسرار

لا تضع Fulus token أو ملفات keystore في GitHub.

للنشر العام استخدم GitHub Secret أو Backend Proxy بدل وضع المفتاح داخل الكود.
