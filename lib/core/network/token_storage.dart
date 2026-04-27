import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class TokenStorage {
  final SharedPreferences _prefs;
  TokenStorage(this._prefs);

  String getAccessToken()  => _prefs.getString(AppConstants.accessTokenKey)  ?? '';
  String getRefreshToken() => _prefs.getString(AppConstants.refreshTokenKey) ?? '';

  Future<void> saveTokens({required String access, required String refresh}) async {
    await _prefs.setString(AppConstants.accessTokenKey,  access);
    await _prefs.setString(AppConstants.refreshTokenKey, refresh);
  }

  Future<void> clearTokens() async {
    await _prefs.remove(AppConstants.accessTokenKey);
    await _prefs.remove(AppConstants.refreshTokenKey);
  }

  bool get hasTokens => getAccessToken().isNotEmpty;

  Future<void> saveTheme(bool isDark) => _prefs.setBool(AppConstants.themeKey, isDark);
  bool? get savedTheme => _prefs.getBool(AppConstants.themeKey);
}
