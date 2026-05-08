import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:leafloop/screens/homepage.dart';
import 'package:leafloop/screens/eco_timeline.dart';
import 'package:leafloop/screens/missions.dart';
import 'package:leafloop/screens/profile.dart';
import 'package:leafloop/widgets/nav_menu.dart';
import 'package:leafloop/database/database_helper.dart';
import 'package:leafloop/services/local_auth_service.dart';
import 'package:leafloop/screens/admin/users_list.dart';
import 'package:leafloop/screens/settings_pages/edit_missions.dart';
import 'package:leafloop/services/offline_ai_service.dart';

class TreeGrowthScreen extends StatefulWidget {
  const TreeGrowthScreen({super.key});

  @override
  State<TreeGrowthScreen> createState() => _TreeGrowthScreenState();
}

class _TreeGrowthScreenState extends State<TreeGrowthScreen>
    with SingleTickerProviderStateMixin {
  double _currentGrowth = 0.0;
  int _longestStreak = 0;
  int _currentStreak = 0;
  int _totalMissions = 0;
  late AnimationController _lottieController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      int? userId = LocalAuthService().currentUserId;
      if (userId != null) {
        var stats = await DatabaseHelper().getUserMissionStats(userId);
        var user = await DatabaseHelper().getUserById(userId);

        double aiGrowth = await OfflineAIService().predictGrowth(stats);

        if (mounted) {
          setState(() {
            _longestStreak = user?['longest_streak'] ?? 0;
            _currentStreak = user?['current_streak'] ?? 0;
            _totalMissions = stats['total_missions'] ?? 0;
            _currentGrowth = aiGrowth;
            _isLoading = false;
          });

          _lottieController.animateTo(
            _currentGrowth,
            curve: Curves.easeInOut,
            duration: const Duration(seconds: 2),
          );
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String get _growthLabel {
    final pct = (_currentGrowth * 100).round();
    if (pct >= 80) return 'Ancient Tree 🌳';
    if (pct >= 60) return 'Tall Tree 🌲';
    if (pct >= 40) return 'Growing Tree 🌿';
    if (pct >= 20) return 'Sapling 🌱';
    return 'Seedling 🌾';
  }

  String get _streakStatusMessage {
    if (_currentStreak == 0) {
      return 'Complete a mission today to start your streak!';
    } else if (_currentStreak < 3) {
      return 'Keep going! ${3 - _currentStreak} more day${(3 - _currentStreak) > 1 ? "s" : ""} to reach a Hot Streak.';
    } else if (_currentStreak < 7) {
      return '${7 - _currentStreak} more day${(7 - _currentStreak) > 1 ? "s" : ""} to reach max streak bonus! 💪';
    } else {
      return 'Max streak bonus active! Your tree grows 30% faster! 🔥';
    }
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pct = (_currentGrowth * 100).round();
    final streakTier = _currentStreak >= 7
        ? 3
        : _currentStreak >= 3
            ? 2
            : _currentStreak >= 1
                ? 1
                : 0;
    final tierColors = [Colors.grey, const Color(0xFF5C8A52), Colors.orange, Colors.red];
    final tierIcons = [Icons.eco_outlined, Icons.eco, Icons.local_fire_department, Icons.whatshot];
    final tierLabels = ['No Streak', 'Growing (+14%)', 'Hot Streak (+22%)', 'On Fire! (+30%) 🔥'];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            Text(
              'Growth Tree',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
            Spacer(),
            Icon(Icons.park, size: 45, color: Color(0xFF90C152)),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ── Stats row ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.local_fire_department,
                      iconColor: Colors.deepOrange,
                      label: 'Current Streak',
                      value: '$_currentStreak days',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.emoji_events,
                      iconColor: Colors.amber,
                      label: 'Longest Streak',
                      value: '$_longestStreak days',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.check_circle_outline,
                      iconColor: const Color(0xFF5C8A52),
                      label: 'Missions Done',
                      value: '$_totalMissions',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Lottie tree ───────────────────────────────────────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 240,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : RepaintBoundary(
                        child: Lottie.asset(
                          'assets/animations/tree.json',
                          controller: _lottieController,
                          delegates: LottieDelegates(
                            values: [
                              ValueDelegate.opacity(
                                  ['**', 'Background', '**'], value: 0),
                              ValueDelegate.opacity(
                                  ['**', 'Solid', '**'], value: 0),
                            ],
                          ),
                          onLoaded: (composition) {
                            _lottieController.duration = composition.duration;
                            _lottieController.value = 0.0;
                            _lottieController.animateTo(
                              _currentGrowth,
                              curve: Curves.easeInOut,
                              duration: const Duration(seconds: 2),
                            );
                          },
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Growth % progress bar ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _growthLabel,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        Text(
                          '$pct%',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3B5236),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: _currentGrowth,
                        minHeight: 14,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF5C8A52)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Complete missions every day to advance your tree\'s stage.',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Streak tier indicator ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How Streaks Grow Your Tree',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _streakStatusMessage,
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 14),
                    ...List.generate(4, (i) {
                      bool isActive = streakTier == i;
                      bool isPassed = streakTier > i;
                      final color = isPassed || isActive
                          ? tierColors[i]
                          : Colors.grey.shade300;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: color, width: 1.5),
                              ),
                              child: Icon(tierIcons[i],
                                  size: 18, color: color),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                tierLabels[i],
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isActive
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isActive
                                      ? tierColors[i]
                                      : isPassed
                                          ? Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.color
                                          : Colors.grey,
                                ),
                              ),
                            ),
                            if (isActive)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: tierColors[i]
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'CURRENT',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: tierColors[i],
                                  ),
                                ),
                              )
                            else if (isPassed)
                              Icon(Icons.check_circle,
                                  color: tierColors[i], size: 18),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Growth formula breakdown ──────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tree Growth Formula',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _FormulaRow(
                        label: 'Mission Volume',
                        hint: '(up to 30 missions)',
                        weight: '45%',
                        color: const Color(0xFF5C8A52)),
                    const SizedBox(height: 8),
                    _FormulaRow(
                        label: 'Mission Difficulty',
                        hint: 'Hard > Medium > Easy',
                        weight: '25%',
                        color: Colors.orange),
                    const SizedBox(height: 8),
                    _FormulaRow(
                        label: 'Daily Streak',
                        hint: '7-day streak = max bonus',
                        weight: '30%',
                        color: Colors.deepOrange),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }


  Widget _buildBottomNav(BuildContext context) {
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
              _buildNavItem(Icons.home_outlined, "Home", () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomePage()),
                  (route) => false,
                );
              }),
              _buildNavItem(LocalAuthService().isAdmin ? Icons.people : Icons.access_time, LocalAuthService().isAdmin ? "Users" : "Eco Timeline", () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => LocalAuthService().isAdmin ? const UsersListScreen() : const EcoTimeline()),
                );
              }),
              const SizedBox(width: 50), // Space for center logo
              _buildNavItem(LocalAuthService().isAdmin ? Icons.settings_suggest : Icons.track_changes, LocalAuthService().isAdmin ? "Manage" : "Missions", () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => LocalAuthService().isAdmin ? const EditMissionsScreen() : const MissionsScreen(),
                  ),
                );
              }, isActive: false),
              _buildNavItem(Icons.person_outline, "Profile", () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
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
}

/// Small stat card used in the 3-column top row.
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

/// Row showing a growth formula factor with its weight badge.
class _FormulaRow extends StatelessWidget {
  final String label;
  final String hint;
  final String weight;
  final Color color;

  const _FormulaRow({
    required this.label,
    required this.hint,
    required this.weight,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold),
              ),
              Text(
                hint,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            weight,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
