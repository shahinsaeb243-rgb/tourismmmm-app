import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/place.dart';
import '../services/location_service.dart';
import '../services/user_posts_storage.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  PlaceCategory _category = PlaceCategory.attraction;
  String? _imagePath;
  bool _saving = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) {
      setState(() => _imagePath = picked.path);
    }
  }

  Future<void> _savePost() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('لطفاً اسم مکان را وارد کنید')));
      return;
    }

    setState(() => _saving = true);
    try {
      final position = await LocationService.getCurrentLocation();

      final post = Place(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        lat: position.latitude,
        lng: position.longitude,
        images: _imagePath != null ? [_imagePath!] : [],
        category: _category,
        address: 'ثبت‌شده توسط شما',
      );

      await UserPostsStorage.addPost(post);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('پست جدید')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(14),
                ),
                child: _imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(_imagePath!, fit: BoxFit.cover),
                      )
                    : const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_a_photo, size: 36, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('افزودن عکس', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'اسم مکان',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'توضیحات / تجربه شما',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<PlaceCategory>(
              value: _category,
              decoration: InputDecoration(
                labelText: 'دسته‌بندی',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: [
                PlaceCategory.attraction,
                PlaceCategory.hotel,
                PlaceCategory.restaurant,
              ]
                  .map((c) => DropdownMenuItem(value: c, child: Text('${c.icon}  ${c.label}')))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 10),
            const Text(
              'موقعیت مکانی فعلی شما به‌طور خودکار برای این پست ثبت می‌شود.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _savePost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('ثبت پست'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
