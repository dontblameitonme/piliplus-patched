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

  /// Parses formatted time string (e.g. "01:23:45" or "23：45") into total seconds.
  /// Performance optimized: avoids RegExp matching, split allocations, list reversals,
  /// closures, and floating-point pow calculations.
  static int parseDuration(String? data) {
    if (data == null || data.isEmpty) {
      return 0;
    }

    int totalSeconds = 0;
    int currentPart = 0;
    bool hasDigit = false;

    for (int i = 0; i < data.length; i++) {
      final code = data.codeUnitAt(i);
      // '0'..'9'
      if (code >= 0x30 && code <= 0x39) {
        currentPart = currentPart * 10 + (code - 0x30);
        hasDigit = true;
      } else if (code == 0x3A || code == 0xFF1A) {
        // ':' (0x3A) or '：' (0xFF1A)
        if (hasDigit) {
          totalSeconds = totalSeconds * 60 + currentPart;
          currentPart = 0;
          hasDigit = false;
        }
      }
    }

    if (hasDigit) {
      totalSeconds = totalSeconds * 60 + currentPart;
    }

    return totalSeconds;
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
