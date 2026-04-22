import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galli_maps_assignment/features/entry/presentation/screen/widgets/map_widgets.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:galli_maps_assignment/features/entry/presentation/screen/widgets/entry_detail_bottom_sheet.dart';
import 'package:galli_maps_assignment/features/entry/presentation/screen/widgets/add_entry_bottom_sheet.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

import '../../../../core/constants/app_constants.dart';
import '../providers/entry_provider.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  MapLibreMapController? _controller;
  bool _isLoadingLocation = true;
  
  // Real-time location state for the bottom card
  LatLng _currentCenter = const LatLng(AppConstants.defaultLat, AppConstants.defaultLng);
  String _currentAddress = 'Fetching address...';

  @override
  void initState() {
    super.initState();
    _handlePermissions();
  }

  Future<void> _handlePermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showErrorSnackBar('Location services are disabled.');
      setState(() => _isLoadingLocation = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showErrorSnackBar('Location permissions are denied.');
        setState(() => _isLoadingLocation = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showErrorSnackBar('Permissions are permanently denied.');
      setState(() => _isLoadingLocation = false);
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    _controller?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude),
        14.0,
      ),
    );
    setState(() => _isLoadingLocation = false);
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _onMapCreated(MapLibreMapController controller) {
    _controller = controller;
    
    // Listen for camera changes while moving for real-time coordinate display
    _controller?.addListener(() {
      if (_controller != null && _controller!.isCameraMoving) {
        if (_controller!.cameraPosition != null) {
          setState(() {
            _currentCenter = _controller!.cameraPosition!.target;
          });
        }
      }
    });

    // Handle marker taps for BOTH symbols and circles for safety
    _controller?.onSymbolTapped.add(_onSymbolTapped);
    _controller?.onCircleTapped.add(_onCircleTapped);

    // Load category icons and then refresh
    _loadCategoryMarkers(controller);
  }

  void _onCircleTapped(Circle circle) {
    _handleMarkerTap(circle.data?['id']);
  }

  void _onSymbolTapped(Symbol symbol) {
    _handleMarkerTap(symbol.data?['id']);
  }

  void _handleMarkerTap(dynamic entryId) {
    if (entryId == null) return;
    
    final entries = ref.read(entryProvider);
    try {
      final entry = entries.firstWhere((e) => e.id == entryId);
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => EntryDetailBottomSheet(entry: entry),
      );
    } catch (e) {
      debugPrint('Entry not found: $e');
    }
  }

  void _refreshMarkers() {
    final controller = _controller;
    if (controller == null) return;

    final entries = ref.read(entryProvider);
    debugPrint('Refreshing ${entries.length} categoried markers on map...');
    
    try {
      controller.clearSymbols();
      controller.clearCircles().then((_) {
        for (final entry in entries) {
          // Use the categoryId as the icon name we loaded in _onMapCreated
          controller.addSymbol(
            SymbolOptions(
              geometry: LatLng(entry.latitude, entry.longitude),
              iconImage: entry.categoryId, 
              iconSize: 1.0, 
            ),
            {'id': entry.id},
          );
          
          // Optional: Keep a small circle underneath for shadow/border effect if desired
          controller.addCircle(
            CircleOptions(
              geometry: LatLng(entry.latitude, entry.longitude),
              circleColor: '#FF9800',
              circleRadius: 10.0,
              circleOpacity: 0.1, // Very subtle shadow
            ),
          );
        }
      });
    } catch (e) {
      debugPrint('Error refreshing markers: $e');
    }
  }

  // Generates a custom bitmap image for a category
  Future<void> _loadCategoryMarkers(MapLibreMapController controller) async {
    for (final category in kCategories) {
      final bytes = await _createMarkerImage(category.icon);
      await controller.addImage(category.id, bytes);
    }
    // Initial refresh once icons are loaded
    _refreshMarkers();
  }

  Future<Uint8List> _createMarkerImage(IconData icon) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = 100.0;
    
    // Draw background circle
    final paint = Paint()..color = Colors.orange;
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2, paint);
    
    // Draw border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 6.0;
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2 - 3, borderPaint);

    // Draw Icon
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: 60.0,
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        color: Colors.white,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(size / 2 - textPainter.width / 2, size / 2 - textPainter.height / 2),
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  // Fetch address when map stops moving
  void _onCameraIdle() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentCenter.latitude,
        _currentCenter.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _currentAddress = '${place.name}, ${place.locality}, ${place.country}';
        });
      }
    } catch (e) {
      setState(() {
        _currentAddress = 'Unknown location';
      });
    }
  }

  // Show Add Entry bottom sheet
  void _onAddLocation() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AddEntryBottomSheet(
        latitude: _currentCenter.latitude,
        longitude: _currentCenter.longitude,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(entryProvider, (_, __) => _refreshMarkers());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
  
          Positioned.fill(
            child: MapLibreMap(
              styleString: AppConstants.mapStyleUrl,
              initialCameraPosition: const CameraPosition(
                target: LatLng(AppConstants.defaultLat, AppConstants.defaultLng),
                zoom: AppConstants.defaultZoom,
              ),
              onMapCreated: _onMapCreated,
              onStyleLoadedCallback: _refreshMarkers,
              myLocationEnabled: true,
              onCameraIdle: _onCameraIdle,
              trackCameraPosition: true,
            ),
          ),

       
          SafeArea(
            child: Column(
              children: [
                const MapTopBar(),
                SizedBox(height: 12.h),
                const FloatingSearchBar(),
                SizedBox(height: 16.h),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: StatusBadge(),
                  ),
                ),
              ],
            ),
          ),

          // 3. CENTER PIN (Always present like the image)
          Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 24.h), // Offset to point tip
              child: Icon(
                Icons.location_on,
                color: Colors.orange,
                size: 32.sp,
              ),
            ),
          ),

          // 4. RIGHT SIDE CONTROLS
          Positioned(
            right: 16.w,
            top: 240.h,
            child: Column(
              children: [
                _buildSideButton(Icons.layers_outlined),
                SizedBox(height: 12.h),
                _buildSideButton(Icons.my_location, onPressed: _handlePermissions),
              ],
            ),
          ),

          // 5. BOTTOM PREVIEW CARD
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: LocationPreviewCard(
              address: _currentAddress,
              latitude: _currentCenter.latitude,
              longitude: _currentCenter.longitude,
              onAdd: _onAddLocation,
            ),
          ),

          // 6. LOADING OVERLAY
          if (_isLoadingLocation)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: const Center(child: CircularProgressIndicator(color: Colors.orange)),
            ),
        ],
      ),
      // ADDED Prominent FAB to make it easy to find "Add Entry"
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 120.h), // Stay above the preview card
        child: FloatingActionButton(
          onPressed: _onAddLocation,
          backgroundColor: Colors.orange,
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  Widget _buildSideButton(IconData icon, {VoidCallback? onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed ?? () {},
        icon: Icon(icon, color: const Color(0xFF2D3142), size: 22.sp),
      ),
    );
  }
}
