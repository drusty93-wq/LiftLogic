import 'dart:convert';

class WorkoutSession {
  final DateTime date;
  final Map<String, String> entries; // exercise -> result like "3x8 @ 80kg"

  WorkoutSession({required this.date, required this.entries});

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'entries': entries,
      };

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    final map = <String, String>{};
    if (json['entries'] is Map) {
      (json['entries'] as Map).forEach((k, v) => map[k.toString()] = v.toString());
    }
    return WorkoutSession(
      date: DateTime.parse(json['date'] as String),
      entries: map,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}
