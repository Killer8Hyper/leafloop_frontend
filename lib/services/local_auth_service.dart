import 'package:shared_preferences/shared_preferences.dart';

class LocalAuthService {
  static final LocalAuthService _instance = LocalAuthService._internal();
  factory LocalAuthService() => _instance;
  LocalAuthService._internal();

  int? currentUserId;
  String? currentUsername;
  bool isAdmin = false;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    currentUserId = prefs.getInt('userId');
    currentUsername = prefs.getString('username');
    isAdmin = prefs.getBool('isAdmin') ?? false;
  }

  Future<void> login(int id, String username, {bool isAdmin = false}) async {
    currentUserId = id;
    currentUsername = username;
    this.isAdmin = isAdmin;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', id);
    await prefs.setString('username', username);
    await prefs.setBool('isAdmin', isAdmin);
  }

  Future<void> logout() async {
    currentUserId = null;
    currentUsername = null;
    isAdmin = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('username');
    await prefs.remove('isAdmin');
  }

  bool get isLoggedIn => currentUserId != null;
}
