import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

abstract final class ConnectivityUtils {
  // Cached WiFi state — updated by the background stream listener.
  // Eliminates the async await on the main isolate inside queryVideoUrl().
  static bool _cachedIsWiFi = true;
  static bool _initialized = false;

  /// Call once at app startup to initialise the cache
  /// and subscribe to connectivity change events.
  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    if (!PlatformUtils.isMobile) return;
    final connectivity = Connectivity();
    // Populate the initial value synchronously-ish.
    try {
      final result = await connectivity.checkConnectivity();
      _cachedIsWiFi = result.contains(ConnectivityResult.wifi);
    } catch (_) {
      _cachedIsWiFi = true;
    }
    // Keep it up-to-date with zero per-query overhead.
    connectivity.onConnectivityChanged.listen((result) {
      _cachedIsWiFi = result.contains(ConnectivityResult.wifi);
    });
  }

  /// Synchronous read — zero await overhead. Use in hot paths.
  static bool get isWiFiSync => !PlatformUtils.isMobile || _cachedIsWiFi;

  /// Async fallback kept for compatibility; initialises cache on first call.
  static Future<bool> get isWiFi async {
    if (!_initialized) await init();
    return isWiFiSync;
  }
}
