class LocalAuthService {
  static final LocalAuthService _instance = LocalAuthService._internal();
  factory LocalAuthService() => _instance;
  LocalAuthService._internal();

  int? currentUserId;
  String? currentUsername;

  void login(int id, String username) {
    currentUserId = id;
    currentUsername = username;
  }

  void logout() {
    currentUserId = null;
    currentUsername = null;
  }

  bool get isLoggedIn => currentUserId != null;
}
