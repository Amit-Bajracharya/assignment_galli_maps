import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/entry_entity.dart';
import '../providers/entry_provider.dart';
import 'widgets/entry_detail_bottom_sheet.dart';
import 'widgets/map_widgets.dart';

class SavedEntriesScreen extends ConsumerWidget {
  const SavedEntriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(entryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MapTopBar(),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0.h, 20.w, 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Places',
                    style: GoogleFonts.poppins(
                      fontSize: 21.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2D3142),
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    'View and manage your saved locations',
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            Expanded(
              child: entries.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.separated(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      itemCount: entries.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) =>
                          _buildEntryCard(context, entries[index], ref),
                    ),
            ),
          ],
        ),
      ),
    
    );
  }

  Widget _buildEntryCard(
    BuildContext context,
    EntryEntity entry,
    WidgetRef ref,
  ) {
    final category = kCategories.firstWhere(
      (c) => c.id == entry.categoryId,
      orElse: () => kCategories.last,
    );

    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        ref.read(entryProvider.notifier).deleteEntry(entry.id);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (context) => EntryDetailBottomSheet(entry: entry),
          );
        },
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(category.icon, color: Colors.red, size: 20.sp),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2D3142),
                      ),
                    ),
                    if (entry.description.isNotEmpty)
                      Text(
                        entry.description,
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          color: Colors.grey.shade500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 10.sp, color: Colors.red),
                        SizedBox(width: 4.w),
                        Text(
                          '${entry.latitude.toStringAsFixed(3)},  ${entry.longitude.toStringAsFixed(3)}',
                          style: GoogleFonts.poppins(
                            fontSize: 9.sp,
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                _relativeTime(entry.createdAt),
                style: GoogleFonts.poppins(
                  fontSize: 9.sp,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 190.w,
                height: 180.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Icon(
                      Icons.add_location_alt_rounded,
                      size: 40.sp,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: -20.w,
                top: 20.h,
                child: Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.travel_explore,
                    size: 20.sp,
                    color: Colors.green,
                  ),
                ),
              ),
              Positioned(
                right: -10.w,
                bottom: 10.h,
                child: Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.location_on,
                    size: 20.sp,
                    color: Colors.green.shade800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 32.h),
          Text(
            'No places saved yet',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D3142),
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 48.w),
            child: Text(
              'Start exploring to save your favorite spots. Your personal map is waiting to be filled with adventures.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 15.h),
          ElevatedButton.icon(
            onPressed: () {
              StatefulNavigationShell.of(context).goBranch(0);
            },
            icon: const Icon(Icons.explore, size: 18), 
            label: const Text(
              'EXPLORE MAP',
              style: TextStyle(fontSize: 12), 
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 10.h,
              ),
              minimumSize: const Size(100, 38),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _relativeTime(DateTime createdAt) {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30)
      return '${(diff.inDays / 7).floor()} week${(diff.inDays / 7).floor() > 1 ? 's' : ''} ago';
    return '${(diff.inDays / 30).floor()} month${(diff.inDays / 30).floor() > 1 ? 's' : ''} ago';
  }
}
