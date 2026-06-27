/// Shared formatting utilities used across the app.
class FormatUtils {
  FormatUtils._();

  /// Format integer price with dot separators: 1500000 -> "1.500.000"
  static String formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  /// Format price input with dots in real-time: "1500000" -> "1.500.000"
  static String formatPriceInput(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';
    final result = <String>[];
    int count = 0;
    for (int i = digits.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) result.add('.');
      result.add(digits[i]);
      count++;
    }
    return result.reversed.join();
  }

  /// Parse formatted price string back to int: "1.500.000" -> 1500000
  static int parseFormattedPrice(String value) {
    return int.tryParse(value.replaceAll('.', '')) ?? 0;
  }

  /// Convert 08xxx to 628xxx and strip non-digits
  static String formatPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.startsWith('0')) {
      return '62${cleaned.substring(1)}';
    }
    return cleaned;
  }

  /// Relative time ago string from ISO8601 date string
  static String timeAgo(String? dateStr, {bool short = false}) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) {
      return short ? '${diff.inMinutes}m' : '${diff.inMinutes} menit lalu';
    }
    if (diff.inHours < 24) {
      return short ? '${diff.inHours}j' : '${diff.inHours} jam lalu';
    }
    if (diff.inDays < 7) {
      return short ? '${diff.inDays}h' : '${diff.inDays} hari lalu';
    }
    return short
        ? '${diff.inDays ~/ 7}mgg'
        : '${diff.inDays ~/ 7} minggu lalu';
  }
}
