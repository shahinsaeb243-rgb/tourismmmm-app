import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/place.dart';

// این سرویس پست‌هایی که کاربر خودش اضافه می‌کنه رو روی حافظه گوشی ذخیره می‌کنه.
// یعنی بدون نیاز به سرور، کاربر می‌تونه مکان جدید ثبت کنه و بعداً ببینتش.
//
// نکته: این پست‌ها فقط روی همین گوشی ذخیره میشن و بقیه کاربرها نمی‌بینن.
// اگه بخواید پست‌ها عمومی و برای همه قابل مشاهده باشه، باید بعداً
// به‌جای shared_preferences از یک دیتابیس ابری مثل Firebase Firestore استفاده کنید.
class UserPostsStorage {
  static const _key = 'user_posts';

  static Future<List<Place>> getAllPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.map((e) => Place.fromJson(json.decode(e))).toList();
  }

  static Future<void> addPost(Place place) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    raw.add(json.encode(place.toJson()));
    await prefs.setStringList(_key, raw);
  }

  static Future<void> deletePost(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    raw.removeWhere((e) => json.decode(e)['id'] == id);
    await prefs.setStringList(_key, raw);
  }
}
