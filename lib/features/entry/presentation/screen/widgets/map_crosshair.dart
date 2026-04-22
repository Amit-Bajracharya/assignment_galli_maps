import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MapCrosshair extends StatelessWidget {
  const MapCrosshair({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [ 
          Icon(
            Icons.add_location,
            size: 48.sp, 
            color: Theme.of(context).primaryColor, 
            shadows: const [
              Shadow(
                blurRadius: 10,
                color: Colors.black26,
              )
            ],
          ),
          SizedBox(height: 24.h), 
        ],
      ),
    );
  }
}
