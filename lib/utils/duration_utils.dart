abstract final class DurationUtils {
  /// Formats [seconds] into a string like `MM:SS` or `HH:MM:SS`.
  /// Optimized to avoid redundant string allocations and padLeft overhead.
  static String formatDuration(num? seconds) {
    if (seconds == null || seconds == 0) {
      return '00:00';
    }
    int h = seconds ~/ 3600;
    seconds %= 3600;
    int m = seconds ~/ 60;
    seconds %= 60;
    String sms = seconds is double
        ? seconds.toStringAsFixed(3).padLeft(6, '0')
        : (seconds < 10 ? '0$seconds' : '$seconds');
    final mStr = m < 10 ? '0$m' : '$m';
    if (h == 0) {
      return '$mStr:$sms';
    }
    final hStr = h < 10 ? '0$h' : '$h';
    return '$hStr:$mStr:$sms';
  }

  /// Parses a duration string (e.g., `01:23:45`, `03:45`, `1：23：45`) into seconds.
  /// Optimized to parse in a single pass using Horner's method, avoiding RegExp compilation,
  /// split allocations, list reversal, mapping, and floating point `pow()` math.
  static int parseDuration(String? data) {
    if (data == null || data.isEmpty) {
      return 0;
    }
    int duration = 0;
    int start = 0;
    final len = data.length;
    for (int i = 0; i < len; i++) {
      final code = data.codeUnitAt(i);
      if (code == 58 || code == 65306) { // ':' (58) or '：' (65306)
        if (i > start) {
          final val = int.tryParse(data.substring(start, i)) ?? 0;
          duration = duration * 60 + val;
        }
        start = i + 1;
      }
    }
    if (start < len) {
      final val = int.tryParse(data.substring(start)) ?? 0;
      duration = duration * 60 + val;
    }
    return duration;
  }

  static String formatDurationBetween(int startMillis, int endMillis) =>
      formatTimeDuration(Duration(milliseconds: endMillis - startMillis));

  static String formatTimeDuration(Duration duration) {
    final inDays = duration.inDays;
    final daysLeft = inDays % 365;
    final years = inDays ~/ 365;
    final months = daysLeft ~/ 30;
    final days = daysLeft % 30;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    final format = StringBuffer();

    if (years > 0) format.write('$years年');
    if (months > 0) format.write('$months月');
    if (days > 0) format.write('$days天');
    if (hours > 0) format.write('$hours小时');
    if (minutes > 0) format.write('$minutes分钟');

    return format.toString();
  }
}
