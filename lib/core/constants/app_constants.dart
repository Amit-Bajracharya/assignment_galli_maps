import 'package:flutter/material.dart';

/// Global constants used throughout the app.
class AppConstants {
  // Galli Maps tile server URL with custom style
  static const String mapStyleUrl =
      'https://map-init.gallimap.com/styles/light/style.json';
  // Hive storage box name
  static const String entriesBoxName = 'entries_box';
  // Default map position (Kathmandu)
  static const double defaultLat  = 27.7172;
  static const double defaultLng  = 85.3240;
  static const double defaultZoom = 12.0;
}

/// Category data for marker icons.
class CategoryIcon {
  final String id;      // unique identifier for the category
  final String label;   // display name
  final IconData icon;  // Flutter icon to render
  const CategoryIcon({required this.id, required this.label, required this.icon});
}

/// Available categories for location entries.
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
