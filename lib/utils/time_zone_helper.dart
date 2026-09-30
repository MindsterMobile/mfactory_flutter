import 'package:intl/intl.dart';

/// Helper for user timezone detection and formatting dates/times in the user's timezone.
class TimezoneHelper {
  TimezoneHelper._();

  /// Returns user's IANA timezone or standard timezone identifier (e.g. Asia/Kolkata).
  static String get userTimezone {
    final name = DateTime.now().timeZoneName.trim();
    if (name.toUpperCase() == 'IST') {
      return 'Asia/Kolkata';
    }
    final offset = DateTime.now().timeZoneOffset;
    if (offset.inHours == 5 && offset.inMinutes % 60 == 30) {
      return 'Asia/Kolkata';
    }
    if (name.isNotEmpty && !name.startsWith('+') && !name.startsWith('-')) {
      return name;
    }
    return 'Asia/Kolkata';
  }

  /// Parses an ISO 8601 string and converts to local DateTime.
  static DateTime? parseUtcToLocal(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.trim().isEmpty) return null;
    final trimmed = dateTimeStr.trim();
    try {
      return DateTime.parse(trimmed).toLocal();
    } catch (_) {
      return null;
    }
  }

  /// Parses an ISO 8601 or UTC datetime string and formats it into the user's local timezone.
  static String formatToUserLocal(
    String? dateTimeStr, {
    String format = 'dd MMM yyyy, hh:mm a',
    String fallback = '',
  }) {
    if (dateTimeStr == null || dateTimeStr.trim().isEmpty) return fallback;
    final trimmed = dateTimeStr.trim();
    try {
      final parsed = DateTime.parse(trimmed).toLocal();
      return DateFormat(format).format(parsed);
    } catch (_) {
      return trimmed;
    }
  }

  /// Formats time only in local timezone, e.g. "01:15 pm"
  static String formatTimeOnly(String? dateTimeStr, {String fallback = '-'}) {
    if (dateTimeStr == null || dateTimeStr.trim().isEmpty) return fallback;
    final trimmed = dateTimeStr.trim();
    try {
      final dt = DateTime.parse(trimmed).toLocal();
      final hour = dt.hour;
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'pm' : 'am';
      final formattedHour =
          (hour % 12 == 0 ? 12 : hour % 12).toString().padLeft(2, '0');
      return '$formattedHour:$minute $period';
    } catch (_) {
      if (trimmed.length >= 16 && trimmed.contains('T')) {
        return trimmed.substring(11, 16);
      }
      return trimmed;
    }
  }

  /// Formats date only in local timezone, e.g. "25 Sep 2026"
  static String formatDateOnly(String? dateTimeStr, {String fallback = '-'}) {
    if (dateTimeStr == null || dateTimeStr.trim().isEmpty) return fallback;
    final trimmed = dateTimeStr.trim();
    try {
      final dt = DateTime.parse(trimmed).toLocal();
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return trimmed;
    }
  }

  /// Formats date range e.g. "2026-08-24" and "2026-08-30" -> "24 Aug 2026 - 30 Aug 2026"
  static String formatDateRange(String? startDate, String? endDate) {
    if (startDate == null && endDate == null) return '';
    try {
      final start = startDate != null ? DateTime.tryParse(startDate) : null;
      final end = endDate != null ? DateTime.tryParse(endDate) : null;
      if (start != null && end != null) {
        final fStart = DateFormat('dd MMM yyyy').format(start);
        final fEnd = DateFormat('dd MMM yyyy').format(end);
        return '$fStart - $fEnd';
      }
    } catch (_) {}
    return '${startDate ?? ''} - ${endDate ?? ''}'.trim();
  }
}
