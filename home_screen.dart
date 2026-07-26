import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../data/mock_data.dart';
import '../models/place.dart';
import '../services/location_service.dart';
import '../services/places_api_service.dart';
import '../services/user_posts_storage.dart';
import '../widgets/place_list_item.dart';
import 'place_detail_screen.dart';
import 'add_post_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;
  Position? _currentPosition;
  String? _locationError;
  bool _loadingLocation = false;

  List<Place> _nearbyRestaurants = [];
  List<Place> _nearbyGasStations = [];
  bool _loadingNearby = false;

  List<Place> _userPosts = [];

  @override
  void initState() {
    super.initState();
    _refreshLocation();
    _loadUserPosts();
  }

  Future<void> _loadUserPosts() async {
    final posts = await UserPostsStorage.getAllPosts();
    setState(() => _userPosts = posts);
  }

  Future<void> _refreshLocation() async {
    setState(() {
      _loadingLocation = true;
      _locationError = null;
    });
    try {
      final pos = await LocationService.getCurrentLocation();
      setState(() => _currentPosition = pos);
      await _loadNearbyPlaces();
    } catch (e) {
      setState(() => _locationError = e.toString());
    } finally {
      setState(() => _loadingLocation = false);
    }
  }

  Future<void> _loadNearbyPlaces() async {
    if (_currentPosition == null) return;
    setState(() => _loadingNearby = true);
    final results = await Future.wait([
      PlacesApiService.getNearbyPlaces(
          lat: _currentPosition!.latitude,
          lng: _currentPosition!.longitude,
          type: 'restaurant'),
      PlacesApiService.getNearbyPlaces(
          lat: _currentPosition!.latitude,
          lng: _currentPosition!.longitude,
          type: 'gas_station'),
    ]);
    setState(() {
      _nearbyRestaurants = results[0];
      _nearbyGasStations = results[1];
      _loadingNearby = false;
    });
  }

  String? _distanceTo(Place place) {
    if (_currentPosition == null) return null;
    final meters = LocationService.distanceInMeters(
        _currentPosition!.latitude, _currentPosition!.longitude, place.lat, place.lng);
    return LocationService.formatDistance(meters);
  }

  void _openDetail(Place place) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlaceDetailScreen(place: place, distanceText: _distanceTo(place)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('همسفر من', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.gps_fixed),
            onPressed: _refreshLocation,
            tooltip: 'به‌روزرسانی موقعیت',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _tabIndex == 3
          ? FloatingActionButton(
              backgroundColor: Colors.teal,
              onPressed: () async {
                final added = await Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const AddPostScreen()));
                if (added == true) _loadUserPosts();
              },
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
        selectedItemColor: Colors.teal,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Text('🏛️', style: TextStyle(fontSize: 20)), label: 'جاذبه‌ها'),
          BottomNavigationBarItem(icon: Text('🏨', style: TextStyle(fontSize: 20)), label: 'اقامتگاه‌ها'),
          BottomNavigationBarItem(icon: Text('📍', style: TextStyle(fontSize: 20)), label: 'نزدیک من'),
          BottomNavigationBarItem(icon: Text('✍️', style: TextStyle(fontSize: 20)), label: 'پست‌های من'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_tabIndex) {
      case 0:
        return _buildList(attractions);
      case 1:
        return _buildList(hotels);
      case 2:
        return _buildNearMeTab();
      case 3:
        return _buildMyPostsTab();
      default:
        return const SizedBox();
    }
  }

  Widget _buildList(List<Place> places) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: places.length,
      itemBuilder: (context, i) => PlaceListItem(
        place: places[i],
        distanceText: _distanceTo(places[i]),
        onTap: () => _openDetail(places[i]),
      ),
    );
  }

  Widget _buildNearMeTab() {
    if (_loadingLocation) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_locationError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_off, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(_locationError!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _refreshLocation, child: const Text('تلاش مجدد')),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            labelColor: Colors.teal,
            tabs: [
              Tab(text: '⛽ پمپ بنزین'),
              Tab(text: '🍽️ رستوران'),
            ],
          ),
          if (_loadingNearby) const LinearProgressIndicator(),
          Expanded(
            child: TabBarView(
              children: [
                _nearbyGasStations.isEmpty && !_loadingNearby
                    ? const Center(child: Text('پمپ‌بنزینی در این نزدیکی پیدا نشد'))
                    : _buildList(_nearbyGasStations),
                _nearbyRestaurants.isEmpty && !_loadingNearby
                    ? const Center(child: Text('رستورانی در این نزدیکی پیدا نشد'))
                    : _buildList(_nearbyRestaurants),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyPostsTab() {
    if (_userPosts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('هنوز پستی ثبت نکرده‌اید. با دکمه + یک پست جدید اضافه کنید.',
              textAlign: TextAlign.center),
        ),
      );
    }
    return _buildList(_userPosts);
  }
}
