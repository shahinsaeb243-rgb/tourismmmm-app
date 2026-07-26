import 'package:flutter/material.dart';
import '../models/place.dart';

// کارت نمایش هر مکان توی لیست - شامل عکس، اسم، فاصله (اگه موجود باشه) و امتیاز
class PlaceListItem extends StatelessWidget {
  final Place place;
  final String? distanceText;
  final VoidCallback onTap;

  const PlaceListItem({
    super.key,
    required this.place,
    this.distanceText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: place.images.isNotEmpty
                    ? Image.network(
                        place.images.first,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          width: 72,
                          height: 72,
                          color: Colors.grey[300],
                          child: Text(place.category.icon,
                              style: const TextStyle(fontSize: 28)),
                        ),
                      )
                    : Container(
                        width: 72,
                        height: 72,
                        color: Colors.grey[300],
                        child: Text(place.category.icon,
                            style: const TextStyle(fontSize: 28)),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(place.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(
                      place.address.isNotEmpty ? place.address : place.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (place.rating != null) ...[
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text('${place.rating}', style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 10),
                        ],
                        if (distanceText != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.teal.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.near_me, size: 12, color: Colors.teal),
                                const SizedBox(width: 3),
                                Text(distanceText!,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.teal,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
