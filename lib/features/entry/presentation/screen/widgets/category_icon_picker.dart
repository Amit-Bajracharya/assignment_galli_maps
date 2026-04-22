import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:galli_maps_assignment/core/constants/app_constants.dart';
import 'package:google_fonts/google_fonts.dart';


class CategoryIconPicker extends StatelessWidget {
  final String selectedId;
  final void Function(String id) onSelect;

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
          height: 80.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: kCategories.length,
            separatorBuilder: (context, index) => SizedBox(width: 16.w),
            itemBuilder: (context, index) {
              final cat = kCategories[index];
              final isSelected = cat.id == selectedId;
              
              return GestureDetector(
                onTap: () => onSelect(cat.id),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.orange : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : [],
                      ),
                      child: Icon(
                        cat.icon,
                        size: 20.sp,
                        color: isSelected ? Colors.white : Colors.grey.shade500,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      cat.label,
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? Colors.orange : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
