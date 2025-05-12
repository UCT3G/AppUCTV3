import 'package:shared_preferences/shared_preferences.dart';

class SessionHelper {
  static Future<void> updateLastActive() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastActiveAt', DateTime.now().toIso8601String());
  }

  static Future<Duration> getInactivityDuration() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActive = prefs.getString('lastActiveAt');
    if (lastActive == null) {
      return Duration.zero;
    }
    final lastTime = DateTime.tryParse(lastActive);
    if (lastTime == null) return Duration.zero;
    return DateTime.now().difference(lastTime);
  }

  static Future<bool> hasLastActive() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('lastActiveAt');
  }
}
