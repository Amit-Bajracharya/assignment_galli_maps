import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class MapTopBar extends StatelessWidget {
  const MapTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.menu, size: 28.sp),
          ),
          Text(
            'Galli Maps',
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D3142),
            ),
          ),
          CircleAvatar(
            radius: 18.r,
            backgroundColor: Colors.orange.shade100,
            child: Icon(Icons.person, color: Colors.orange, size: 20.sp),
          ),
        ],
      ),
    );
  }
}

class FloatingSearchBar extends StatelessWidget {
  const FloatingSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.orange, size: 22.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Search for destination...',
              style: GoogleFonts.poppins(
                color: Colors.grey.shade500,
                fontSize: 14.sp,
              ),
            ),
          ),
          Icon(Icons.mic, color: Colors.grey.shade400, size: 22.sp),
        ],
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.r,
            height: 8.r,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            'SECURE ENCRYPTION ACTIVE',
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: Colors.green.shade700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class LocationPreviewCard extends StatelessWidget {
  final String address;
  final double latitude;
  final double longitude;
  final VoidCallback onAdd;

  const LocationPreviewCard({
    super.key,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F4),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Location',
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2D3142),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      address,
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.gps_fixed, color: Colors.orange, size: 24.sp),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              _buildCoordChip('LATITUDE', '${latitude.toStringAsFixed(4)}° N'),
              SizedBox(width: 12.w),
              _buildCoordChip('LONGITUDE', '${longitude.toStringAsFixed(4)}° E'),
              const Spacer(),
              _buildFab(),
            ],
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildCoordChip(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 9.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D3142),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFab() {
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(Icons.push_pin, color: Colors.white, size: 28.sp),
      ),
    );
  }
}
