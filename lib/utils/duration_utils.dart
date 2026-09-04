abstract final class DurationUtils {
  // Pre-formatted two-digit lookup table to eliminate string padding overhead in hot formatting loops
  static final List<String> _twoDigitsCache = List<String>.generate(
    100,
    (i) => i < 10 ? '0$i' : '$i',
  );

  static String _twoDigits(int n) {
    if (n >= 0 && n < 100) return _twoDigitsCache[n];
    return n.toString().padLeft(2, '0');
  }

  /// Formats [seconds] into HH:mm:ss or mm:ss string.
  /// Optimized integer division and caching for standard integer seconds to minimize allocations.
  static String formatDuration(num? seconds) {
    if (seconds == null || seconds == 0) {
      return '00:00';
    }
    if (seconds is int) {
      final int h = seconds ~/ 3600;
      final int rem = seconds % 3600;
      final int m = rem ~/ 60;
      final int s = rem % 60;
      if (h == 0) {
        return '${_twoDigits(m)}:${_twoDigits(s)}';
      } else {
        return '${_twoDigits(h)}:${_twoDigits(m)}:${_twoDigits(s)}';
      }
    }
    int h = seconds ~/ 3600;
    seconds %= 3600;
    int m = seconds ~/ 60;
    seconds %= 60;
    String sms = seconds is double
        ? seconds.toStringAsFixed(3).padLeft(6, '0')
        : _twoDigits(seconds.toInt());
    return h == 0
        ? "${_twoDigits(m)}:$sms"
        : "${_twoDigits(h)}:${_twoDigits(m)}:$sms";
  }

  /// Parses duration formatted as "HH:mm:ss" or "mm:ss" or "ss".
  /// Optimized with direct character-code parsing to avoid regex splitting & math pow overhead.
  static int parseDuration(String? data) {
    if (data == null || data.isEmpty) {
      return 0;
    }
    int totalSeconds = 0;
    int currentNum = 0;
    bool hasNum = false;

    final len = data.length;
    for (int i = 0; i < len; i++) {
      final code = data.codeUnitAt(i);
      if (code >= 48 && code <= 57) {
        // '0' - '9'
        currentNum = currentNum * 10 + (code - 48);
        hasNum = true;
      } else if (code == 58 || code == 65306) {
        // ':' or '：'
        if (hasNum) {
          totalSeconds = totalSeconds * 60 + currentNum;
          currentNum = 0;
          hasNum = false;
        }
      }
    }
    if (hasNum) {
      totalSeconds = totalSeconds * 60 + currentNum;
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
