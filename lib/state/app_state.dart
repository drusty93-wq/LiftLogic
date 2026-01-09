import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout_session.dart';
import '../models/workout_template.dart';
import '../models/workout_data.dart';

class AppState extends ChangeNotifier {
  List<WorkoutTemplate> templates = [];
  List<WorkoutSession> sessions = [];
  List<WorkoutRecord> workoutRecords = [];
  UserProfile userProfile = const UserProfile();
  String userName = '';
  bool isSetupComplete = false;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final rawTemplates = prefs.getStringList('templates') ?? [];
    templates = rawTemplates.map((e) => WorkoutTemplate.fromJson(jsonDecode(e) as Map<String, dynamic>)).toList();

    final rawSessions = prefs.getStringList('sessions') ?? [];
    sessions = rawSessions.map((e) => WorkoutSession.fromJson(jsonDecode(e) as Map<String, dynamic>)).toList();
    sessions.sort((a, b) => b.date.compareTo(a.date));

    // Load workout records
    final rawRecords = prefs.getStringList('workoutRecords') ?? [];
    workoutRecords = rawRecords.map((e) => WorkoutRecord.fromJson(jsonDecode(e) as Map<String, dynamic>)).toList();
    workoutRecords.sort((a, b) => b.date.compareTo(a.date));

    // Load user profile
    final rawProfile = prefs.getString('userProfile');
    if (rawProfile != null) {
      userProfile = UserProfile.fromJson(jsonDecode(rawProfile) as Map<String, dynamic>);
    }

    userName = prefs.getString('userName') ?? '';
    isSetupComplete = prefs.getBool('isSetupComplete') ?? false;

    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    userName = name;
    await prefs.setString('userName', name);
    notifyListeners();
  }

  Future<void> completeSetup() async {
    final prefs = await SharedPreferences.getInstance();
    isSetupComplete = true;
    await prefs.setBool('isSetupComplete', true);
    notifyListeners();
  }

  Future<void> addTemplates(List<WorkoutTemplate> list) async {
    templates.addAll(list);
    await _saveTemplates();
    notifyListeners();
  }

  Future<void> addTemplate(WorkoutTemplate t) async {
    templates.add(t);
    await _saveTemplates();
    notifyListeners();
  }

  Future<void> updateTemplate(int index, WorkoutTemplate t) async {
    templates[index] = t;
    await _saveTemplates();
    notifyListeners();
  }

  Future<void> deleteTemplate(int index) async {
    templates.removeAt(index);
    await _saveTemplates();
    notifyListeners();
  }

  Future<void> _saveTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('templates', templates.map((t) => jsonEncode(t.toJson())).toList());
  }

  Future<void> addSession(WorkoutSession s) async {
    sessions.insert(0, s);
    await _saveSessions();
    notifyListeners();
  }

  Future<void> deleteSession(int index) async {
    sessions.removeAt(index);
    await _saveSessions();
    notifyListeners();
  }

  Future<void> _saveSessions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('sessions', sessions.map((s) => jsonEncode(s.toJson())).toList());
  }

  Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('templates');
    await prefs.remove('sessions');
    await prefs.remove('workoutRecords');
    await prefs.remove('userProfile');
    await prefs.remove('userName');
    await prefs.remove('isSetupComplete');
    templates = [];
    sessions = [];
    workoutRecords = [];
    userProfile = const UserProfile();
    userName = '';
    isSetupComplete = false;
    notifyListeners();
  }

  // Workout Records Management
  Future<void> addWorkoutRecord(WorkoutRecord record) async {
    workoutRecords.insert(0, record);
    await _saveWorkoutRecords();
    notifyListeners();
  }

  Future<void> deleteWorkoutRecord(int index) async {
    workoutRecords.removeAt(index);
    await _saveWorkoutRecords();
    notifyListeners();
  }

  Future<void> _saveWorkoutRecords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('workoutRecords', workoutRecords.map((r) => jsonEncode(r.toJson())).toList());
  }

  WorkoutRecord? getLastWorkoutOfType(String workoutTypeId) {
    try {
      return workoutRecords.firstWhere((r) => r.workoutTypeId == workoutTypeId);
    } catch (e) {
      return null;
    }
  }

  // User Profile Management
  Future<void> updateUserProfile(UserProfile profile) async {
    userProfile = profile;
    await _saveUserProfile();
    notifyListeners();
  }

  Future<void> _saveUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userProfile', jsonEncode(userProfile.toJson()));
  }
}
