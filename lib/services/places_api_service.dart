import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/place.dart';
import '../widgets/image_carousel.dart';

class PlaceDetailScreen extends StatelessWidget {
  final Place place;
  final String? distanceText;

  const PlaceDetailScreen({super.key, required this.place, this.distanceText});

  // باز کردن مسیریابی گوگل مپ به سمت این مکان
  Future<void> _openDirections() async {
    final url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${place.lat},${place.lng}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: ImageCarousel(images: place.images, height: 280),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(place.name,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      ),
                      if (place.rating != null)
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            Text(' ${place.rating}',
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(place.address,
                            style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      ),
                    ],
                  ),
                  if (distanceText != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.near_me, size: 16, color: Colors.teal),
                          const SizedBox(width: 6),
                          Text('$distanceText با شما فاصله دارد',
                              style: const TextStyle(
                                  color: Colors.teal, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(place.category.label,
                      style: TextStyle(
                          color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(place.description,
                      style: const TextStyle(fontSize: 15, height: 1.6)),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _openDirections,
                      icon: const Icon(Icons.directions),
                      label: const Text('مسیریابی در گوگل مپ'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
