import 'dart:io';
import 'dart:math';

void main() {
  final random = Random();
  final file = File('growth_training_data.csv');
  final sink = file.openWrite();

  sink.writeln('energy_level,total_missions,easy_count,medium_count,hard_count,current_streak,target_growth');

  for (int i = 0; i < 1000; i++) {
    int energy = random.nextInt(3) + 1;
    int easy = random.nextInt(21);
    int medium = random.nextInt(16);
    int hard = random.nextInt(11);
    int total = easy + medium + hard;
    int streak = random.nextInt(31);

    double volumeScore = (total / 50.0).clamp(0.0, 1.0);
    double difficultyScore = ((easy * 1 + medium * 2 + hard * 3) / 100.0).clamp(0.0, 1.0);
    double streakScore = (streak / 30.0).clamp(0.0, 1.0);

    double growth = (volumeScore * 0.6) + (difficultyScore * 0.2) + (streakScore * 0.2);
    growth = growth.clamp(0.0, 1.0);

    sink.writeln('$energy,$total,$easy,$medium,$hard,$streak,${growth.toStringAsFixed(4)}');
  }

  sink.close();
  print('Successfully generated growth_training_data.csv with 1000 rows.');
}
