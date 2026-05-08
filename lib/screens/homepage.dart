import 'package:flutter/material.dart';
import 'package:leafloop/screens/missions.dart';
import 'package:leafloop/screens/profile.dart';
import 'package:leafloop/screens/eco_timeline.dart';
import 'package:leafloop/screens/growth_tree.dart';
import 'package:leafloop/screens/admin/users_list.dart';
import 'package:leafloop/widgets/nav_menu.dart';
import 'package:leafloop/database/database_helper.dart';
import 'package:leafloop/services/local_auth_service.dart';
import 'package:leafloop/screens/settings_pages/edit_missions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? _user;
  List<Map<String, dynamic>> _missions = [];
  int _todayCount = 0;
  bool _isLoading = true;
  
  // Admin stats
  int _totalUsers = 0;
  int _totalMissionsCompleted = 0;
  List<Map<String, dynamic>> _recentGlobalActivity = [];
  List<Map<String, dynamic>> _dailyMissionStats = [];
  List<Map<String, dynamic>> _dailyLoginStats = [];
  List<Map<String, dynamic>> _topMissionsUsers = [];
  List<Map<String, dynamic>> _topStreakUsers = [];
  Set<int> _completedMissionIds = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (mounted) setState(() => _isLoading = true);

    try {
      // Re-init the service to restore session from SharedPreferences.
      await LocalAuthService().init();

      int? userId = LocalAuthService().currentUserId;

      // Fallback: look up by stored username if userId is somehow null.
      if (userId == null) {
        final username = LocalAuthService().currentUsername;
        if (username != null && username.isNotEmpty) {
          final found = await DatabaseHelper().getUserByUsername(username);
          if (found != null) {
            userId = found['id'] as int?;
            if (userId != null) {
              await LocalAuthService().login(
                userId,
                username,
                isAdmin: (found['is_admin'] ?? 0) == 1,
              );
            }
          }
        }
      }

      if (userId == null) {
        // Not logged in — nothing to load.
        return;
      }

      final user = await DatabaseHelper().getUserById(userId);

      if (user == null) {
        // User row missing — nothing to load.
        return;
      }

      if (user['is_admin'] == 1) {
        // ── Admin Dashboard ──────────────────────────────────────────────
        final allUsers = await DatabaseHelper().getAllUsers();
        final db = await DatabaseHelper().database;
        final totalCompleted = Sqflite.firstIntValue(
              await db.rawQuery('SELECT COUNT(*) FROM user_missions')) ??
            0;
        final recentActivity = await db.rawQuery('''
          SELECT u.username, m.title, m.icon, um.completed_date
          FROM user_missions um
          JOIN users u ON um.user_id = u.id
          JOIN missions m ON um.mission_id = m.id
          ORDER BY um.completed_date DESC LIMIT 5
        ''');
        final dailyStats = await DatabaseHelper().getDailyMissionStats();
        final loginStats = await DatabaseHelper().getDailyLoginStats();
        final topMissions = await db.rawQuery(
            'SELECT username, total_missions FROM users ORDER BY total_missions DESC LIMIT 3');
        final topStreaks = await db.rawQuery(
            'SELECT username, current_streak FROM users ORDER BY current_streak DESC LIMIT 3');

        // Fill last 7 days with 0 where there is no data.
        List<Map<String, dynamic>> fullStats = [];
        List<Map<String, dynamic>> fullLoginStats = [];
        for (int i = 6; i >= 0; i--) {
          final dateStr = DateFormat('yyyy-MM-dd')
              .format(DateTime.now().subtract(Duration(days: i)));
          fullStats.add(dailyStats.firstWhere(
              (e) => e['date'] == dateStr,
              orElse: () => {'date': dateStr, 'count': 0}));
          fullLoginStats.add(loginStats.firstWhere(
              (e) => e['date'] == dateStr,
              orElse: () => {'date': dateStr, 'count': 0}));
        }

        if (mounted) {
          setState(() {
            _user = user;
            _totalUsers = allUsers.length;
            _totalMissionsCompleted = totalCompleted;
            _recentGlobalActivity = recentActivity;
            _dailyMissionStats = fullStats;
            _dailyLoginStats = fullLoginStats;
            _topMissionsUsers = topMissions;
            _topStreakUsers = topStreaks;
          });
        }
      } else {
        // ── Regular User Home ─────────────────────────────────────────────
        final todayCount = await DatabaseHelper().getTodayCompletedCount(userId);
        final completedMissions =
            await DatabaseHelper().getUserCompletedMissions(userId);
        final today = DateTime.now().toIso8601String().substring(0, 10);
        final completedIds = completedMissions
            .where((m) => m['completed_date'].toString().startsWith(today))
            .map((m) => m['id'] as int)
            .toSet();

        final allMissions = await DatabaseHelper().getAllMissions();
        List<Map<String, dynamic>> missions = [];

        if (allMissions.isNotEmpty) {
          allMissions.shuffle();
          // Pick one of each difficulty; fall back to any available mission.
          final easyList   = allMissions.where((m) => (m['difficulty'] ?? 1) <= 1).toList();
          final mediumList = allMissions.where((m) => (m['difficulty'] ?? 1) == 2).toList();
          final hardList   = allMissions.where((m) => (m['difficulty'] ?? 1) >= 3).toList();

          if (easyList.isNotEmpty)   missions.add(easyList.first);
          if (mediumList.isNotEmpty) missions.add(mediumList.first);
          if (hardList.isNotEmpty)   missions.add(hardList.first);

          // If some difficulties are missing, pad with anything available.
          if (missions.isEmpty) missions = allMissions.take(3).toList();
        }

        if (mounted) {
          setState(() {
            _user = user;
            _missions = missions;
            _todayCount = todayCount;
            _completedMissionIds = completedIds;
          });
        }
      }
    } catch (e, stack) {
      debugPrint('_loadData error: $e\n$stack');
    } finally {
      // Always clear the loading flag, no matter what happened above.
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Dynamic background color
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        title: Row(
          children: [
            Text(
              LocalAuthService().isAdmin ? 'Admin Dashboard' : 'Home',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.notifications_none, size: 35, color: Colors.white),
              onPressed: _showNotificationsDialog,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: LocalAuthService().isAdmin ? _buildAdminDashboard() : _buildUserHome(),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildMissionItem(BuildContext context, String title, bool isDone) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).cardColor, // Dark in dark mode, White in light mode
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isDone
                ? const Color(0xFFA8C69F)
                : const Color(0xFFE0D9D1),
            child: Icon(isDone ? Icons.check : null, color: Colors.white),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHome() {
    final String displayName;
    if (_isLoading) {
      displayName = '...';
    } else if (_user != null) {
      final firstName = (_user!['first_name'] ?? '').toString().trim();
      final lastName  = (_user!['last_name']  ?? '').toString().trim();
      if (firstName.isNotEmpty || lastName.isNotEmpty) {
        displayName = '$firstName $lastName'.trim();
      } else {
        displayName = (_user!['username'] ?? 'User').toString();
      }
    } else {
      displayName = LocalAuthService().currentUsername ?? 'User';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: Theme.of(context).primaryColor,
              backgroundImage: _user?['profile_image_path'] != null 
                        ? FileImage(File(_user!['profile_image_path'])) 
                        : null,
              child: _user?['profile_image_path'] == null ? const Icon(
                Icons.person,
                color: Colors.white,
                size: 40,
              ) : null,
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Welcome back,",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                Text(
                  displayName,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(
              flex: 5,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const TreeGrowthScreen()),
                  ).then((_) => _loadData());
                },
                child: Container(
                  height: 160,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA8C69F),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${_user?['current_streak'] ?? 0}",
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          Text(
                            (_user?['current_streak'] ?? 0) == 1 ? "Streak Day" : "Streak Days",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        bottom: -10,
                        right: -10,
                        child: Image.asset(
                          'assets/images/icons/sapling.png',
                          width: 50,
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  Text(
                    DateTime.now().toLocal().weekday == 1 ? "MONDAY" :
                    DateTime.now().toLocal().weekday == 2 ? "TUESDAY" :
                    DateTime.now().toLocal().weekday == 3 ? "WEDNESDAY" :
                    DateTime.now().toLocal().weekday == 4 ? "THURSDAY" :
                    DateTime.now().toLocal().weekday == 5 ? "FRIDAY" :
                    DateTime.now().toLocal().weekday == 6 ? "SATURDAY" : "SUNDAY",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Text(
                    "${DateTime.now().day}",
                    style: TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.w300,
                      color: Theme.of(context).primaryColor,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFA8C69F),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Daily Goal",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 15),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _todayCount >= 2 
                    ? "Goal reached! Your tree is growing beautifully." 
                    : "Complete ${2 - _todayCount} more missions to grow your plant today",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        Text(
          "MISSION",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 15),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_missions.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'No missions available.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ..._missions.map((m) => _buildMissionItem(context, m['title'] ?? 'Mission', _completedMissionIds.contains(m['id']))).toList(),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildAdminDashboard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _buildAdminStatCard("Total Users", _totalUsers.toString(), Icons.people, Colors.blue)),
            const SizedBox(width: 15),
            Expanded(child: _buildAdminStatCard("Global Missions", _totalMissionsCompleted.toString(), Icons.check_circle, Colors.green)),
          ],
        ),
        const SizedBox(height: 25),
        const Text(
          "MISSION IMPACT (LAST 7 DAYS)",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
        ),
        const SizedBox(height: 15),
        _buildActivityChart(_dailyMissionStats, "Missions", const Color(0xFF3B5236)),
        const SizedBox(height: 30),
        const Text(
          "USER ENGAGEMENT (LAST 7 DAYS)",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
        ),
        const SizedBox(height: 15),
        _buildActivityChart(_dailyLoginStats, "Logins", Colors.blueAccent),
        const SizedBox(height: 30),
        _buildTopPerformersSection(),
        const SizedBox(height: 30),
        const Text(
          "RECENT GLOBAL ACTIVITY",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 15),
        ..._recentGlobalActivity.map((activity) => Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFA8C69F),
              child: Text(
                activity['icon'] ?? '🌱',
                style: const TextStyle(fontSize: 20),
              ),
            ),
            title: Text("${activity['username']} completed:"),
            subtitle: Text(activity['title']),
            trailing: Text(
              activity['completed_date'].toString().substring(0, 10),
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ),
        )).toList(),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildTopPerformersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _buildLeaderboard("Eco Champions", _topMissionsUsers, "Missions", 'total_missions', Colors.orangeAccent)),
            const SizedBox(width: 15),
            Expanded(child: _buildLeaderboard("Streak Kings", _topStreakUsers, "Days", 'current_streak', Colors.redAccent)),
          ],
        ),
      ],
    );
  }

  Widget _buildLeaderboard(String title, List<Map<String, dynamic>> users, String unit, String key, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 10),
          ...users.asMap().entries.map((entry) {
            int rank = entry.key + 1;
            var user = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Text("$rank.", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(user['username'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
                  Text("${user[key]} $unit", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            );
          }).toList(),
          if (users.isEmpty) const Text("No data yet", style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildActivityChart(List<Map<String, dynamic>> stats, String label, Color color) {
    return Container(
      height: 200,
      padding: const EdgeInsets.only(top: 20, right: 20, left: 10, bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: stats.isEmpty 
        ? Center(child: Text("No $label data", style: const TextStyle(color: Colors.grey)))
        : LineChart(
            LineChartData(
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      return LineTooltipItem(
                        '$label: ${spot.y.toInt()}',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      );
                    }).toList();
                  },
                ),
              ),
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      int index = value.toInt();
                      if (index >= 0 && index < stats.length) {
                        DateTime date = DateTime.parse(stats[index]['date']);
                        String dayName = DateFormat('E').format(date);
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(dayName, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                        );
                      }
                      return const Text('');
                    },
                    reservedSize: 30,
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: (stats.length - 1).toDouble(),
              lineBarsData: [
                LineChartBarData(
                  spots: stats.asMap().entries.map((entry) {
                    return FlSpot(entry.key.toDouble(), entry.value['count'].toDouble());
                  }).toList(),
                  isCurved: true,
                  color: color,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(show: true, color: color.withOpacity(0.05)),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildAdminStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 20, backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey), overflow: TextOverflow.ellipsis),
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildBottomNav(BuildContext context) {
    bool isAdmin = LocalAuthService().isAdmin;
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, Icons.home, "Home", () { _loadData(); }, isActive: true),
              _buildNavItem(
                context, 
                LocalAuthService().isAdmin ? Icons.people : Icons.access_time, 
                LocalAuthService().isAdmin ? "Users" : "Eco Timeline", 
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => LocalAuthService().isAdmin 
                        ? const UsersListScreen() 
                        : const EcoTimeline(),
                    ),
                  ).then((_) => _loadData());
                },
              ),
              const SizedBox(width: 50),
              _buildNavItem(context, isAdmin ? Icons.settings_suggest : Icons.track_changes, isAdmin ? "Manage" : "Missions", () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => isAdmin ? const EditMissionsScreen() : const MissionsScreen(),
                  ),
                ).then((_) => _loadData());
              }, isActive: false),
              _buildNavItem(context, Icons.person_outline, "Profile", () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                ).then((_) => _loadData());
              }),
            ],
          ),
        ),
        Positioned(
          top: -30,
          child: GestureDetector(
            onTap: () {
              showNavigationMenu(context);
            },
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      'assets/images/logo/LeafLoop2.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive
                ? Theme.of(context).primaryColor
                : const Color(0xFFA5A5A5),
            size: 30,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive
                  ? Theme.of(context).primaryColor
                  : const Color(0xFFA5A5A5),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showNotificationsDialog() async {
    int? userId = LocalAuthService().currentUserId;
    if (userId == null) return;
    
    List<Map<String, dynamic>> notifications = [];
    if (LocalAuthService().isAdmin) {
      final db = await DatabaseHelper().database;
      notifications = await db.rawQuery('''
        SELECT u.username, m.title, um.completed_date 
        FROM user_missions um 
        JOIN users u ON um.user_id = u.id 
        JOIN missions m ON um.mission_id = m.id 
        ORDER BY um.completed_date DESC LIMIT 15
      ''');
    } else {
      notifications = await DatabaseHelper().getUserCompletedMissions(userId);
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text("Notifications", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Divider(),
              Expanded(
                child: notifications.isEmpty 
                  ? const Center(child: Text("No recent notifications.", style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        var notif = notifications[index];
                        DateTime date = DateTime.parse(notif['completed_date']);
                        String formattedDate = DateFormat('MMM d, yyyy - h:mm a').format(date);
                        
                        String text = LocalAuthService().isAdmin 
                          ? "${notif['username']} completed: ${notif['title']}"
                          : "You completed: ${notif['title']}";

                        return ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
                            child: const Icon(Icons.check_circle, color: Colors.green, size: 24),
                          ),
                          title: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          subtitle: Text(formattedDate, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        );
                      },
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}
