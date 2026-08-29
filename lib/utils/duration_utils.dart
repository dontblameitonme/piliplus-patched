abstract final class DurationUtils {
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
        : seconds.toString().padLeft(2, '0');
    return h == 0
        ? "${m.toString().padLeft(2, '0')}:$sms"
        : "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:$sms";
  }

  static final _splitRegex = RegExp(r'[:：]');
  /// Parses formatted duration string (e.g. "01:23:45" or "03:45") into total seconds.
  /// Performance optimization: Single-pass forward evaluation (Horner's method)
  /// avoids overhead of reversing lists, mapping functions, and calling `pow()`.
  static int parseDuration(String? data) {
    if (data == null || data.isEmpty) {
      return 0;
    }
    final parts = data.split(_splitRegex);
    int duration = 0;
    for (int i = 0; i < parts.length; i++) {
      final part = int.tryParse(parts[i]) ?? 0;
      duration = duration * 60 + part;
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
