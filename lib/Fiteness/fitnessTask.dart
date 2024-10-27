import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';

class Fitnesstask extends StatefulWidget {
  const Fitnesstask({Key? key}) : super(key: key);

  @override
  State<Fitnesstask> createState() => _FitnesstaskState();
}

class _FitnesstaskState extends State<Fitnesstask> {
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  List<FitnessTask> tasks = [];
  int totalFitPoints = 0;
  Map<String, int> streaks = {};

  @override
  void initState() {
    super.initState();
    _initializeTasks();
    _loadUserFitPoints();
    _loadStreaks();
  }

  Future<void> _initializeTasks() async {
    tasks = [
      FitnessTask(
        id: 'run_2k',
        title: '2KM Run',
        description: 'Complete a 2KM run',
        fitPoints: 100,
        targetValue: 2.0,
        type: 'distance',
        icon: Icons.directions_run,
        streakBonus: 50,
        requiredStreakDays: 10,
      ),
      FitnessTask(
        id: 'run_5k',
        title: '5KM Run',
        description: 'Complete a 5KM run',
        fitPoints: 250,
        targetValue: 5.0,
        type: 'distance',
        icon: Icons.directions_run,
        streakBonus: 100,
        requiredStreakDays: 7,
      ),
      FitnessTask(
        id: 'cycling_10k',
        title: '10KM Cycling',
        description: 'Complete a 10KM cycling session',
        fitPoints: 200,
        targetValue: 10.0,
        type: 'distance',
        icon: Icons.directions_bike,
        streakBonus: 75,
        requiredStreakDays: 5,
      ),
      FitnessTask(
        id: 'steps_10k',
        title: '10,000 Steps',
        description: 'Complete 10,000 steps in a day',
        fitPoints: 150,
        targetValue: 10000,
        type: 'steps',
        icon: Icons.directions_walk,
        streakBonus: 60,
        requiredStreakDays: 7,
      ),
      // Static exercise tasks
      FitnessTask(
        id: 'yoga_30min',
        title: 'Yoga Session',
        description: 'Complete a 30-minute yoga session',
        fitPoints: 120,
        targetValue: 30,
        type: 'duration',
        icon: Icons.self_improvement,
        streakBonus: 40,
        requiredStreakDays: 5,
        isStatic: true,
      ),
      FitnessTask(
        id: 'hiit_20min',
        title: 'HIIT Workout',
        description: 'Complete a 20-minute HIIT session',
        fitPoints: 180,
        targetValue: 20,
        type: 'duration',
        icon: Icons.fitness_center,
        streakBonus: 70,
        requiredStreakDays: 3,
        isStatic: true,
      ),
      
    ];
    await _loadTaskProgress();
  }

  Future<void> _loadUserFitPoints() async {
    if (userId.isEmpty) return;
    
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
    
    if (userDoc.exists) {
      setState(() {
        totalFitPoints = userDoc.data()?['fitPoints'] ?? 0;
      });
    }
  }

  Future<void> _loadStreaks() async {
    if (userId.isEmpty) return;
    
    final streaksDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('streaks')
        .doc('current')
        .get();
    
    if (streaksDoc.exists) {
      setState(() {
        streaks = Map<String, int>.from(streaksDoc.data() ?? {});
      });
    }
  }

  Future<void> _loadTaskProgress() async {
    if (userId.isEmpty) return;
    
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final progressDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('taskProgress')
        .doc(today)
        .get();
    
    if (progressDoc.exists) {
      Map<String, dynamic> progress = progressDoc.data() ?? {};
      
      setState(() {
        for (var task in tasks) {
          if (progress.containsKey(task.id)) {
            task.currentProgress = progress[task.id]['progress'].toDouble();
            task.isCompleted = progress[task.id]['completed'] ?? false;
          }
        }
      });
    }
  }

  Future<void> _updateTaskProgress(FitnessTask task, double progress) async {
    if (userId.isEmpty) return;
    
    setState(() {
      task.currentProgress = progress;
      if (progress >= task.targetValue && !task.isCompleted) {
        task.isCompleted = true;
        _awardFitPoints(task);
        _updateStreak(task);
      }
    });
    
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('taskProgress')
        .doc(today)
        .set({
          task.id: {
            'progress': progress,
            'completed': task.isCompleted,
            'timestamp': FieldValue.serverTimestamp(),
          }
        }, SetOptions(merge: true));
  }

  Future<void> _awardFitPoints(FitnessTask task) async {
    if (userId.isEmpty) return;
    
    int pointsToAward = task.fitPoints;
    
    // Add streak bonus if applicable
    if (streaks[task.id] != null && 
        streaks[task.id]! >= task.requiredStreakDays) {
      pointsToAward += task.streakBonus;
    }
    
    setState(() {
      totalFitPoints += pointsToAward;
    });
    
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .set({
          'fitPoints': FieldValue.increment(pointsToAward),
        }, SetOptions(merge: true));
    
    // Record points history
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('pointsHistory')
        .add({
          'taskId': task.id,
          'points': pointsToAward,
          'timestamp': FieldValue.serverTimestamp(),
          'type': 'task_completion',
          'includesStreakBonus': streaks[task.id] != null && 
              streaks[task.id]! >= task.requiredStreakDays,
        });
  }

  Future<void> _updateStreak(FitnessTask task) async {
    if (userId.isEmpty) return;
    
    // Check if task was completed yesterday
    final yesterday = DateFormat('yyyy-MM-dd')
        .format(DateTime.now().subtract(const Duration(days: 1)));
    
    final yesterdayDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('taskProgress')
        .doc(yesterday)
        .get();
    
    bool completedYesterday = false;
    if (yesterdayDoc.exists) {
      final yesterdayProgress = yesterdayDoc.data()?[task.id];
      completedYesterday = yesterdayProgress?['completed'] ?? false;
    }
    
    int currentStreak = streaks[task.id] ?? 0;
    if (completedYesterday) {
      currentStreak++;
    } else {
      currentStreak = 1;
    }
    
    setState(() {
      streaks[task.id] = currentStreak;
    });
    
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('streaks')
        .doc('current')
        .set({task.id: currentStreak}, SetOptions(merge: true));
  }

  void _completeStaticTask(FitnessTask task) async {
    if (!task.isStatic || task.isCompleted) return;
    
    await _updateTaskProgress(task, task.targetValue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness Tasks'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Icon(Icons.stars, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  '$totalFitPoints FP',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTaskCategories(),
          const SizedBox(height: 20),
          ...tasks.map((task) => _buildTaskCard(task)).toList(),
        ],
      ),
    );
  }

  Widget _buildTaskCategories() {
    return Container(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildCategoryCard('Cardio', Icons.directions_run),
          _buildCategoryCard('Strength', Icons.fitness_center),
          _buildCategoryCard('Flexibility', Icons.self_improvement),
          _buildCategoryCard('Steps', Icons.directions_walk),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String title, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(right: 16),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(FitnessTask task) {
    final progress = task.currentProgress / task.targetValue;
    final streakDays = streaks[task.id] ?? 0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(task.icon),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        task.description,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.stars, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${task.fitPoints} FP',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    if (streakDays > 0)
                      Text(
                        '$streakDays day streak',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearPercentIndicator(
              percent: progress.clamp(0.0, 1.0),
              lineHeight: 8,
              backgroundColor: Colors.grey[200],
              progressColor: task.isCompleted ? Colors.green : Colors.blue,
              barRadius: const Radius.circular(4),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${task.currentProgress.toStringAsFixed(1)}/${task.targetValue} ${_getUnitLabel(task.type)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                if (task.isStatic && !task.isCompleted)
                  ElevatedButton(
                    onPressed: () => _completeStaticTask(task),
                    child: const Text('Complete'),
                  ),
              ],
            ),
            if (streakDays > 0 && streakDays < task.requiredStreakDays)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '${task.requiredStreakDays - streakDays} more days for +${task.streakBonus} FP bonus!',
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getUnitLabel(String type) {
    switch (type) {
      case 'distance':
        return 'km';
      case 'duration':
        return 'min';
      case 'steps':
        return 'steps';
      default:
        return '';
    }
  }
}

class FitnessTask {
  final String id;
  final String title;
  final String description;
  final int fitPoints;
  final double targetValue;
  final String type;
  final IconData icon;
  final int streakBonus;
  final int requiredStreakDays;
  final bool isStatic;
  final int? caloriesPerUnit; // New field for calories
  final String? targetMuscleGroup;
  
  
   double currentProgress;
  bool isCompleted;
  int? caloriesBurned;

 FitnessTask({
    required this.id,
    required this.title,
    required this.description,
    required this.fitPoints,
    required this.targetValue,
    required this.type,
    required this.icon,
    required this.streakBonus,
    required this.requiredStreakDays,
    this.isStatic = false,
    this.currentProgress = 0.0,
    this.isCompleted = false,
    this.caloriesPerUnit,
    this.targetMuscleGroup,
    this.caloriesBurned,
  });
}
// Add these utility functions outside the main class

Future<void> syncFitnessDataWithTasks(String userId) async {
  if (userId.isEmpty) return;
  
  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  
  // Get today's fitness stats
  final fitnessStatsDoc = await FirebaseFirestore.instance
      .collection('fitness_stats')
      .doc(userId)
      .collection('daily')
      .doc(today)
      .get();

  if (!fitnessStatsDoc.exists) return;

  final stats = fitnessStatsDoc.data() as Map<String, dynamic>;
  
  // Update task progress based on fitness stats
  final taskProgress = <String, dynamic>{};
  
  // Running distance
  if (stats['currentActivity'] == 'run') {
    final distance = stats['distance'] ?? 0.0;
    taskProgress['run_2k'] = {
      'progress': distance,
      'completed': distance >= 2.0,
      'timestamp': FieldValue.serverTimestamp(),
    };
    taskProgress['run_5k'] = {
      'progress': distance,
      'completed': distance >= 5.0,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
  
  // Cycling distance
  if (stats['currentActivity'] == 'cycle') {
    final distance = stats['distance'] ?? 0.0;
    taskProgress['cycling_10k'] = {
      'progress': distance,
      'completed': distance >= 10.0,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
  
  // Steps
  final steps = stats['steps'] ?? 0;
  taskProgress['steps_10k'] = {
    'progress': steps.toDouble(),
    'completed': steps >= 10000,
    'timestamp': FieldValue.serverTimestamp(),
  };
  
  // Update Firebase
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('taskProgress')
      .doc(today)
      .set(taskProgress, SetOptions(merge: true));
}

Future<void> resetDailyTasks() async {
  final now = DateTime.now();
  final today = DateFormat('yyyy-MM-dd').format(now);
  
  // Get all users
  final usersSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .get();
  
  for (var userDoc in usersSnapshot.docs) {
    final userId = userDoc.id;
    
    // Reset task progress for the new day
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('taskProgress')
        .doc(today)
        .set({
          'lastReset': FieldValue.serverTimestamp(),
        });
    
    // Update streaks
    final yesterdayStr = DateFormat('yyyy-MM-dd')
        .format(now.subtract(const Duration(days: 1)));
    
    final yesterdayDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('taskProgress')
        .doc(yesterdayStr)
        .get();
    
    if (yesterdayDoc.exists) {
      final streaksDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('streaks')
          .doc('current')
          .get();
      
      final currentStreaks = Map<String, int>.from(streaksDoc.data() ?? {});
      final yesterdayProgress = yesterdayDoc.data() ?? {};
      
      // Update each task streak
      yesterdayProgress.forEach((taskId, progress) {
        if (progress['completed'] == true) {
          currentStreaks[taskId] = (currentStreaks[taskId] ?? 0) + 1;
        } else {
          currentStreaks[taskId] = 0;
        }
      });
      
      // Save updated streaks
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('streaks')
          .doc('current')
          .set(currentStreaks);
    }
  }
}


// Add these Firebase Security Rules to secure the data:
/*
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      match /taskProgress/{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      match /streaks/{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      match /pointsHistory/{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    match /fitness_stats/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
*/