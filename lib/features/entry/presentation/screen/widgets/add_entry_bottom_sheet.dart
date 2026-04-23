import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geocoding/geocoding.dart';
import 'category_icon_picker.dart';
import '../../providers/entry_provider.dart';

/// Bottom sheet for adding a new location entry.
/// Shows form with title, description, category picker, and location info.
class AddEntryBottomSheet extends ConsumerStatefulWidget {
  final double latitude;
  final double longitude;

  const AddEntryBottomSheet({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  ConsumerState<AddEntryBottomSheet> createState() => _AddEntryBottomSheetState();
}

class _AddEntryBottomSheetState extends ConsumerState<AddEntryBottomSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedCategoryId = 'food';
  String _address = 'Fetching address...';

  @override
  void initState() {
    super.initState();
    // Lookup human-readable address from coordinates
    _fetchAddress();
  }

  /// Converts coordinates to address using geocoding service
  Future<void> _fetchAddress() async {
    try {
      final placemarks = await placemarkFromCoordinates(
        widget.latitude,
        widget.longitude,
      );
      if (placemarks.isNotEmpty && mounted) {
        final p = placemarks.first;
        setState(() {
          _address = '${p.name}, ${p.locality}, ${p.country}';
        });
      }
    } catch (_) {
      if (mounted) setState(() => _address = 'Unknown location');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  /// Validates form and saves entry to local storage
  Future<void> _onSave() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a location name.')),
      );
      return;
    }

    await ref.read(entryProvider.notifier).addEntry(
          title: _titleController.text,
          description: _descController.text.isNotEmpty ? _descController.text : _address,
          categoryId: _selectedCategoryId,
          latitude: widget.latitude,
          longitude: widget.longitude,
        );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add New Location',
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D3142),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, size: 22.sp, color: Colors.grey.shade400),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                'Save this pinpoint to your personal map.',
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  color: Colors.grey.shade500,
                ),
              ),
              SizedBox(height: 20.h),

              Text(
                'PLACE DETAILS',
                style: GoogleFonts.poppins(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade400,
                  letterSpacing: 1.0,
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: _titleController,
                style: TextStyle(fontSize: 13.sp),
                decoration: InputDecoration(
                  labelText: 'Location Name',
                  labelStyle: TextStyle(fontSize: 11.sp),
                  hintText: 'e.g. My Nepal Cafe',
                  hintStyle: TextStyle(fontSize: 11.sp),
                ),
              ),
              SizedBox(height: 18.h),
              TextField(
                controller: _descController,
                maxLines: 2,
                style: TextStyle(fontSize: 13.sp),
                decoration: InputDecoration(
                  labelText: 'Description / Notes',
                  labelStyle: TextStyle(fontSize: 11.sp),
                  hintText: 'What makes this place special?',
                  hintStyle: TextStyle(fontSize: 11.sp),
                ),
              ),
              SizedBox(height: 14.h),

              CategoryIconPicker(
                selectedId: _selectedCategoryId,
                onSelect: (id) => setState(() => _selectedCategoryId = id),
              ),
              SizedBox(height: 14.h),

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.red, size: 20.sp),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.latitude.toStringAsFixed(4)}° N, ${widget.longitude.toStringAsFixed(4)}° E',
                            style: GoogleFonts.poppins(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2D3142),
                            ),
                          ),
                          Text(
                            _address,
                            style: GoogleFonts.poppins(
                              fontSize: 10.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              SizedBox(
                width: double.infinity,
                height: 44.h,
                child: ElevatedButton.icon(
                  onPressed: _onSave,
                  icon: Icon(Icons.save, size: 20.sp),
                  label: Text(
                    'Save Location',
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 75.h),
            ],
          ),
        ),
      ),
    );
  }
}
