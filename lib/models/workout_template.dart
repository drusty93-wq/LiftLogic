import 'dart:convert';

class Exercise {
  final String id;
  final String name;
  final double currentWeight;
  final int targetReps;
  final int failureStreak; // NEW: Vital for the deload logic

  Exercise({
    required this.id,
    required this.name,
    required this.currentWeight,
    required this.targetReps,
    this.failureStreak = 0, // Defaults to 0 for new exercises
  });

  // This helper method allows you to update the model easily
  Exercise copyWith({
    double? currentWeight,
    int? failureStreak,
  }) {
    return Exercise(
      id: id,
      name: name,
      currentWeight: currentWeight ?? this.currentWeight,
      targetReps: targetReps,
      failureStreak: failureStreak ?? this.failureStreak,
    );
  }

  // Standard JSON conversion for Database/API storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'currentWeight': currentWeight,
    'targetReps': targetReps,
    'failureStreak': failureStreak,
  };

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
    id: json['id'],
    name: json['name'],
    currentWeight: json['currentWeight'].toDouble(),
    targetReps: json['targetReps'],
    failureStreak: json['failureStreak'] ?? 0,
  );
}

class WorkoutTemplate {
  final String name;
  final List<String> exercises;

  WorkoutTemplate({required this.name, required this.exercises});

  Map<String, dynamic> toJson() => {
        'name': name,
        'exercises': exercises,
      };

  factory WorkoutTemplate.fromJson(Map<String, dynamic> json) {
    return WorkoutTemplate(
      name: json['name'] as String,
      exercises: List<String>.from(json['exercises'] ?? <String>[]),
    );
  }

  static List<WorkoutTemplate> sampleTemplates() => [
        WorkoutTemplate(
          name: 'Push/Pull/Legs',
          exercises: ['Bench Press', 'Overhead Press', 'Pull-ups', 'Barbell Row', 'Squat', 'Romanian Deadlift'],
        ),
        WorkoutTemplate(
          name: 'Upper/Lower',
          exercises: ['Bench Press', 'Dumbbell Row', 'Squat', 'Deadlift'],
        ),
        WorkoutTemplate(
          name: 'Full Body',
          exercises: ['Squat', 'Bench Press', 'Deadlift'],
        ),
      ];

  @override
  String toString() => jsonEncode(toJson());
}
