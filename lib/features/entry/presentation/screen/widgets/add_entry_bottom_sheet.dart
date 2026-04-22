import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geocoding/geocoding.dart';
import 'category_icon_picker.dart';
import '../../providers/entry_provider.dart';

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
    _fetchAddress();
  }

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
          // Auto-fill description with address if empty
          if (_descController.text.isEmpty) {
            _descController.text = _address;
          }
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
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        ),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add New Location',
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D3142),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, size: 24.sp, color: Colors.grey.shade400),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              Text(
                'Save this pinpoint to your personal map.',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: Colors.grey.shade500,
                ),
              ),
              SizedBox(height: 18.h),

              // FORM FIELDS
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
                decoration:  InputDecoration(
                  labelText: 'Location Name',
                  labelStyle: TextStyle(
                    fontSize: 12.h
                  ),
                  hintText: 'e.g. My Favorite Cafe',
                ),
              ),
              SizedBox(height: 18.h),
              TextField(
                controller: _descController,
                maxLines: 2,
                decoration:  InputDecoration(
                  labelText: 'Description / Notes',
                   labelStyle: TextStyle(
                    fontSize: 12.h
                  ),
                  hintText: 'What makes this place special?',
                ),
              ),
              SizedBox(height: 12.h),

              // CATEGORY PICKER
              CategoryIconPicker(
                selectedId: _selectedCategoryId,
                onSelect: (id) => setState(() => _selectedCategoryId = id),
              ),
              SizedBox(height: 12.h),

              // COORDINATES CARD
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.orange, size: 22.sp),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.latitude.toStringAsFixed(4)}° N, ${widget.longitude.toStringAsFixed(4)}° E',
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
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

              // SAVE BUTTON
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton.icon(
                  onPressed: _onSave,
                  icon: const Icon(Icons.save),
                  label: Text(
                    'Save Location',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
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
