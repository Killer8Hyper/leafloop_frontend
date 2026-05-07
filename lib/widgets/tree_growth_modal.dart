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

  // Pre-fetch growth data before showing the dialog
  int? userId = LocalAuthService().currentUserId;
  double growthValue = 0.0;
  int newStreak = 0;

  if (userId != null) {
    try {
      final stats = await DatabaseHelper().getUserMissionStats(userId);
      final user = await DatabaseHelper().getUserById(userId);
      growthValue = await OfflineAIService().predictGrowth(stats);
      newStreak = user?['current_streak'] ?? 0;
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
      growthValue: growthValue,
      currentStreak: newStreak,
    ),
  );
}

class _TreeGrowthDialog extends StatefulWidget {
  final String missionTitle;
  final int xpReward;
  final String difficulty;
  final double growthValue;
  final int currentStreak;

  const _TreeGrowthDialog({
    required this.missionTitle,
    required this.xpReward,
    required this.difficulty,
    required this.growthValue,
    required this.currentStreak,
  });

  @override
  State<_TreeGrowthDialog> createState() => _TreeGrowthDialogState();
}

class _TreeGrowthDialogState extends State<_TreeGrowthDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _lottieController;
  late Animation<double> _scaleAnimation;

  // Separate controller for the entry scale/fade animation
  late AnimationController _fadeScaleController;

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
    final pct = (widget.growthValue * 100).round();
    if (pct >= 80) return 'Ancient Tree 🌳';
    if (pct >= 60) return 'Tall Tree 🌲';
    if (pct >= 40) return 'Growing Tree 🌿';
    if (pct >= 20) return 'Sapling 🌱';
    return 'Seedling 🌾';
  }

  String get _congratsMessage {
    if (widget.currentStreak >= 7) {
      return 'On fire! ${widget.currentStreak} day streak! 🔥';
    } else if (widget.currentStreak >= 3) {
      return 'Great streak! Keep it up! 💪';
    }
    return 'Every action counts for the planet!';
  }

  @override
  Widget build(BuildContext context) {
    final pct = (widget.growthValue * 100).round();

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
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
                padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF3B5236), const Color(0xFF5C8A52)],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
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

              // ── XP + Streak row ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Row(
                  children: [
                    _StatChip(
                      icon: Icons.bolt,
                      label: '+${widget.xpReward} XP',
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 10),
                    _StatChip(
                      icon: Icons.local_fire_department,
                      label: '${widget.currentStreak} Day Streak',
                      color: Colors.deepOrange,
                    ),
                    const SizedBox(width: 10),
                    _StatChip(
                      icon: Icons.flag,
                      label: widget.difficulty,
                      color: _diffColor,
                    ),
                  ],
                ),
              ),

              // ── Lottie Tree ──────────────────────────────────────────
              SizedBox(
                height: 220,
                child: Lottie.asset(
                  'assets/animations/tree.json',
                  controller: _lottieController,
                  delegates: LottieDelegates(
                    values: [
                      ValueDelegate.opacity(['**', 'Background', '**'], value: 0),
                      ValueDelegate.opacity(['**', 'Solid', '**'], value: 0),
                    ],
                  ),
                  onLoaded: (composition) {
                    _lottieController.duration = composition.duration;
                    _lottieController.value = 0.0;
                    _lottieController.animateTo(
                      widget.growthValue,
                      curve: Curves.easeInOut,
                      duration: const Duration(seconds: 2),
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
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: widget.growthValue),
                        duration: const Duration(seconds: 2),
                        curve: Curves.easeInOut,
                        builder: (_, value, __) => LinearProgressIndicator(
                          value: value,
                          minHeight: 12,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF5C8A52)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _congratsMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

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

  const _StatChip({required this.icon, required this.label, required this.color});

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
