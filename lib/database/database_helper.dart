import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  static const String _databaseName = "leafloop.db";
  static const int _databaseVersion = 9;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS user_missions');
      await db.execute('DROP TABLE IF EXISTS missions');
      await db.execute('DROP TABLE IF EXISTS users');
      await _onCreate(db, newVersion);
    }
    if (oldVersion < 3) {
      // Version 3: Add first_name, middle_name, last_name
      await db.execute('ALTER TABLE users ADD COLUMN first_name TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN middle_name TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN last_name TEXT');
    }
    if (oldVersion < 5) {
      // Version 5: Ensuring Date of Birth is present
      try {
        await db.execute('ALTER TABLE users ADD COLUMN date_of_birth TEXT');
      } catch (e) {}
    }
    if (oldVersion < 6) {
      // Version 6: Add is_admin column
      try {
        await db.execute('ALTER TABLE users ADD COLUMN is_admin INTEGER DEFAULT 0');
        // Seed default admin if not exists
        await db.insert('users', {
          'username': 'admin',
          'email': 'admin@leafloop.com',
          'password_hash': 'P@ssw0rd',
          'first_name': 'LeafLoop',
          'last_name': 'Admin',
          'is_admin': 1
        });
      } catch (e) {}
    }
    if (oldVersion < 7) {
      // Version 7: Update Admin Password to secure version
      await db.update(
        'users',
        {'password_hash': 'P@ssw0rd'},
        where: 'username = ?',
        whereArgs: ['admin'],
      );
    }
    if (oldVersion < 8) {
      // Version 8: Add note and image_path to user_missions
      try {
        await db.execute('ALTER TABLE user_missions ADD COLUMN note TEXT');
        await db.execute('ALTER TABLE user_missions ADD COLUMN image_path TEXT');
      } catch (e) {}
    }
    if (oldVersion < 9) {
      // Version 9: Add login_activity table
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS login_activity (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            login_date DATETIME DEFAULT CURRENT_TIMESTAMP
          )
        ''');
      } catch (e) {}
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        email TEXT UNIQUE,
        password_hash TEXT,
        profile_image_path TEXT,
        first_name TEXT,
        middle_name TEXT,
        last_name TEXT,
        date_of_birth TEXT,
        energy_level INTEGER DEFAULT 2,
        current_streak INTEGER DEFAULT 0,
        longest_streak INTEGER DEFAULT 0,
        total_missions INTEGER DEFAULT 0,
        easy_completed INTEGER DEFAULT 0,
        medium_completed INTEGER DEFAULT 0,
        hard_completed INTEGER DEFAULT 0,
        is_admin INTEGER DEFAULT 0,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Seed default admin
    await db.insert('users', {
      'username': 'admin',
      'email': 'admin@leafloop.com',
      'password_hash': 'P@ssw0rd',
      'first_name': 'LeafLoop',
      'last_name': 'Admin',
      'is_admin': 1
    });

    // Missions table
    await db.execute('''
      CREATE TABLE missions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        difficulty INTEGER,
        category TEXT,
        xp_reward INTEGER,
        icon TEXT
      )
    ''');

    // User Missions (completed)
    await db.execute('''
      CREATE TABLE user_missions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        mission_id INTEGER,
        completed_date DATETIME,
        note TEXT,
        image_path TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (mission_id) REFERENCES missions (id)
      )
    ''');

    // Insert missions
    await _insertMissions(db);
  }

  Future<void> _insertMissions(Database db) async {
    List<Map<String, dynamic>> missions = [
      // EASY MISSIONS (Difficulty 1)
      {'title': 'Turn off lights when leaving room', 'description': 'Save energy by turning off unused lights', 'difficulty': 1, 'category': 'energy', 'xp_reward': 5, 'icon': '💡'},
      {'title': 'Use reusable water bottle', 'description': 'Avoid single-use plastic bottles', 'difficulty': 1, 'category': 'plastic', 'xp_reward': 5, 'icon': '💧'},
      {'title': 'Say no to plastic straw', 'description': 'Politely refuse plastic straws', 'difficulty': 1, 'category': 'plastic', 'xp_reward': 5, 'icon': '🥤'},
      {'title': 'Turn off tap while brushing', 'description': 'Save water while brushing teeth', 'difficulty': 1, 'category': 'water', 'xp_reward': 5, 'icon': '🚰'},
      {'title': 'Take stairs for 1 floor', 'description': 'Skip the elevator for short trips', 'difficulty': 1, 'category': 'energy', 'xp_reward': 5, 'icon': '🪜'},
      {'title': 'Bring reusable bag', 'description': 'Use eco-friendly bags for shopping', 'difficulty': 1, 'category': 'plastic', 'xp_reward': 5, 'icon': '🛍️'},
      {'title': 'Unplug phone charger', 'description': 'Unplug when not in use', 'difficulty': 1, 'category': 'energy', 'xp_reward': 5, 'icon': '📱'},
      {'title': 'Use both sides of paper', 'description': 'Reduce paper waste', 'difficulty': 1, 'category': 'community', 'xp_reward': 5, 'icon': '📄'},
      {'title': 'Take a 5-min shower', 'description': 'Shorten your shower time', 'difficulty': 1, 'category': 'water', 'xp_reward': 5, 'icon': '🚿'},
      {'title': 'Open windows instead of AC', 'description': 'Use natural ventilation', 'difficulty': 1, 'category': 'energy', 'xp_reward': 5, 'icon': '🪟'},
      
      // MEDIUM MISSIONS (Difficulty 2)
      {'title': 'Recycle plastic bottles', 'description': 'Sort and recycle plastic waste', 'difficulty': 2, 'category': 'plastic', 'xp_reward': 10, 'icon': '♻️'},
      {'title': 'Use public transport', 'description': 'Take bus or train instead of car', 'difficulty': 2, 'category': 'transport', 'xp_reward': 10, 'icon': '🚌'},
      {'title': 'Meal prep to reduce waste', 'description': 'Plan meals to avoid food waste', 'difficulty': 2, 'category': 'food', 'xp_reward': 10, 'icon': '🍱'},
      {'title': 'Fix a leaky faucet', 'description': 'Repair dripping taps', 'difficulty': 2, 'category': 'water', 'xp_reward': 10, 'icon': '🔧'},
      {'title': 'Donate old clothes', 'description': 'Give unused clothes a second life', 'difficulty': 2, 'category': 'community', 'xp_reward': 10, 'icon': '👕'},
      {'title': 'Bike to school/work', 'description': 'Use bicycle for transportation', 'difficulty': 2, 'category': 'transport', 'xp_reward': 10, 'icon': '🚲'},
      {'title': 'Start a compost bin', 'description': 'Compost food scraps', 'difficulty': 2, 'category': 'food', 'xp_reward': 10, 'icon': '🗑️'},
      {'title': 'Use rechargeable batteries', 'description': 'Switch to reusable batteries', 'difficulty': 2, 'category': 'energy', 'xp_reward': 10, 'icon': '🔋'},
      {'title': 'Bring own container for takeout', 'description': 'Avoid single-use containers', 'difficulty': 2, 'category': 'plastic', 'xp_reward': 10, 'icon': '🥡'},
      {'title': 'Collect rainwater for plants', 'description': 'Use rain for watering', 'difficulty': 2, 'category': 'water', 'xp_reward': 10, 'icon': '🌧️'},
      
      // HARD MISSIONS (Difficulty 3)
      {'title': 'Organize a cleanup event', 'description': 'Lead a community cleanup', 'difficulty': 3, 'category': 'community', 'xp_reward': 20, 'icon': '🧹'},
      {'title': 'Plastic-free week challenge', 'description': 'No single-use plastics for a week', 'difficulty': 3, 'category': 'plastic', 'xp_reward': 25, 'icon': '🏆'},
      {'title': 'Install solar-powered lights', 'description': 'Use solar energy for outdoor lights', 'difficulty': 3, 'category': 'energy', 'xp_reward': 20, 'icon': '☀️'},
      {'title': 'Start a community garden', 'description': 'Grow food together', 'difficulty': 3, 'category': 'community', 'xp_reward': 25, 'icon': '🌻'},
      {'title': 'Go car-free for a week', 'description': 'Use only walking, biking, or transit', 'difficulty': 3, 'category': 'transport', 'xp_reward': 20, 'icon': '🚶'},
      {'title': 'Host a swap party', 'description': 'Exchange items with friends', 'difficulty': 3, 'category': 'community', 'xp_reward': 15, 'icon': '🔄'},
      {'title': 'Install low-flow showerhead', 'description': 'Reduce water usage', 'difficulty': 3, 'category': 'water', 'xp_reward': 15, 'icon': '🚿'},
      {'title': 'Volunteer at recycling center', 'description': 'Help sort recyclables', 'difficulty': 3, 'category': 'community', 'xp_reward': 20, 'icon': '♻️'},
      {'title': 'Plant a tree', 'description': 'Grow a tree for the future', 'difficulty': 3, 'category': 'community', 'xp_reward': 20, 'icon': '🌳'},
      {'title': 'Zero waste grocery shopping', 'description': 'Buy without packaging', 'difficulty': 3, 'category': 'plastic', 'xp_reward': 20, 'icon': '🛒'},
    ];

    for (var mission in missions) {
      await db.insert('missions', mission);
    }
  }

  // ==================== USER METHODS ====================

  Future<int> createUser(String username, String email, String passwordHash, int energyLevel, 
      {String? profileImagePath, String? firstName, String? middleName, String? lastName, String? dob, int isAdmin = 0}) async {
    final db = await database;
    return await db.insert('users', {
      'username': username,
      'email': email,
      'password_hash': passwordHash,
      'profile_image_path': profileImagePath,
      'energy_level': energyLevel,
      'first_name': firstName,
      'middle_name': middleName,
      'last_name': lastName,
      'date_of_birth': dob,
      'is_admin': isAdmin,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Check if username is taken
  Future<bool> isUsernameTaken(String username) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty;
  }

  // Check if email is taken
  Future<bool> isEmailTaken(String email) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }

  // Get user by username
  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Get user by ID
  Future<Map<String, dynamic>?> getUserById(int userId) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Get all users
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return await db.query('users', orderBy: 'created_at DESC');
  }

  // Get Daily Mission Stats for Chart
  Future<List<Map<String, dynamic>>> getDailyMissionStats() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT DATE(completed_date) as date, COUNT(*) as count 
      FROM user_missions 
      WHERE completed_date >= date('now', '-7 days')
      GROUP BY DATE(completed_date)
      ORDER BY date ASC
    ''');
  }

  // Record a Login Event
  Future<void> recordLogin(int userId) async {
    final db = await database;
    await db.insert('login_activity', {
      'user_id': userId,
      'login_date': DateTime.now().toIso8601String(),
    });
  }

  // Get Daily Login Stats for Chart
  Future<List<Map<String, dynamic>>> getDailyLoginStats() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT DATE(login_date) as date, COUNT(*) as count 
      FROM login_activity 
      WHERE login_date >= date('now', '-7 days')
      GROUP BY DATE(login_date)
      ORDER BY date ASC
    ''');
  }

  // Update user energy level
  Future<void> updateUserEnergyLevel(int userId, int energyLevel) async {
    final db = await database;
    await db.update(
      'users',
      {'energy_level': energyLevel},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // Update user profile
  Future<void> updateUserProfile({
    required int userId,
    String? username,
    String? email,
    String? firstName,
    String? middleName,
    String? lastName,
    String? dob,
    String? profileImagePath,
  }) async {
    final db = await database;
    Map<String, dynamic> values = {};
    if (username != null) values['username'] = username;
    if (email != null) values['email'] = email;
    if (firstName != null) values['first_name'] = firstName;
    if (middleName != null) values['middle_name'] = middleName;
    if (lastName != null) values['last_name'] = lastName;
    if (dob != null) values['date_of_birth'] = dob;
    if (profileImagePath != null) values['profile_image_path'] = profileImagePath;

    if (values.isNotEmpty) {
      await db.update(
        'users',
        values,
        where: 'id = ?',
        whereArgs: [userId],
      );
    }
  }

  // Update user streak after completing mission
  Future<void> updateUserStreak(int userId, bool isNewDay) async {
    final db = await database;
    
    if (isNewDay) {
      await db.rawQuery('''
        UPDATE users 
        SET current_streak = current_streak + 1,
            longest_streak = CASE 
              WHEN current_streak + 1 > longest_streak THEN current_streak + 1 
              ELSE longest_streak 
            END,
            total_missions = total_missions + 1
        WHERE id = ?
      ''', [userId]);
    } else {
      await db.rawQuery('''
        UPDATE users 
        SET total_missions = total_missions + 1
        WHERE id = ?
      ''', [userId]);
    }
  }

  // ==================== MISSION METHODS ====================

  // Get missions by difficulty
  Future<List<Map<String, dynamic>>> getMissionsByDifficulty(int difficulty, {int limit = 5}) async {
    final db = await database;
    return await db.query(
      'missions',
      where: 'difficulty = ?',
      whereArgs: [difficulty],
      limit: limit,
    );
  }

  // Get all missions
  Future<List<Map<String, dynamic>>> getAllMissions() async {
    final db = await database;
    return await db.query('missions');
  }

  // Get mission by ID
  Future<Map<String, dynamic>?> getMissionById(int missionId) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'missions',
      where: 'id = ?',
      whereArgs: [missionId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Add a new mission
  Future<int> addMission(Map<String, dynamic> mission) async {
    final db = await database;
    return await db.insert('missions', mission);
  }

  // Update a mission
  Future<int> updateMission(int id, Map<String, dynamic> mission) async {
    final db = await database;
    return await db.update(
      'missions',
      mission,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete a mission
  Future<int> deleteMission(int id) async {
    final db = await database;
    return await db.delete(
      'missions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Complete a mission
  Future<void> completeMission(int userId, int missionId, {String? note, String? imagePath}) async {
    final db = await database;
    
    String today = DateTime.now().toIso8601String().substring(0, 10);
    
    // Check if already completed today
    var existing = await db.rawQuery('''
      SELECT id FROM user_missions 
      WHERE user_id = ? AND mission_id = ? 
      AND DATE(completed_date) = ?
    ''', [userId, missionId, today]);
    
    if (existing.isNotEmpty) {
      return; // Already completed this specific mission today
    }

    // Check if ANY mission was completed today (to determine if streak goes up)
    var anyToday = await db.rawQuery('''
      SELECT id FROM user_missions 
      WHERE user_id = ? AND DATE(completed_date) = ?
    ''', [userId, today]);
    
    bool isNewDay = anyToday.isEmpty;

    // Check if yesterday had a mission. If not, and this is a new day, streak resets.
    if (isNewDay) {
      String yesterday = DateTime.now().subtract(const Duration(days: 1)).toIso8601String().substring(0, 10);
      var anyYesterday = await db.rawQuery('''
        SELECT id FROM user_missions 
        WHERE user_id = ? AND DATE(completed_date) = ?
      ''', [userId, yesterday]);
      
      if (anyYesterday.isEmpty) {
        // Streak broken
        await db.update('users', {'current_streak': 0}, where: 'id = ?', whereArgs: [userId]);
      }
    }

    await db.insert('user_missions', {
      'user_id': userId,
      'mission_id': missionId,
      'completed_date': DateTime.now().toIso8601String(),
      'note': note,
      'image_path': imagePath,
    });
    
    // Update user stats
    await updateUserStreak(userId, isNewDay);
  }

  // Get user's completed missions
  Future<List<Map<String, dynamic>>> getUserCompletedMissions(int userId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT m.*, um.completed_date, um.note, um.image_path
      FROM user_missions um
      JOIN missions m ON um.mission_id = m.id
      WHERE um.user_id = ?
      ORDER BY um.completed_date DESC
    ''', [userId]);
  }

  // Get count of missions completed today by difficulty
  Future<int> getTodayDifficultyCount(int userId, int difficulty) async {
    final db = await database;
    String today = DateTime.now().toIso8601String().substring(0, 10);
    var result = await db.rawQuery('''
      SELECT COUNT(*) as count 
      FROM user_missions um
      JOIN missions m ON um.mission_id = m.id
      WHERE um.user_id = ? AND DATE(um.completed_date) = ? AND m.difficulty = ?
    ''', [userId, today, difficulty]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get count of total missions completed today
  Future<int> getTodayCompletedCount(int userId) async {
    final db = await database;
    String today = DateTime.now().toIso8601String().substring(0, 10);
    var result = await db.rawQuery('''
      SELECT COUNT(*) as count FROM user_missions 
      WHERE user_id = ? AND DATE(completed_date) = ?
    ''', [userId, today]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ==================== AI STATS METHODS ====================

  // Get user stats for AI
  Future<Map<String, dynamic>> getUserMissionStats(int userId) async {
    final db = await database;
    
    // Get counts by difficulty
    List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        COUNT(CASE WHEN m.difficulty = 1 THEN 1 END) as easy_count,
        COUNT(CASE WHEN m.difficulty = 2 THEN 1 END) as medium_count,
        COUNT(CASE WHEN m.difficulty = 3 THEN 1 END) as hard_count,
        COUNT(*) as total
      FROM user_missions um
      JOIN missions m ON um.mission_id = m.id
      WHERE um.user_id = ?
    ''', [userId]);
    
    // Get current streak and energy level
    List<Map<String, dynamic>> user = await db.query(
      'users',
      columns: ['current_streak', 'energy_level'],
      where: 'id = ?',
      whereArgs: [userId],
    );
    
    return {
      'easy_count': result.first['easy_count'] ?? 0,
      'medium_count': result.first['medium_count'] ?? 0,
      'hard_count': result.first['hard_count'] ?? 0,
      'total_missions': result.first['total'] ?? 0,
      'current_streak': user.first['current_streak'] ?? 0,
      'energy_level': user.first['energy_level'] ?? 2,
      'completion_rate': await _calculateCompletionRate(userId),
    };
  }

  Future<double> _calculateCompletionRate(int userId) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        COUNT(DISTINCT DATE(completed_date)) as days_with_missions,
        (SELECT COUNT(DISTINCT DATE(completed_date)) 
         FROM user_missions 
         WHERE user_id = ? AND completed_date >= DATE('now', '-30 days')
        ) as total_active_days
      FROM user_missions
      WHERE user_id = ? AND completed_date >= DATE('now', '-30 days')
    ''', [userId, userId]);
    
    int daysWithMissions = result.first['days_with_missions'] ?? 0;
    return daysWithMissions / 30.0;
  }
}