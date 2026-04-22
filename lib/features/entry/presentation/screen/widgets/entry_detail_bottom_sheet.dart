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
    // Find category for icon
    final category = kCategories.firstWhere(
      (c) => c.id == entry.categoryId,
      orElse: () => kCategories.last,
    );

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
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
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(category.icon, color: Colors.orange, size: 28.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      style: GoogleFonts.poppins(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2D3142),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          category.label,
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange,
                          ),
                        ),
                        Text(
                          ' • Saved on ${entry.createdAt.day}/${entry.createdAt.month}/${entry.createdAt.year}',
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Text(
            'DESCRIPTION',
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            entry.description,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: const Color(0xFF2D3142),
              height: 1.5,
            ),
          ),
          SizedBox(height: 24.h),
          _buildInfoRow(Icons.location_on_outlined, 'Coordinates', '${entry.latitude.toStringAsFixed(4)}° N, ${entry.longitude.toStringAsFixed(4)}° E'),
          SizedBox(height: 32.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.read(entryProvider.notifier).deleteEntry(entry.id);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete Place'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red,
                    elevation: 0,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: Colors.grey.shade400),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade400,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                color: const Color(0xFF2D3142),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
