import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/place.dart';

// این سرویس با استفاده از Google Places API پمپ‌بنزین‌ها و رستوران‌های
// واقعی و نزدیک به موقعیت کاربر رو زنده دریافت می‌کنه.
//
// ⚠️ برای کار کردن این بخش، باید یک API Key از Google Cloud Console بگیرید:
// ۱. برید به console.cloud.google.com
// ۲. یک پروژه بسازید
// ۳. از بخش APIs، "Places API" را فعال کنید
// ۴. یک API Key بسازید و همینجا جایگزین کنید
class PlacesApiService {
  static const String _apiKey = 'YOUR_GOOGLE_PLACES_API_KEY';

  // دریافت مکان‌های نزدیک بر اساس نوع (gas_station یا restaurant)
  // radius بر حسب متر است (مثلاً ۵۰۰۰ یعنی ۵ کیلومتر)
  static Future<List<Place>> getNearbyPlaces({
    required double lat,
    required double lng,
    required String type, // 'gas_station' یا 'restaurant'
    int radius = 5000,
  }) async {
    final category =
        type == 'gas_station' ? PlaceCategory.gasStation : PlaceCategory.restaurant;

    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=$lat,$lng&radius=$radius&type=$type&key=$_apiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode != 200) {
        throw Exception('خطا در دریافت اطلاعات از گوگل');
      }

      final data = json.decode(response.body);
      if (data['status'] != 'OK') {
        // اگه کلید API درست نباشه یا نتیجه‌ای نباشه
        return [];
      }

      final List results = data['results'];
      return results.map<Place>((item) {
        final loc = item['geometry']['location'];
        return Place(
          id: item['place_id'],
          name: item['name'] ?? 'بدون نام',
          description: item['vicinity'] ?? '',
          lat: loc['lat'],
          lng: loc['lng'],
          images: item['photos'] != null
              ? [
                  'https://maps.googleapis.com/maps/api/place/photo'
                      '?maxwidth=800&photo_reference=${item['photos'][0]['photo_reference']}'
                      '&key=$_apiKey'
                ]
              : [],
          category: category,
          address: item['vicinity'] ?? '',
          rating: (item['rating'] as num?)?.toDouble(),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
