import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 72.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.map_outlined,
                  activeIcon: Icons.map,
                  label: 'MAP',
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.search,
                  activeIcon: Icons.search,
                  label: 'SEARCH',
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.bookmark_outline,
                  activeIcon: Icons.bookmark,
                  label: 'SAVED',
                  isElevated: true,
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.list_alt_outlined,
                  activeIcon: Icons.list_alt,
                  label: 'HISTORY',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    bool isElevated = false,
  }) {
    final isActive = navigationShell.currentIndex == index;

    return GestureDetector(
      onTap: () => navigationShell.goBranch(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72.w,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isElevated)
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: isActive ? Colors.orange : Colors.orange.shade50,
                  shape: BoxShape.circle,
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Icon(
                  isActive ? activeIcon : icon,
                  size: 22.sp,
                  color: isActive ? Colors.white : Colors.orange,
                ),
              )
            else
              Icon(
                isActive ? activeIcon : icon,
                size: 24.sp,
                color: isActive ? Colors.orange : Colors.grey.shade400,
              ),
            if (!isElevated) SizedBox(height: 4.h),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 9.sp,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? Colors.orange : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
