// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/app_state.dart';
import 'models/workout_template.dart';
import 'models/workout_session.dart';
import 'models/workout_data.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final AppState _appState = AppState();
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _appState.load();
    setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return ChangeNotifierProvider<AppState>.value(
      value: _appState,
      child: Consumer<AppState>(
        builder: (context, state, _) {
          return MaterialApp(
            title: 'Lift Logic',
            theme: ThemeData(primarySwatch: Colors.blue),
            home: const MainScaffold(),
          );
        },
      ),
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    WorkoutsPage(),
    PastWorkoutsPage(),
    OptionsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gym Workout Tracker')),
      body: _pages[_selectedIndex < _pages.length ? _selectedIndex : 0],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center, color: Colors.black54),
            label: 'Home',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.history, color: Colors.black54),
              label: 'Past'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings, color: Colors.black54),
              label: 'Settings'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black87,
      ),
    );
  }
}

class MuscleGroupExercises {
  static const Map<String, List<String>> exercises = {
    'Chest (Pectorals)': [
      'Incline Dumbbell Press (Targets the upper chest)',
      'Barbell Bench Press (Great for overall mass)',
      'Machine Chest Press (Allows for safe failure and maximum stability)',
      'Low-to-High Cable Flyes (Focuses on the squeeze and inner chest)',
      'Weighted Dips (Targets the lower chest and triceps)',
    ],
    'Back (Lats, Rhomboids, Traps)': [
      'Pull-Ups / Lat Pulldowns (Primary vertical pull for width)',
      'Bent-Over Barbell Rows (Primary horizontal pull for thickness)',
      'Single-Arm Dumbbell Rows (Great for stretch and range of motion)',
      'Seated Cable Rows (Constant tension on the mid-back)',
      'Face Pulls (Essential for rear delts and upper back posture)',
    ],
    'Legs (Quads, Hamstrings, Glutes, Calves)': [
      'Hack Squats or Leg Press (Superior for hypertrophy due to stability)',
      'Barbell Back Squats (The "king" of leg builders)',
      'Romanian Deadlifts (RDLs) (The best for hamstring and glute growth)',
      'Leg Extensions (Isolation for the quads)',
      'Seated or Lying Leg Curls (Isolation for the hamstrings)',
      'Standing Calf Raises (Heavy loads for calf development)',
    ],
    'Shoulders (Deltoids)': [
      'Seated Dumbbell Shoulder Press (Heavy overhead loading)',
      'Dumbbell Lateral Raises (Crucial for the "width" of the side delt)',
      'Cable Lateral Raises (Provides constant tension throughout the move)',
      'Reverse Pec Deck Flyes (Isolation for the rear deltoids)',
      'Barbell Overhead Press (Strong foundational compound movement)',
    ],
    'Arms (Biceps & Triceps)': [
      'Dumbbell Incline Curls (Puts the biceps in a deep stretch)',
      'Preacher Curls (Prevents cheating and isolates the short head)',
      'Hammer Curls (Targets the brachialis and forearm for thickness)',
      'Tricep Rope Pushdowns (Great for the lateral head and mind-muscle connection)',
      'Skull Crushers (EZ Bar) (Heavy loading for the long head of the tricep)',
      'Overhead Cable Tricep Extensions (Targets the triceps in the lengthened position)',
    ],
    'Core (Abs & Obliques)': [
      'Hanging Leg Raises (Targets the lower abdominals)',
      'Cable Crunches (Allows for weighted progression/overload)',
      'Ab Wheel Rollouts (Excellent for eccentric strength)',
      'Russian Twists (Weighted) (Targets the obliques)',
      'Plank with Weight Plate (Builds core stability and endurance)',
    ],
  };
}

class WorkoutsPage extends StatelessWidget {
  const WorkoutsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const Text(
              "Welcome to today's workout",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => MuscleGroupSelectorDialog(
                    onWorkoutStarted: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Workout saved successfully!'),
                        ),
                      );
                    },
                  ),
                );
              },
              child: const Text('Create Workout'),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Tap "Create Workout" to start a new workout by selecting a muscle group.',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MuscleGroupSelectorDialog extends StatefulWidget {
  final VoidCallback? onWorkoutStarted;
  final Function(String)? onExerciseSelected;
  const MuscleGroupSelectorDialog({this.onWorkoutStarted, this.onExerciseSelected, super.key});

  @override
  State<MuscleGroupSelectorDialog> createState() =>
      _MuscleGroupSelectorDialogState();
}

class _MuscleGroupSelectorDialogState extends State<MuscleGroupSelectorDialog> {
  String? _selectedMuscleGroup;
  String? _selectedExercise;

  @override
  Widget build(BuildContext context) {
    if (_selectedMuscleGroup == null) {
      return Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Muscle Group',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: MuscleGroupExercises.exercises.keys.length,
                  itemBuilder: (context, index) {
                    final muscleGroup =
                        MuscleGroupExercises.exercises.keys.elementAt(index);
                    return Card(
                      child: ListTile(
                        title: Text(muscleGroup),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () {
                          setState(() => _selectedMuscleGroup = muscleGroup);
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_selectedExercise == null) {
      final exercises =
          MuscleGroupExercises.exercises[_selectedMuscleGroup] ?? [];
      return Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedMuscleGroup!,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    return Card(
                      child: ListTile(
                        title: Text(exercise),
                        onTap: () {
                          setState(() => _selectedExercise = exercise);
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() => _selectedMuscleGroup = null);
                    },
                    child: const Text('Back'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // Handle exercise selection
    if (widget.onExerciseSelected != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
        widget.onExerciseSelected!(_selectedExercise!);
      });
    } else {
      // Start new workout with selected exercise
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
        _startWorkout(context, _selectedExercise!);
        widget.onWorkoutStarted?.call();
      });
    }

    return const Dialog(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: CircularProgressIndicator(),
      ),
    );
  }

  void _startWorkout(BuildContext context, String exerciseName) async {
    final workoutExercise = WorkoutExercise(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: exerciseName,
      targetSets: 3,
      targetReps: 8,
    );

    final workoutType = WorkoutType(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: _selectedMuscleGroup ?? 'Workout',
      exercises: [workoutExercise],
    );

    if (mounted) {
      await Navigator.of(context).push<bool?>(
        MaterialPageRoute(
          builder: (_) => WorkoutRecordingPage(workoutType: workoutType),
        ),
      );
    }
  }
}

class WorkoutRecordingPage extends StatefulWidget {
  final WorkoutType workoutType;
  const WorkoutRecordingPage({required this.workoutType, super.key});

  @override
  State<WorkoutRecordingPage> createState() => _WorkoutRecordingPageState();
}

class _WorkoutRecordingPageState extends State<WorkoutRecordingPage> {
  late List<ExerciseRecordingController> exerciseControllers;
  late TextEditingController _workoutNameController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _workoutNameController = TextEditingController(text: widget.workoutType.name);
    _notesController = TextEditingController();
    exerciseControllers = widget.workoutType.exercises
        .map(
          (ex) => ExerciseRecordingController(
            exercise: ex,
            targetSets: ex.targetSets,
          ),
        )
        .toList();
  }

  @override
  void dispose() {
    for (var controller in exerciseControllers) {
      controller.dispose();
    }
    _workoutNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveWorkout() async {
    final exercises = <ExerciseRecord>[];
    for (var controller in exerciseControllers) {
      final setRecords = controller.getSetRecords();
      if (setRecords.isNotEmpty) {
        exercises.add(
          ExerciseRecord(
            exerciseId: controller.exercise.id,
            exerciseName: controller.exercise.name,
            sets: setRecords,
          ),
        );
      }
    }

    if (exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please record at least one set')),
      );
      return;
    }

    final record = WorkoutRecord(
      id: const Uuid().v4(),
      workoutTypeId: widget.workoutType.id,
      workoutTypeName: _workoutNameController.text,
      date: DateTime.now(),
      exercises: exercises,
    );

    final state = Provider.of<AppState>(context, listen: false);
    await state.addWorkoutRecord(record);
    if (mounted) Navigator.of(context).pop(true);
  }

  void _renameWorkout() {
    final controller = TextEditingController(text: _workoutNameController.text);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Workout'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Workout Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _workoutNameController.text = controller.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _renameWorkout,
          child: Row(
            children: [
              Expanded(
                child: Text(_workoutNameController.text),
              ),
              const Icon(Icons.edit, size: 18),
            ],
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: exerciseControllers.length + 3,
        itemBuilder: (context, index) {
          if (index < exerciseControllers.length) {
            return ExerciseRecordingWidget(
              controller: exerciseControllers[index],
            );
          } else if (index == exerciseControllers.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: ElevatedButton.icon(
                onPressed: _addNewExercise,
                icon: const Icon(Icons.add),
                label: const Text('Add Another Exercise'),
              ),
            );
          } else if (index == exerciseControllers.length + 1) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Workout Notes',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          hintText: 'Add notes about your workout...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ElevatedButton(
          onPressed: _saveWorkout,
          child: const Text('Complete Workout'),
        ),
      ),
    );
  }

  void _addNewExercise() {
    showDialog(
      context: context,
      builder: (context) => MuscleGroupSelectorDialog(
        onExerciseSelected: (exerciseName) {
          final workoutExercise = WorkoutExercise(
            id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
            name: exerciseName,
            targetSets: 3,
            targetReps: 8,
          );
          setState(() {
            exerciseControllers.add(
              ExerciseRecordingController(
                exercise: workoutExercise,
                targetSets: 3,
              ),
            );
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Exercise added')),
          );
        },
      ),
    );
  }
}

class ExerciseRecordingController {
  final WorkoutExercise exercise;
  int targetSets;
  late List<TextEditingController> repsControllers;
  late List<TextEditingController> weightControllers;

  ExerciseRecordingController({
    required this.exercise,
    required this.targetSets,
  }) {
    repsControllers = List.generate(targetSets, (_) => TextEditingController());
    weightControllers = List.generate(
      targetSets,
      (_) => TextEditingController(),
    );
  }

  void addSet() {
    repsControllers.add(TextEditingController());
    weightControllers.add(TextEditingController());
    targetSets++;
  }

  List<SetRecord> getSetRecords() {
    final records = <SetRecord>[];
    for (int i = 0; i < targetSets; i++) {
      final reps = int.tryParse(repsControllers[i].text) ?? 0;
      final weight = double.tryParse(weightControllers[i].text);
      if (reps > 0) {
        records.add(
          SetRecord(setNumber: i + 1, repsCompleted: reps, weight: weight),
        );
      }
    }
    return records;
  }

  void dispose() {
    for (var controller in repsControllers) {
      controller.dispose();
    }
    for (var controller in weightControllers) {
      controller.dispose();
    }
  }
}

class ExerciseRecordingWidget extends StatefulWidget {
  final ExerciseRecordingController controller;
  const ExerciseRecordingWidget({required this.controller, super.key});

  @override
  State<ExerciseRecordingWidget> createState() =>
      _ExerciseRecordingWidgetState();
}

class _ExerciseRecordingWidgetState extends State<ExerciseRecordingWidget> {
  bool _showWeightPrompt = false;

  bool _isTargetMet() {
    int completedSets = 0;
    for (int i = 0; i < widget.controller.targetSets; i++) {
      final reps = int.tryParse(widget.controller.repsControllers[i].text) ?? 0;
      if (reps >= widget.controller.exercise.targetReps) {
        completedSets++;
      }
    }
    return completedSets == widget.controller.targetSets;
  }

  @override
  Widget build(BuildContext context) {
    final targetMet = _isTargetMet();
    if (targetMet && !_showWeightPrompt) {
      _showWeightPrompt = true;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.controller.exercise.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Target: ${widget.controller.exercise.targetSets} sets x ${widget.controller.exercise.targetReps} reps',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Builder(
              builder: (context) {
                final state = Provider.of<AppState>(context);
                String? prevSummary;
                double? lastWeight;
                for (final r in state.workoutRecords.reversed) {
                  try {
                    final ex = r.exercises.firstWhere(
                        (e) => e.exerciseName == widget.controller.exercise.name);
                    prevSummary = ex.sets
                        .map((s) =>
                            'Set ${s.setNumber}: ${s.repsCompleted}${s.weight != null ? ' @ ${s.weight} kg' : ''}')
                        .join(' • ');
                    if (ex.sets.isNotEmpty && ex.sets.last.weight != null) {
                      lastWeight = ex.sets.last.weight;
                    }
                    break;
                  } catch (_) {}
                }

                final widgets = <Widget>[];
                if (prevSummary != null) {
                  widgets.add(
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        'Last: $prevSummary',
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic),
                      ),
                    ),
                  );
                }

                if (_showWeightPrompt && lastWeight != null) {
                  final nextWeight = lastWeight + 2.5;
                  widgets.add(
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          border: Border.all(color: Colors.green),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Great work! Consider increasing weight to $nextWeight kg next time.',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widgets,
                );
              },
            ),
            Column(
              children: List.generate(
                widget.controller.targetSets,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: Text(
                          'Set ${index + 1}:',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: widget.controller.repsControllers[index],
                          decoration: const InputDecoration(
                            labelText: 'Reps',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller:
                              widget.controller.weightControllers[index],
                          decoration: const InputDecoration(
                            labelText: 'Weight (kg)',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  widget.controller.addSet();
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Set'),
            ),
          ],
        ),
      ),
    );
  }
}

class PastWorkoutsPage extends StatefulWidget {
  const PastWorkoutsPage({super.key});

  @override
  State<PastWorkoutsPage> createState() => _PastWorkoutsPageState();
}

class _PastWorkoutsPageState extends State<PastWorkoutsPage> {
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final records = state.workoutRecords;

    if (records.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No past workouts. Start recording to see them here.'),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return Card(
          child: ExpansionTile(
            title: Text(record.workoutTypeName),
            subtitle: Text(record.formattedDate),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Workout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirm == true && mounted) {
                  await state.deleteWorkoutRecord(index);
                }
              },
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: record.exercises
                      .map(
                        (ex) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ex.exerciseName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ...ex.sets.map(
                                (set) => Text(
                                  'Set ${set.setNumber}: ${set.repsCompleted} reps${set.weight != null ? ' @ ${set.weight} kg' : ''}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _strengthController;
  late TextEditingController _improvementController;

  @override
  void initState() {
    super.initState();
    final state = Provider.of<AppState>(context, listen: false);
    _nameController = TextEditingController(text: state.userProfile.name);
    _bioController = TextEditingController(text: state.userProfile.bio);
    _strengthController = TextEditingController();
    _improvementController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _strengthController.dispose();
    _improvementController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final state = Provider.of<AppState>(context, listen: false);
    final updatedProfile = UserProfile(
      name: _nameController.text,
      bio: _bioController.text,
      strengths: state.userProfile.strengths,
      areasForImprovement: state.userProfile.areasForImprovement,
    );
    await state.updateUserProfile(updatedProfile);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated')));
    }
  }

  Future<void> _addStrength() async {
    final state = Provider.of<AppState>(context, listen: false);
    final text = _strengthController.text.trim();
    if (text.isEmpty) return;

    final updated = UserProfile(
      name: state.userProfile.name,
      bio: state.userProfile.bio,
      strengths: [...state.userProfile.strengths, text],
      areasForImprovement: state.userProfile.areasForImprovement,
    );
    await state.updateUserProfile(updated);
    _strengthController.clear();
    setState(() {});
  }

  Future<void> _addImprovement() async {
    final state = Provider.of<AppState>(context, listen: false);
    final text = _improvementController.text.trim();
    if (text.isEmpty) return;

    final updated = UserProfile(
      name: state.userProfile.name,
      bio: state.userProfile.bio,
      strengths: state.userProfile.strengths,
      areasForImprovement: [...state.userProfile.areasForImprovement, text],
    );
    await state.updateUserProfile(updated);
    _improvementController.clear();
    setState(() {});
  }

  Future<void> _removeStrength(int index) async {
    final state = Provider.of<AppState>(context, listen: false);
    final updated = state.userProfile.strengths.toList();
    updated.removeAt(index);
    final profile = UserProfile(
      name: state.userProfile.name,
      bio: state.userProfile.bio,
      strengths: updated,
      areasForImprovement: state.userProfile.areasForImprovement,
    );
    await state.updateUserProfile(profile);
    setState(() {});
  }

  Future<void> _removeImprovement(int index) async {
    final state = Provider.of<AppState>(context, listen: false);
    final updated = state.userProfile.areasForImprovement.toList();
    updated.removeAt(index);
    final profile = UserProfile(
      name: state.userProfile.name,
      bio: state.userProfile.bio,
      strengths: state.userProfile.strengths,
      areasForImprovement: updated,
    );
    await state.updateUserProfile(profile);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Bio',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _saveProfile,
              child: const Text('Save Profile'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Strengths',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...List.generate(
              state.userProfile.strengths.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('• ${state.userProfile.strengths[index]}'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _removeStrength(index),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _strengthController,
                    decoration: const InputDecoration(
                      hintText: 'Add strength',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addStrength,
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Areas for Improvement',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...List.generate(
              state.userProfile.areasForImprovement.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '• ${state.userProfile.areasForImprovement[index]}',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _removeImprovement(index),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _improvementController,
                    decoration: const InputDecoration(
                      hintText: 'Add area for improvement',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addImprovement,
                  child: const Text('Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final templates = state.templates;

    if (templates.isEmpty) {
      return Scaffold(
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
                child: Text(
                  'No templates found. Add templates in Settings or during setup.',
                ),
          ),
        ),
      );
    }

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: templates.length,
        itemBuilder: (context, index) {
          final t = templates[index];
          return Card(
            child: ListTile(
              title: Text(t.name),
              subtitle: Text(t.exercises.join(', ')),
              onTap: () async {
                final saved = await Navigator.of(context).push<bool?>(
                  MaterialPageRoute(
                    builder: (_) => AddSessionPage(template: t),
                  ),
                );
                if (saved == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Session saved')),
                  );
                }
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final t = templates.first;
          final saved = await Navigator.of(context).push<bool?>(
            MaterialPageRoute(builder: (_) => AddSessionPage(template: t)),
          );
          if (saved == true && context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Session saved')));
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddSessionPage extends StatefulWidget {
  final WorkoutTemplate template;
  const AddSessionPage({required this.template, super.key});

  @override
  State<AddSessionPage> createState() => _AddSessionPageState();
}

class _AddSessionPageState extends State<AddSessionPage> {
  late final List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = widget.template.exercises
        .map((_) => TextEditingController())
        .toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _saveSession() async {
    final entries = <String, String>{};
    for (var i = 0; i < widget.template.exercises.length; i++) {
      final name = widget.template.exercises[i];
      final value = _controllers[i].text.trim();
      if (value.isNotEmpty) entries[name] = value;
    }

    final session = WorkoutSession(date: DateTime.now(), entries: entries);
    final state = Provider.of<AppState>(context, listen: false);
    await state.addSession(session);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Session - ${widget.template.name}')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: widget.template.exercises.length,
                itemBuilder: (context, index) {
                  final name = widget.template.exercises[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      controller: _controllers[index],
                      decoration: InputDecoration(
                        labelText: name,
                        hintText: 'e.g. 3x8 @ 80kg',
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _saveSession,
              child: const Text('Save Session'),
            ),
          ],
        ),
      ),
    );
  }
}

class WeeklyComparisonPage extends StatelessWidget {
  const WeeklyComparisonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const WeeklyComparisonBody();
  }
}

class WeeklyComparisonBody extends StatefulWidget {
  const WeeklyComparisonBody({super.key});

  @override
  State<WeeklyComparisonBody> createState() => _WeeklyComparisonBodyState();
}

class _WeeklyComparisonBodyState extends State<WeeklyComparisonBody> {
  // Sessions are read from AppState via Provider in build

  DateTime _weekStart(DateTime d) {
    final weekday = d.weekday; // 1 = Mon
    return DateTime(
      d.year,
      d.month,
      d.day,
    ).subtract(Duration(days: weekday - 1));
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final thisWeekStart = _weekStart(now);
    final prevWeekStart = thisWeekStart.subtract(const Duration(days: 7));
    final thisWeekEnd = thisWeekStart.add(const Duration(days: 7));

    final allSessions = Provider.of<AppState>(context).sessions;
    final sessions = List<WorkoutSession>.from(allSessions)
      ..sort((a, b) => b.date.compareTo(a.date));
    final thisWeek = sessions
        .where(
          (s) =>
              s.date.isAfter(
                thisWeekStart.subtract(const Duration(seconds: 1)),
              ) &&
              s.date.isBefore(thisWeekEnd),
        )
        .toList();
    final prevWeek = sessions
        .where(
          (s) =>
              s.date.isAfter(
                prevWeekStart.subtract(const Duration(seconds: 1)),
              ) &&
              s.date.isBefore(thisWeekStart),
        )
        .toList();

    // For each exercise, pick latest session entry in that week (if multiple sessions exist)
    final Map<String, String> thisWeekMap = {};
    for (final s in thisWeek) {
      for (final e in s.entries.entries) {
        if (!thisWeekMap.containsKey(e.key)) {
          thisWeekMap[e.key] =
              e.value; // keep most recent (sessions sorted newest->oldest)
        }
      }
    }

    final Map<String, String> prevWeekMap = {};
    for (final s in prevWeek) {
      for (final e in s.entries.entries) {
        if (!prevWeekMap.containsKey(e.key)) prevWeekMap[e.key] = e.value;
      }
    }

    final exercises = <String>{}
      ..addAll(prevWeekMap.keys)
      ..addAll(thisWeekMap.keys);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Weekly Comparison',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: const <Widget>[
                  Expanded(child: Text('Exercise')),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('Last Week', textAlign: TextAlign.center),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('This Week', textAlign: TextAlign.center),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: exercises.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final ex = exercises.elementAt(index);
                final last = prevWeekMap[ex] ?? '-';
                final current = thisWeekMap[ex] ?? '-';
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(child: Text(ex)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(last, textAlign: TextAlign.center),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(current, textAlign: TextAlign.center),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tip: Progressive overload is visible when the "This Week" column shows higher weights or volume.',
          ),
        ],
      ),
    );
  }
}

class OptionsPage extends StatelessWidget {
  const OptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Column(
        children: <Widget>[
          const Material(
            color: Colors.grey,
            child: TabBar(
              isScrollable: true,
              tabs: <Tab>[
                Tab(text: 'Templates'),
                Tab(text: 'Sessions'),
                Tab(text: 'Settings'),
                Tab(text: 'Export'),
                Tab(text: 'About'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: <Widget>[
                const TemplatesManager(),
                const SessionsManager(),
                const SettingsTab(),
                const Center(
                  child: Text('Export / Import will be added here.'),
                ),
                const Center(child: Text('Gym Workout Tracker\nVersion 0.1.0')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TemplatesManager extends StatefulWidget {
  const TemplatesManager({super.key});

  @override
  State<TemplatesManager> createState() => _TemplatesManagerState();
}

class _TemplatesManagerState extends State<TemplatesManager> {
  List<WorkoutTemplate> _templates = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final state = Provider.of<AppState>(context, listen: false);
    setState(() => _templates = List<WorkoutTemplate>.from(state.templates));
  }

  Future<void> _saveTemplates() async {
    final state = Provider.of<AppState>(context, listen: false);
    for (var i = 0; i < _templates.length; i++) {
      if (i < state.templates.length) {
        await state.updateTemplate(i, _templates[i]);
      } else {
        await state.addTemplate(_templates[i]);
      }
    }
  }

  Future<void> _addOrEdit({WorkoutTemplate? existing, int? index}) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final exercisesController = TextEditingController(
      text: existing?.exercises.join(', ') ?? '',
    );
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? 'Add Template' : 'Edit Template'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: exercisesController,
              decoration: const InputDecoration(
                labelText: 'Exercises (comma separated)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final exs = exercisesController.text
                  .split(',')
                  .map((s) => s.trim())
                  .where((s) => s.isNotEmpty)
                  .toList();
              if (name.isEmpty || exs.isEmpty) return;
              final t = WorkoutTemplate(name: name, exercises: exs);
              setState(() {
                if (existing != null && index != null) {
                  _templates[index] = t;
                  // ignore: curly_braces_in_flow_control_structures
                } else {
                  _templates.add(t);
                }
              });
              _saveTemplates();
              Navigator.of(context).pop(true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result == true) _load();
  }

  Future<void> _delete(int index) async {
    setState(() => _templates.removeAt(index));
    await _saveTemplates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _templates.isEmpty
          ? const Center(child: Text('No templates saved. Add one with +'))
          : ListView.builder(
              itemCount: _templates.length,
              itemBuilder: (context, index) {
                final t = _templates[index];
                return Card(
                  child: ListTile(
                    title: Text(t.name),
                    subtitle: Text(t.exercises.join(', ')),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () =>
                              _addOrEdit(existing: t, index: index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _delete(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEdit(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class SessionsManager extends StatefulWidget {
  const SessionsManager({super.key});

  @override
  State<SessionsManager> createState() => _SessionsManagerState();
}

class _SessionsManagerState extends State<SessionsManager> {
  List<WorkoutSession> _sessions = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final state = Provider.of<AppState>(context, listen: false);
    setState(() {
      _sessions = List<WorkoutSession>.from(state.sessions);
      _sessions.sort((a, b) => b.date.compareTo(a.date));
    });
  }

  Future<void> _delete(int index) async {
    final state = Provider.of<AppState>(context, listen: false);
    await state.deleteSession(index);
    _load();
  }

  void _viewSession(WorkoutSession s) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Session: ${s.date.toLocal().toString().split('.').first}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: s.entries.entries
              .map((e) => ListTile(title: Text(e.key), subtitle: Text(e.value)))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _sessions.isEmpty
          ? const Center(child: Text('No sessions recorded yet.'))
          : ListView.builder(
              itemCount: _sessions.length,
              itemBuilder: (context, index) {
                final s = _sessions[index];
                return Card(
                  child: ListTile(
                    title: Text(s.date.toLocal().toString().split('.').first),
                    subtitle: Text(s.entries.keys.join(', ')),
                    onTap: () => _viewSession(s),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _delete(index),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  String _name = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final state = Provider.of<AppState>(context, listen: false);
    setState(() => _name = state.userName);
  }

  Future<void> _setName() async {
    final controller = TextEditingController(text: _name);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set user name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final state = Provider.of<AppState>(context, listen: false);
              await state.setUserName(controller.text.trim());
              Navigator.of(context).pop(true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result == true) _load();
  }

  Future<void> _resetData() async {
    final state = Provider.of<AppState>(context, listen: false);
    await state.resetAll();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Data reset')));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('User: ${_name.isEmpty ? 'Not set' : _name}'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _setName,
            child: const Text('Set user name'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _resetData,
            child: const Text('Reset all data'),
          ),
        ],
      ),
    );
  }
}

class FirstRunPage extends StatefulWidget {
  final VoidCallback onComplete;
  const FirstRunPage({required this.onComplete, super.key});

  @override
  State<FirstRunPage> createState() => _FirstRunPageState();
}

class _FirstRunPageState extends State<FirstRunPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final List<WorkoutTemplate> _samples = WorkoutTemplate.sampleTemplates();
  final Map<int, bool> _selected = {};

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final state = Provider.of<AppState>(context, listen: false);
    final name = _nameController.text.trim();
    if (name.isNotEmpty) await state.setUserName(name);

    final chosen = <WorkoutTemplate>[];
    for (var i = 0; i < _samples.length; i++) {
      if (_selected[i] == true) chosen.add(_samples[i]);
    }
    if (chosen.isNotEmpty) await state.addTemplates(chosen);

    await state.completeSetup();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Initial Setup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Welcome — let\'s set up your app',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Your name (optional)',
                    ),
                    validator: (value) => null,
                  ),
                  const SizedBox(height: 12),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Choose initial workout templates:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...List<Widget>.generate(_samples.length, (i) {
                    final t = _samples[i];
                    return CheckboxListTile(
                      title: Text(t.name),
                      subtitle: Text(t.exercises.join(', ')),
                      value: _selected[i] ?? false,
                      onChanged: (v) =>
                          setState(() => _selected[i] = v ?? false),
                    );
                  }),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Complete setup'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
                'You can add or change workout templates later in Settings.',
            ),
          ],
        ),
      ),
    );
  }
}
