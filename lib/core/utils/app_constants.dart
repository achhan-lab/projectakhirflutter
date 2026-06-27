import 'package:flutter/material.dart';

/// App-wide constants and theme colors.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF27AE60);
  static const Color primaryLight = Color(0xFF2ECC71);
  static const Color accent = Color(0xFF1ABC9C);
  static const Color background = Color(0xFFF5F7FA);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color blue = Color(0xFF3B82F6);
  static const Color blueLight = Color(0xFF60A5FA);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color purpleLight = Color(0xFF6366F1);
  static const Color yellow = Color(0xFFFBBF24);
  static const Color orange = Color(0xFFF59E0B);
  static const Color pink = Color(0xFFFB7185);
  static const Color red = Color(0xFFE74C3C);
  static const Color greenLight = Color(0xFF4ADE80);
  static const Color whatsapp = Color(0xFF25D366);
  static const Color grey = Color(0xFF6B7280);
}

/// Product categories
const List<String> productCategories = [
  'Jasa',
  'Makanan & Minuman',
  'Barang Bekas',
  'Elektronik',
  'Buku',
  'Fashion & Aksesoris',
  'Lainnya',
];

/// Forum categories
const List<String> forumCategories = [
  'Semua',
  'PKM',
  'Supplier',
  'Lowongan',
  'Diskusi',
  'Lainnya',
];

/// Colab purpose categories
const List<String> colabCategories = [
  'Semua',
  'PKM',
  'Project',
  'Riset',
  'Komunitas',
  'Lainnya',
];

/// Colab status options
const List<String> colabStatuses = [
  'Open',
  'In Progress',
  'Completed',
];

/// Map kategori to color
const Map<String, Color> kategoriColors = {
  'PKM': Color(0xFF8B5CF6),
  'Project': Color(0xFF3B82F6),
  'Riset': Color(0xFFF59E0B),
  'Komunitas': Color(0xFF27AE60),
  'Supplier': Color(0xFFF59E0B),
  'Lowongan': Color(0xFF3B82F6),
  'Diskusi': Color(0xFF27AE60),
  'Lainnya': Color(0xFF6B7280),
};

/// Map colab kategori to icon
const Map<String, IconData> colabIcons = {
  'PKM': Icons.emoji_events_outlined,
  'Project': Icons.code_rounded,
  'Riset': Icons.science_outlined,
  'Komunitas': Icons.groups_rounded,
  'Lainnya': Icons.more_horiz_rounded,
};
