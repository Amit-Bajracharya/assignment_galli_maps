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

  // User's current location for the blue circle marker
  LatLng? _userLocation;

  @override
  void initState() {
    super.initState();
    _handlePermissions();
  }

  Future<void> _handlePermissions() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showErrorSnackBar('Location permissions are denied.');
        permission = await Geolocator.requestPermission();
        setState(() {
          _isLoadingLocation = false;
          _currentAddress = 'Location Access Denied';
        });
        _onCameraIdle();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showErrorSnackBar(
        'Location permissions are permanently denied.',
        actionLabel: 'SETTINGS',
        onAction: () async {
          await Geolocator.openAppSettings();
        },
      );
      setState(() {
        _isLoadingLocation = false;
        _currentAddress = 'Access Permanently Denied';
      });
      _onCameraIdle();
      return;
    }

 
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showErrorSnackBar(
        'GPS is turned off.',
        actionLabel: 'TURN ON',
        onAction: () async {
          await Geolocator.openLocationSettings();
          _handlePermissions();
        },
        duration: const Duration(seconds: 3), // Auto-dismiss after 3 seconds
      );
      setState(() {
        _isLoadingLocation = false;
        _currentAddress = 'GPS Disabled';
      });
      _onCameraIdle();
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    final userLatLng = LatLng(position.latitude, position.longitude);

    setState(() {
      _userLocation = userLatLng;
      _isLoadingLocation = false;
    });

    _controller?.animateCamera(
      CameraUpdate.newLatLngZoom(userLatLng, 14.0),
    );

    // Only add circle if map style is already loaded, otherwise it will be added in _onStyleLoaded
    if (_controller != null) {
      _addUserLocationCircle();
    }
    _onCameraIdle();
  }

  void _showErrorSnackBar(String message, {String? actionLabel, VoidCallback? onAction, Duration? duration}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: duration ?? const Duration(seconds: 4), // Default 4 seconds
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction ?? () {},
              )
            : null,
      ),
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

    // NOTE: Don't load markers here - wait for onStyleLoadedCallback
    // _loadCategoryMarkers will be called after style is fully loaded
  }

  void _onStyleLoaded() {
    debugPrint('✅ Map style loaded successfully');
    if (_controller != null) {
      _loadCategoryMarkers(_controller!);
      // Also add user location circle if we have it
      if (_userLocation != null) {
        _addUserLocationCircle();
      }
    }
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

  void _addUserLocationCircle() {
    final controller = _controller;
    if (controller == null || _userLocation == null) return;

    try {
      // Small solid blue dot for user location
      controller.addCircle(
        CircleOptions(
          geometry: _userLocation!,
          circleColor: '#2196F3', // Blue color
          circleRadius: 8.0, // Small 8 meters radius
          circleOpacity: 1.0, // Fully opaque
          circleStrokeColor: '#FFFFFF', // White border
          circleStrokeWidth: 3.0,
        ),
        {'type': 'user_location'},
      );
    } catch (e) {
      debugPrint('Error adding user location circle: $e');
    }
  }

  void _refreshMarkers() {
    final controller = _controller;
    if (controller == null) {
      debugPrint('⚠️ Cannot refresh markers - controller is null');
      return;
    }

    final entries = ref.read(entryProvider);
    debugPrint('📍 Refreshing ${entries.length} markers on map...');

    try {
      controller.clearCircles();
      controller.clearSymbols().then((_) async {
        debugPrint('✅ Cleared existing markers, adding ${entries.length} entries...');

        // Re-add user location circle first (if available)
        if (_userLocation != null) {
          _addUserLocationCircle();
          debugPrint('📍 Added user location circle');
        }

        for (final entry in entries) {
          await controller.addSymbol(
            SymbolOptions(
              geometry: LatLng(entry.latitude, entry.longitude),
              iconImage: entry.categoryId,
              iconSize: 1.0,
            ),
            {'id': entry.id},
          );

          await controller.addCircle(
            CircleOptions(
              geometry: LatLng(entry.latitude, entry.longitude),
              circleColor: '#000000',
              circleRadius: 15.0, // Large hit area for easy tapping
              circleOpacity: 0.0, // Invisible hit area
            ),
            {'id': entry.id},
          );
        }
        debugPrint('✅ Added ${entries.length} markers to map');
      });
    } catch (e, stack) {
      debugPrint('❌ Error refreshing markers: $e');
      debugPrint(stack.toString());
    }
  }

  // Generates a custom bitmap image for a category
  Future<void> _loadCategoryMarkers(MapLibreMapController controller) async {
    debugPrint('🎨 Loading category marker images...');
    try {
      for (final category in kCategories) {
        final bytes = await _createMarkerImage(category.icon);
        await controller.addImage(category.id, bytes);
        debugPrint('✅ Added image for category: ${category.id}');
      }
      debugPrint('🎨 All category images loaded, refreshing markers...');
      // Initial refresh once icons are loaded
      _refreshMarkers();
    } catch (e, stack) {
      debugPrint('❌ Error loading category markers: $e');
      debugPrint(stack.toString());
    }
  }

  Future<Uint8List> _createMarkerImage(IconData icon) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = 100.0;
    
    // Draw background circle
    final paint = Paint()..color = Colors.red;
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
              onStyleLoadedCallback: _onStyleLoaded,
              myLocationEnabled: true,
              onCameraIdle: _onCameraIdle,
              trackCameraPosition: true,
            ),
          ),

       
          SafeArea(
            child: Column(
              children: [
                const MapTopBar(),
                SizedBox(height: 16.h),
              
              ],
            ),
          ),

          // 3. CENTER PIN (Always present like the image)
          Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 24.h), // Offset to point tip
              child: Icon(
                Icons.location_on,
                color: Colors.red,
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
              
            ),
          ),

          // 6. LOADING OVERLAY
          if (_isLoadingLocation)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: const Center(child: CircularProgressIndicator(color: Colors.red)),
            ),
        ],
      ),
      // ADDED Prominent FAB to make it easy to find "Add Entry"
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 80.h), // Stay above the preview card
        child: FloatingActionButton(
          onPressed: _onAddLocation,
          backgroundColor: Colors.red,
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
