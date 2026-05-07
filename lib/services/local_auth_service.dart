import 'package:shared_preferences/shared_preferences.dart';

class LocalAuthService {
  static final LocalAuthService _instance = LocalAuthService._internal();
  factory LocalAuthService() => _instance;
  LocalAuthService._internal();

  int? currentUserId;
  String? currentUsername;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    currentUserId = prefs.getInt('userId');
    currentUsername = prefs.getString('username');
  }

  Future<void> login(int id, String username) async {
    currentUserId = id;
    currentUsername = username;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', id);
    await prefs.setString('username', username);
  }

  Future<void> logout() async {
    currentUserId = null;
    currentUsername = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('username');
  }

  bool get isLoggedIn => currentUserId != null;
}
