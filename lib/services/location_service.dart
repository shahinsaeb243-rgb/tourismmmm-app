import 'package:geolocator/geolocator.dart';

// این کلاس مسئول گرفتن مجوز GPS و موقعیت فعلی کاربره
class LocationService {
  // درخواست مجوز و برگردوندن موقعیت فعلی کاربر
  // اگه کاربر مجوز نده یا GPS خاموش باشه، خطا برمی‌گردونه
  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('لطفاً GPS گوشی خود را روشن کنید');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('برای استفاده از این قابلیت باید دسترسی موقعیت مکانی را بدهید');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('دسترسی موقعیت مکانی برای همیشه رد شده. از تنظیمات گوشی فعالش کنید');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // محاسبه فاصله بین دو نقطه (بر حسب متر)
  static double distanceInMeters(
      double lat1, double lng1, double lat2, double lng2) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
  }

  // تبدیل فاصله به متن فارسی خوانا (متر یا کیلومتر)
  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} متر';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} کیلومتر';
    }
  }
}
