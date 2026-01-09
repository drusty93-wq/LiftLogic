// Pre-defined workout types and exercises
class WorkoutExercise {
  final String id;
  final String name;
  final int targetSets;
  final int targetReps;

  const WorkoutExercise({
    required this.id,
    required this.name,
    required this.targetSets,
    required this.targetReps,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'targetSets': targetSets,
    'targetReps': targetReps,
  };

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) =>
      WorkoutExercise(
        id: json['id'],
        name: json['name'],
        targetSets: json['targetSets'],
        targetReps: json['targetReps'],
      );
}

class WorkoutType {
  final String id;
  final String name;
  final List<WorkoutExercise> exercises;

  const WorkoutType({
    required this.id,
    required this.name,
    required this.exercises,
  });

  static final List<WorkoutType> predefined = [
    WorkoutType(
      id: 'shoulder',
      name: 'Shoulder Workout',
      exercises: [
        WorkoutExercise(
          id: 'ohp',
          name: 'Overhead Press (Dumbbell or Barbell)',
          targetSets: 4,
          targetReps: 8,
        ),
        WorkoutExercise(
          id: 'lateral_raises',
          name: 'Lateral Raises',
          targetSets: 3,
          targetReps: 12,
        ),
        WorkoutExercise(
          id: 'face_pulls',
          name: 'Face Pulls',
          targetSets: 3,
          targetReps: 15,
        ),
        WorkoutExercise(
          id: 'dumbbell_front_raises',
          name: 'Dumbbell Front Raises',
          targetSets: 3,
          targetReps: 12,
        ),
      ],
    ),
    WorkoutType(
      id: 'arm',
      name: 'Arm Workout',
      exercises: [
        WorkoutExercise(
          id: 'barbell_curls',
          name: 'Barbell Bicep Curls',
          targetSets: 4,
          targetReps: 8,
        ),
        WorkoutExercise(
          id: 'triceps_pushdowns',
          name: 'Triceps Push Downs',
          targetSets: 3,
          targetReps: 12,
        ),
        WorkoutExercise(
          id: 'hammer_curls',
          name: 'Hammer Curls',
          targetSets: 3,
          targetReps: 10,
        ),
        WorkoutExercise(
          id: 'skull_crushers',
          name: 'Skull Crushers (EZ Bar)',
          targetSets: 3,
          targetReps: 8,
        ),
      ],
    ),
    WorkoutType(
      id: 'leg',
      name: 'Leg Workout',
      exercises: [
        WorkoutExercise(
          id: 'barbell_squats',
          name: 'Barbell Squats',
          targetSets: 4,
          targetReps: 6,
        ),
        WorkoutExercise(
          id: 'leg_press',
          name: 'Leg Press',
          targetSets: 3,
          targetReps: 8,
        ),
        WorkoutExercise(
          id: 'romanian_deadlifts',
          name: 'Romanian Deadlifts',
          targetSets: 3,
          targetReps: 8,
        ),
        WorkoutExercise(
          id: 'leg_extensions',
          name: 'Leg Extensions',
          targetSets: 3,
          targetReps: 12,
        ),
      ],
    ),
    WorkoutType(
      id: 'chest',
      name: 'Chest Workout',
      exercises: [
        WorkoutExercise(
          id: 'incline_press',
          name: 'Incline Dumbbell Press',
          targetSets: 4,
          targetReps: 8,
        ),
        WorkoutExercise(
          id: 'flat_bench',
          name: 'Flat Bench Press (Barbell or Dumbbell)',
          targetSets: 4,
          targetReps: 8,
        ),
        WorkoutExercise(
          id: 'chest_dips',
          name: 'Chest Dips',
          targetSets: 3,
          targetReps: 8,
        ),
        WorkoutExercise(
          id: 'cable_flyes',
          name: 'Cable Flyes',
          targetSets: 3,
          targetReps: 12,
        ),
      ],
    ),
    WorkoutType(
      id: 'back',
      name: 'Back Workout',
      exercises: [
        WorkoutExercise(
          id: 'pullups',
          name: 'Pull-Ups or Lat Pull Downs',
          targetSets: 4,
          targetReps: 8,
        ),
        WorkoutExercise(
          id: 'barbell_rows',
          name: 'Bent Over Barbell Rows',
          targetSets: 4,
          targetReps: 6,
        ),
        WorkoutExercise(
          id: 'cable_rows',
          name: 'Seated Cable Rows',
          targetSets: 3,
          targetReps: 10,
        ),
        WorkoutExercise(
          id: 'dumbbell_rows',
          name: 'Single Arm Dumbbell Rows',
          targetSets: 3,
          targetReps: 10,
        ),
      ],
    ),
    WorkoutType(
      id: 'core',
      name: 'Core Workout',
      exercises: [
        WorkoutExercise(
          id: 'leg_raises',
          name: 'Hanging Leg Raises',
          targetSets: 3,
          targetReps: 12,
        ),
        WorkoutExercise(
          id: 'cable_crunches',
          name: 'Weighted Cable Crunches',
          targetSets: 3,
          targetReps: 15,
        ),
        WorkoutExercise(
          id: 'weighted_plank',
          name: 'Plank with Weight',
          targetSets: 3,
          targetReps: 45,
        ),
        WorkoutExercise(
          id: 'russian_twists',
          name: 'Russian Twists',
          targetSets: 3,
          targetReps: 20,
        ),
      ],
    ),
  ];

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'exercises': exercises.map((e) => e.toJson()).toList(),
  };

  factory WorkoutType.fromJson(Map<String, dynamic> json) => WorkoutType(
    id: json['id'],
    name: json['name'],
    exercises: List<WorkoutExercise>.from(
      (json['exercises'] as List).map(
        (e) => WorkoutExercise.fromJson(e as Map<String, dynamic>),
      ),
    ),
  );
}

// Recording a set during workout
class SetRecord {
  final int setNumber;
  final int repsCompleted;
  final double? weight;

  const SetRecord({
    required this.setNumber,
    required this.repsCompleted,
    this.weight,
  });

  Map<String, dynamic> toJson() => {
    'setNumber': setNumber,
    'repsCompleted': repsCompleted,
    'weight': weight,
  };

  factory SetRecord.fromJson(Map<String, dynamic> json) => SetRecord(
    setNumber: json['setNumber'],
    repsCompleted: json['repsCompleted'],
    weight: json['weight'],
  );
}

// Recording exercise results for a workout session
class ExerciseRecord {
  final String exerciseId;
  final String exerciseName;
  final List<SetRecord> sets;

  const ExerciseRecord({
    required this.exerciseId,
    required this.exerciseName,
    required this.sets,
  });

  int get totalReps => sets.fold(0, (sum, set) => sum + set.repsCompleted);
  double? get maxWeight => sets.isEmpty
      ? null
      : sets.map((s) => s.weight ?? 0).reduce((a, b) => a > b ? a : b);

  Map<String, dynamic> toJson() => {
    'exerciseId': exerciseId,
    'exerciseName': exerciseName,
    'sets': sets.map((s) => s.toJson()).toList(),
  };

  factory ExerciseRecord.fromJson(Map<String, dynamic> json) => ExerciseRecord(
    exerciseId: json['exerciseId'],
    exerciseName: json['exerciseName'],
    sets: List<SetRecord>.from(
      (json['sets'] as List).map(
        (s) => SetRecord.fromJson(s as Map<String, dynamic>),
      ),
    ),
  );
}

// Complete workout session recording
class WorkoutRecord {
  final String id;
  final String workoutTypeId;
  final String workoutTypeName;
  final DateTime date;
  final List<ExerciseRecord> exercises;

  const WorkoutRecord({
    required this.id,
    required this.workoutTypeId,
    required this.workoutTypeName,
    required this.date,
    required this.exercises,
  });

  String get formattedDate => _formatDate(date);

  static String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final workoutDate = DateTime(date.year, date.month, date.day);

    if (workoutDate == today) {
      return 'Today • ${_timeFormat(date)}';
    } else if (workoutDate == yesterday) {
      return 'Yesterday • ${_timeFormat(date)}';
    } else {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} • ${_timeFormat(date)}';
    }
  }

  static String _timeFormat(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'workoutTypeId': workoutTypeId,
    'workoutTypeName': workoutTypeName,
    'date': date.toIso8601String(),
    'exercises': exercises.map((e) => e.toJson()).toList(),
  };

  factory WorkoutRecord.fromJson(Map<String, dynamic> json) => WorkoutRecord(
    id: json['id'],
    workoutTypeId: json['workoutTypeId'],
    workoutTypeName: json['workoutTypeName'],
    date: DateTime.parse(json['date']),
    exercises: List<ExerciseRecord>.from(
      (json['exercises'] as List).map(
        (e) => ExerciseRecord.fromJson(e as Map<String, dynamic>),
      ),
    ),
  );
}

// User profile
class UserProfile {
  final String name;
  final String bio;
  final List<String> strengths;
  final List<String> areasForImprovement;

  const UserProfile({
    this.name = '',
    this.bio = '',
    this.strengths = const [],
    this.areasForImprovement = const [],
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'bio': bio,
    'strengths': strengths,
    'areasForImprovement': areasForImprovement,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] ?? '',
    bio: json['bio'] ?? '',
    strengths: List<String>.from(json['strengths'] ?? []),
    areasForImprovement: List<String>.from(json['areasForImprovement'] ?? []),
  );
}
