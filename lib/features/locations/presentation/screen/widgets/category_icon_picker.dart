import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:galli_maps_assignment/core/constants/app_constants.dart';
import 'package:google_fonts/google_fonts.dart';


class CategoryIconPicker extends StatelessWidget {
  final String selectedId;
  final Function(String) onSelect;

  const CategoryIconPicker({
    super.key,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT CATEGORY',
          style: GoogleFonts.poppins(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade400,
            letterSpacing: 1.0,
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 65.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: kCategories.length,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final cat = kCategories[index];
              final isSelected = selectedId == cat.id;
              
              return GestureDetector(
                onTap: () => onSelect(cat.id),
                child: Container(
                  width: 75.w,
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.red : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isSelected ? Colors.red : Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        cat.icon,
                        color: isSelected ? Colors.white : const Color(0xFF2D3142),
                        size: 21.sp,
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        cat.label,
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}