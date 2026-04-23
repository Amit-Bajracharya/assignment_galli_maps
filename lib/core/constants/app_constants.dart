import 'package:flutter/material.dart';

class AppConstants {
  static const String mapStyleUrl =
      'https://map-init.gallimap.com/styles/light/style.json';
  static const String entriesBoxName = 'entries_box';
  static const double defaultLat  = 27.7172;
  static const double defaultLng  = 85.3240;
  static const double defaultZoom = 12.0;
}

class CategoryIcon {
  final String id;
  final String label;
  final IconData icon;
  const CategoryIcon({required this.id, required this.label, required this.icon});
}


const List<CategoryIcon> kCategories = [
  CategoryIcon(id: 'food',   label: 'Food',      icon: Icons.restaurant),
  CategoryIcon(id: 'home',   label: 'Home',      icon: Icons.home),
  CategoryIcon(id: 'work',   label: 'Work',      icon: Icons.work),
  CategoryIcon(id: 'travel', label: 'Travel',    icon: Icons.flight),
  CategoryIcon(id: 'shop',   label: 'Shop',      icon: Icons.shopping_bag),
  CategoryIcon(id: 'health', label: 'Health',    icon: Icons.local_hospital),
  CategoryIcon(id: 'edu',    label: 'Education', icon: Icons.school),
  CategoryIcon(id: 'other',  label: 'Other',     icon: Icons.place),
];
