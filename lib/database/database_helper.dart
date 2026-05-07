import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'leafloop.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        email TEXT UNIQUE,
        password_hash TEXT,
        energy_level INTEGER DEFAULT 2,
        current_streak INTEGER DEFAULT 0,
        longest_streak INTEGER DEFAULT 0,
        total_missions INTEGER DEFAULT 0,
        easy_completed INTEGER DEFAULT 0,
        medium_completed INTEGER DEFAULT 0,
        hard_completed INTEGER DEFAULT 0,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

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
        completed_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(user_id) REFERENCES users(id),
        FOREIGN KEY(mission_id) REFERENCES missions(id)
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

  // Create user
  Future<int> createUser(String username, String email, String passwordHash, int energyLevel) async {
    final db = await database;
    return await db.insert('users', {
      'username': username,
      'email': email,
      'password_hash': passwordHash,
      'energy_level': energyLevel,
      'created_at': DateTime.now().toIso8601String(),
    });
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

  // Update user streak after completing mission
  Future<void> updateUserStreak(int userId) async {
    final db = await database;
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

  // Complete a mission
  Future<void> completeMission(int userId, int missionId) async {
    final db = await database;
    
    await db.insert('user_missions', {
      'user_id': userId,
      'mission_id': missionId,
      'completed_date': DateTime.now().toIso8601String(),
    });
    
    // Update user stats
    await updateUserStreak(userId);
  }

  // Get user's completed missions
  Future<List<Map<String, dynamic>>> getUserCompletedMissions(int userId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT m.*, um.completed_date
      FROM user_missions um
      JOIN missions m ON um.mission_id = m.id
      WHERE um.user_id = ?
      ORDER BY um.completed_date DESC
    ''', [userId]);
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