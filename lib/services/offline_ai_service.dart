import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;

class OfflineAIService {
  static final OfflineAIService _instance = OfflineAIService._internal();
  factory OfflineAIService() => _instance;
  OfflineAIService._internal();

  Interpreter? _interpreter;
  bool _isLoaded = false;

  Future<void> init() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/leafloop_model.tflite');
      _isLoaded = true;
      debugPrint("Offline AI: Model loaded successfully.");
    } catch (e) {
      debugPrint("Offline AI: No model found. Operating in heuristic mode.");
      _isLoaded = false;
    }
  }

  /// Predicts the growth percentage (0.0 to 1.0) based on user statistics.
  /// Uses a TFLite model if available, otherwise falls back to a weighted heuristic.
  Future<double> predictGrowth(Map<String, dynamic> stats) async {
    if (!_isLoaded || _interpreter == null) {
      return _calculateHeuristicGrowth(stats);
    }

    try {
      var input = [
        [
          (stats['energy_level'] ?? 2).toDouble(),
          (stats['total_missions'] ?? 0).toDouble(),
          (stats['easy_count'] ?? 0).toDouble(),
          (stats['medium_count'] ?? 0).toDouble(),
          (stats['hard_count'] ?? 0).toDouble(),
          (stats['current_streak'] ?? 0).toDouble(),
        ]
      ];

      var output = List.filled(1, 0.0).reshape([1, 1]);
      _interpreter!.run(input, output);
      double prediction = output[0][0];
      return prediction.clamp(0.0, 1.0);
    } catch (e) {
      debugPrint("Offline AI: Inference error, falling back to heuristic. Error: $e");
      return _calculateHeuristicGrowth(stats);
    }
  }

  /// Heuristic growth formula designed so players feel meaningful progress early.
  ///
  /// Growth sources (add up to 1.0 max):
  ///   • Volume score   (45%) — sqrt curve; 30 missions ≈ full 45%
  ///   • Difficulty score (25%) — hard missions count 3×, capped at 60 weighted points
  ///   • Streak score   (30%) — 7-day streak ≈ full 30%; daily missions = biggest lever
  ///
  /// Using sqrt so the FIRST few completions feel rewarding instead of invisible.
  double _calculateHeuristicGrowth(Map<String, dynamic> stats) {
    double total = (stats['total_missions'] ?? 0).toDouble();
    double easy = (stats['easy_count'] ?? 0).toDouble();
    double medium = (stats['medium_count'] ?? 0).toDouble();
    double hard = (stats['hard_count'] ?? 0).toDouble();
    double streak = (stats['current_streak'] ?? 0).toDouble();

    // --- Volume score (45%): sqrt curve, saturates at 30 missions ---
    // sqrt(1/30) ≈ 0.183 after 1 mission — immediately visible
    double volumeScore = math.sqrt((total / 30.0).clamp(0.0, 1.0));

    // --- Difficulty score (25%): weighted XP, saturates at 60 pts ---
    // Easy=1pt, Medium=2pt, Hard=3pt
    double weightedPoints = (easy * 1) + (medium * 2) + (hard * 3);
    double difficultyScore = (weightedPoints / 60.0).clamp(0.0, 1.0);

    // --- Streak score (30%): saturates at 7 consecutive days ---
    // 1-day streak = ~14%, 3 days = ~43%, 7 days = 100%
    double streakScore = math.sqrt((streak / 7.0).clamp(0.0, 1.0));

    // Combine with weights
    double finalGrowth =
        (volumeScore * 0.45) + (difficultyScore * 0.25) + (streakScore * 0.30);

    return finalGrowth.clamp(0.0, 1.0);
  }

  void dispose() {
    _interpreter?.close();
  }
}
