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
      // Attempt to load the TFLite model from assets
      // We use a try-catch to detect if the model exists. 
      // If it doesn't, we simply use the heuristic fallback.
      _interpreter = await Interpreter.fromAsset('assets/models/leafloop_model.tflite');
      _isLoaded = true;
      debugPrint("Offline AI: Model loaded successfully.");
    } catch (e) {
      // Silencing the error since the heuristic fallback is the intended behavior when no model is provided
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
      // Input features mapping:
      // Index 0: Energy Level (1-3)
      // Index 1: Total Missions Completed
      // Index 2: Easy Missions
      // Index 3: Medium Missions
      // Index 4: Hard Missions
      // Index 5: Current Streak
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
      
      // Output buffer
      var output = List.filled(1, 0.0).reshape([1, 1]);
      
      _interpreter!.run(input, output);
      
      double prediction = output[0][0];
      return prediction.clamp(0.0, 1.0);
    } catch (e) {
      print("Offline AI: Inference error, falling back to heuristic. Error: $e");
      return _calculateHeuristicGrowth(stats);
    }
  }

  /// Heuristic fallback logic for growth prediction.
  /// Weighting: 
  /// - 60% based on total missions (capped at 100)
  /// - 20% based on difficulty weights (harder = more growth)
  /// - 20% based on consistency (streak)
  double _calculateHeuristicGrowth(Map<String, dynamic> stats) {
    double total = (stats['total_missions'] ?? 0).toDouble();
    double easy = (stats['easy_count'] ?? 0).toDouble();
    double medium = (stats['medium_count'] ?? 0).toDouble();
    double hard = (stats['hard_count'] ?? 0).toDouble();
    double streak = (stats['current_streak'] ?? 0).toDouble();

    // Base growth from volume (capped at 100 missions for 1.0 growth)
    double volumeScore = (total / 100.0).clamp(0.0, 1.0);

    // Difficulty score (Harder missions contribute more)
    double difficultyScore = ((easy * 1 + medium * 2 + hard * 3) / 200.0).clamp(0.0, 1.0);

    // Streak bonus (Consistency)
    double streakScore = (streak / 30.0).clamp(0.0, 1.0);

    // Combine with weights
    double finalGrowth = (volumeScore * 0.6) + (difficultyScore * 0.2) + (streakScore * 0.2);
    
    return finalGrowth.clamp(0.0, 1.0);
  }

  void dispose() {
    _interpreter?.close();
  }
}
