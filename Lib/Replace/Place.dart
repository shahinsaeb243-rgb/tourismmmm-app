// مدل اصلی داده - هر نوع مکانی (جاذبه گردشگری، هتل، رستوران، پمپ‌بنزین، پست کاربر)
// با این کلاس نمایش داده میشه

enum PlaceCategory { attraction, hotel, restaurant, gasStation, userPost }

extension PlaceCategoryFa on PlaceCategory {
  String get label {
    switch (this) {
      case PlaceCategory.attraction:
        return 'جاذبه گردشگری';
      case PlaceCategory.hotel:
        return 'اقامتگاه';
      case PlaceCategory.restaurant:
        return 'رستوران';
      case PlaceCategory.gasStation:
        return 'پمپ بنزین';
      case PlaceCategory.userPost:
        return 'پست کاربر';
    }
  }

  String get icon {
    switch (this) {
      case PlaceCategory.attraction:
        return '🏛️';
      case PlaceCategory.hotel:
        return '🏨';
      case PlaceCategory.restaurant:
        return '🍽️';
      case PlaceCategory.gasStation:
        return '⛽';
      case PlaceCategory.userPost:
        return '📍';
    }
  }
}

class Place {
  final String id;
  final String name;
  final String description;
  final double lat;
  final double lng;
  final List<String> images;
  final PlaceCategory category;
  final String address;
  final double? rating;

  Place({
    required this.id,
    required this.name,
    required this.description,
    required this.lat,
    required this.lng,
    required this.images,
    required this.category,
    this.address = '',
    this.rating,
  });

  // تبدیل به Map برای ذخیره محلی (پست‌های کاربر)
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'lat': lat,
        'lng': lng,
        'images': images,
        'category': category.name,
        'address': address,
        'rating': rating,
      };

  factory Place.fromJson(Map<String, dynamic> json) => Place(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        lat: json['lat'],
        lng: json['lng'],
        images: List<String>.from(json['images'] ?? []),
        category: PlaceCategory.values.firstWhere(
          (e) => e.name == json['category'],
          orElse: () => PlaceCategory.userPost,
        ),
        address: json['address'] ?? '',
        rating: json['rating'],
      );
}
