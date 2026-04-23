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
import 'dart:math' show Point;
import 'package:flutter/services.dart';

import '../../../../core/constants/app_constants.dart';
import '../providers/entry_provider.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> with WidgetsBindingObserver {
  MapLibreMapController? _controller;
  bool _isLoadingLocation = true;

  LatLng _currentCenter = const LatLng(AppConstants.defaultLat, AppConstants.defaultLng);
  String _currentAddress = 'Fetching address...';
  LatLng? _userLocation;
  bool _needsLocationRetry = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _handlePermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _needsLocationRetry) {
      _needsLocationRetry = false;
      _handlePermissions();
    }
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
      _needsLocationRetry = true;
      _showErrorSnackBar(
        'GPS is turned off.',
        actionLabel: 'TURN ON',
        onAction: () async {
          await Geolocator.openLocationSettings();
        },
        duration: const Duration(seconds: 3),
        actionColor: Colors.green,
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

    if (_controller != null) {
      _addUserLocationCircle();
    }
    _onCameraIdle();
  }

  void _showErrorSnackBar(String message, {String? actionLabel, VoidCallback? onAction, Duration? duration, Color? actionColor}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: duration ?? const Duration(seconds: 4),
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: actionColor ?? Colors.white,
                onPressed: onAction ?? () {},
              )
            : null,
      ),
    );
  }

  void _onMapCreated(MapLibreMapController controller) {
    _controller = controller;

    _controller?.addListener(() {
      if (_controller != null && _controller!.isCameraMoving) {
        if (_controller!.cameraPosition != null) {
          setState(() {
            _currentCenter = _controller!.cameraPosition!.target;
          });
        }
      }
    });

   
    _controller?.onSymbolTapped.add(_onSymbolTapped);
    _controller?.onCircleTapped.add(_onCircleTapped);

 
  }

  void _onStyleLoaded() {
    if (_controller != null) {
      _loadCategoryMarkers(_controller!);
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
      controller.addCircle(
        CircleOptions(
          geometry: _userLocation!,
          circleColor: '#2196F3',
          circleRadius: 8.0,
          circleOpacity: 1.0,
          circleStrokeColor: '#FFFFFF',
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
      return;
    }

    final entries = ref.read(entryProvider);

    try {
      controller.clearCircles();
      controller.clearSymbols().then((_) async {
        if (_userLocation != null) {
          _addUserLocationCircle();
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
              circleRadius: 15.0,
              circleOpacity: 0.0,
            ),
            {'id': entry.id},
          );
        }
      });
    } catch (e) {
      debugPrint('Error refreshing markers: $e');
    }
  }

  Future<void> _loadCategoryMarkers(MapLibreMapController controller) async {
    try {
      for (final category in kCategories) {
        final bytes = await _createMarkerImage(category.icon);
        await controller.addImage(category.id, bytes);
      }
      _refreshMarkers();
    } catch (e) {
      debugPrint('Error loading category markers: $e');
    }
  }

  Future<Uint8List> _createMarkerImage(IconData icon) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = 100.0;
    
    final paint = Paint()..color = Colors.red;
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2, paint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 6.0;
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2 - 3, borderPaint);
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
              compassEnabled: false,
              attributionButtonMargins: const Point(-100, -100)
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

          Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 24.h),
              child: Icon(
                Icons.location_on,
                color: Colors.red,
                size: 32.sp,
              ),
            ),
          ),

          Positioned(
            right: 16.w,
            top: 240.h,
            child: Column(
              children: [
                _buildSideButton(Icons.my_location, onPressed: _handlePermissions),
              ],
            ),
          ),

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

          if (_isLoadingLocation)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: const Center(child: CircularProgressIndicator(color: Colors.red)),
            ),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 80.h),
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
