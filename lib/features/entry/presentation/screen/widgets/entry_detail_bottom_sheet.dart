import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:galli_maps_assignment/core/constants/app_constants.dart';
import 'package:galli_maps_assignment/features/entry/domain/entities/entry_entity.dart';
import 'package:galli_maps_assignment/features/entry/presentation/providers/entry_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class EntryDetailBottomSheet extends ConsumerWidget {
  final EntryEntity entry;

  const EntryDetailBottomSheet({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = kCategories.firstWhere(
      (c) => c.id == entry.categoryId,
      orElse: () => kCategories.last,
    );

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(category.icon, color: Colors.red, size: 24.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2D3142),
                      ),
                    ),
                    Text(
                      category.label.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, size: 20.sp, color: Colors.grey.shade400),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Text(
            'DESCRIPTION',
            style: GoogleFonts.poppins(
              fontSize: 9.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            entry.description,
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              color: const Color(0xFF2D3142),
              height: 1.5,
            ),
          ),
          SizedBox(height: 24.h),
          _buildInfoRow(Icons.location_on_outlined, 'Coordinates',
              '${entry.latitude.toStringAsFixed(4)}° N, ${entry.longitude.toStringAsFixed(4)}° E'),
          SizedBox(height: 12.h),
          _buildInfoRow(Icons.calendar_today_outlined, 'Saved on',
              '${entry.createdAt.day} ${_getMonth(entry.createdAt.month)} ${entry.createdAt.year}'),
          SizedBox(height: 32.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.read(entryProvider.notifier).deleteEntry(entry.id);
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.delete_outline, size: 18.sp),
                  label: Text('Delete Place', style: TextStyle(fontSize: 12.sp)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: Text('Close', style: TextStyle(fontSize: 12.sp)),
                ),
              ),
            ],
          ),
          SizedBox(height: 75.h),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: Colors.grey.shade400),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 9.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade400,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                color: const Color(0xFF2D3142),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getMonth(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}
