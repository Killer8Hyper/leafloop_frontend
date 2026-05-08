import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:leafloop/database/database_helper.dart';
import 'package:leafloop/services/local_auth_service.dart';
import 'package:leafloop/services/offline_ai_service.dart';

/// Shows a full-screen celebration dialog with the animated growth tree
/// after a mission is completed. Call via [showTreeGrowthModal].
Future<void> showTreeGrowthModal(
  BuildContext context, {
  required String missionTitle,
  required int xpReward,
  required String difficulty,
}) async {
  if (!context.mounted) return;

  // Pre-fetch growth data — get BEFORE and AFTER so we can show the delta
  int? userId = LocalAuthService().currentUserId;
  double previousGrowth = 0.0;
  double newGrowth = 0.0;
  int currentStreak = 0;

  if (userId != null) {
    try {
      final stats = await DatabaseHelper().getUserMissionStats(userId);
      final user = await DatabaseHelper().getUserById(userId);
      currentStreak = user?['current_streak'] ?? 0;

      // Current growth is the "new" value after completing the mission
      newGrowth = await OfflineAIService().predictGrowth(stats);

      // Estimate previous growth: subtract this mission's contribution
      // by decrementing total and the relevant difficulty count
      int diffInt = difficulty == 'Hard' ? 3 : (difficulty == 'Medium' ? 2 : 1);
      final prevStats = Map<String, dynamic>.from(stats);
      prevStats['total_missions'] =
          (((prevStats['total_missions'] ?? 1) as num) - 1).clamp(0, 9999);
      if (diffInt == 1) {
        prevStats['easy_count'] =
            (((prevStats['easy_count'] ?? 1) as num) - 1).clamp(0, 9999);
      } else if (diffInt == 2) {
        prevStats['medium_count'] =
            (((prevStats['medium_count'] ?? 1) as num) - 1).clamp(0, 9999);
      } else {
        prevStats['hard_count'] =
            (((prevStats['hard_count'] ?? 1) as num) - 1).clamp(0, 9999);
      }
      previousGrowth = await OfflineAIService().predictGrowth(prevStats);
    } catch (_) {}
  }

  if (!context.mounted) return;

  await showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.75),
    builder: (ctx) => _TreeGrowthDialog(
      missionTitle: missionTitle,
      xpReward: xpReward,
      difficulty: difficulty,
      previousGrowth: previousGrowth,
      newGrowth: newGrowth,
      currentStreak: currentStreak,
    ),
  );
}

class _TreeGrowthDialog extends StatefulWidget {
  final String missionTitle;
  final int xpReward;
  final String difficulty;
  final double previousGrowth;
  final double newGrowth;
  final int currentStreak;

  const _TreeGrowthDialog({
    required this.missionTitle,
    required this.xpReward,
    required this.difficulty,
    required this.previousGrowth,
    required this.newGrowth,
    required this.currentStreak,
  });

  @override
  State<_TreeGrowthDialog> createState() => _TreeGrowthDialogState();
}

class _TreeGrowthDialogState extends State<_TreeGrowthDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _lottieController;
  late AnimationController _fadeScaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _fadeScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _fadeScaleController,
      curve: Curves.easeOutBack,
    );

    _fadeScaleController.forward();
  }

  @override
  void dispose() {
    _lottieController.dispose();
    _fadeScaleController.dispose();
    super.dispose();
  }

  Color get _diffColor {
    switch (widget.difficulty) {
      case 'Medium':
        return Colors.orange;
      case 'Hard':
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  String get _growthLabel {
    final pct = (widget.newGrowth * 100).round();
    if (pct >= 80) return 'Ancient Tree 🌳';
    if (pct >= 60) return 'Tall Tree 🌲';
    if (pct >= 40) return 'Growing Tree 🌿';
    if (pct >= 20) return 'Sapling 🌱';
    return 'Seedling 🌾';
  }

  /// Returns a streak-aware tip explaining how the streak grows the tree.
  String get _streakTip {
    if (widget.currentStreak == 0) {
      return 'Start a streak! Complete a mission every day to watch your tree grow faster.';
    } else if (widget.currentStreak == 1) {
      return '1 day streak started! 🌱 Keep going tomorrow — streaks power your tree\'s growth!';
    } else if (widget.currentStreak < 3) {
      return '${widget.currentStreak} day streak! Your tree gains +30% growth from consistent daily missions.';
    } else if (widget.currentStreak < 7) {
      return '${widget.currentStreak} day streak! 💪 Just ${7 - widget.currentStreak} more days for max streak bonus!';
    } else {
      return '🔥 ${widget.currentStreak} day streak! Your tree is thriving from your consistency!';
    }
  }

  @override
  Widget build(BuildContext context) {
    final newPct = (widget.newGrowth * 100).round();
    final prevPct = (widget.previousGrowth * 100).round();
    final deltaPct = newPct - prevPct;

    // Streak tier for the progress pill
    final streakTier = widget.currentStreak >= 7
        ? 3
        : widget.currentStreak >= 3
            ? 2
            : widget.currentStreak >= 1
                ? 1
                : 0;
    final streakTierColors = [Colors.grey, Colors.green, Colors.orange, Colors.red];
    final streakTierLabels = ['No Streak', 'Growing', 'Hot Streak', 'On Fire 🔥'];

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header ──────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 22, horizontal: 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF3B5236), Color(0xFF5C8A52)],
                  ),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    const Text(
                      '🎉 Mission Complete!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '"${widget.missionTitle}"',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              // ── XP + Streak + Difficulty row ─────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Row(
                  children: [
                    _StatChip(
                      icon: Icons.bolt,
                      label: '+${widget.xpReward} XP',
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      icon: Icons.local_fire_department,
                      label: '${widget.currentStreak}d Streak',
                      color: Colors.deepOrange,
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      icon: Icons.flag,
                      label: widget.difficulty,
                      color: _diffColor,
                    ),
                  ],
                ),
              ),

              // ── Lottie Tree (animates from prev → new) ───────────────
              SizedBox(
                height: 200,
                child: Lottie.asset(
                  'assets/animations/tree.json',
                  controller: _lottieController,
                  delegates: LottieDelegates(
                    values: [
                      ValueDelegate.opacity(
                          ['**', 'Background', '**'], value: 0),
                      ValueDelegate.opacity(['**', 'Solid', '**'], value: 0),
                    ],
                  ),
                  onLoaded: (composition) {
                    _lottieController.duration = composition.duration;
                    // Start at the previous growth level, then animate TO the new level
                    _lottieController.value = widget.previousGrowth;
                    _lottieController.animateTo(
                      widget.newGrowth,
                      curve: Curves.easeInOut,
                      duration: const Duration(milliseconds: 1800),
                    );
                  },
                ),
              ),

              // ── Growth label + progress bar ──────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _growthLabel,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        Row(
                          children: [
                            if (deltaPct > 0)
                              Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '+$deltaPct%',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            Text(
                              '$newPct%',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3B5236),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(
                            begin: widget.previousGrowth, end: widget.newGrowth),
                        duration: const Duration(milliseconds: 1800),
                        curve: Curves.easeInOut,
                        builder: (_, value, __) => LinearProgressIndicator(
                          value: value,
                          minHeight: 12,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF5C8A52)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Streak tier pill ─────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 14),
                      decoration: BoxDecoration(
                        color: streakTierColors[streakTier]
                            .withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: streakTierColors[streakTier]
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.park,
                              size: 18,
                              color: streakTierColors[streakTier]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Streak Tier: ',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      streakTierLabels[streakTier],
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: streakTierColors[streakTier],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  _streakTip,
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Close button ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B5236),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Keep Growing! 🌱',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
