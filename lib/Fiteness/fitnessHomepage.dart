import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math';

import 'package:she_fit_app/Fiteness/fitnessAIAssistances.dart';
import 'package:she_fit_app/Fiteness/fitnessTask.dart';
import 'package:she_fit_app/Fiteness/fitnesssReward.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  // Activity tracking variables
  int steps = 0;
  double calories = 0;
  String currentActivity = 'run';
  double distance = 0;
  int timeInMinutes = 0;
  double avgPace = 0;
  int heartRate = 70; // Mock heart rate - would come from health device

  // Step detection variables
  List<double> _accelerometerValues = [];
  List<DateTime> _timestampedValues = [];
  static const int _windowSize = 15;
  DateTime? _lastStepTime;
  bool _isStepInProgress = false;
  Timer? _timer;

  // Firebase variables
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  // Activity thresholds
  final Map<String, double> _thresholds = {
    'run': 15.0,
    'cycle': 12.0,
    'yoga': 8.0,
  };

  // Daily goals tracking
  List<bool> weeklyProgress = List.generate(7, (index) => false);

  @override
  void initState() {
    super.initState();
    _initializeTracking();
    _loadTodayStats();
    _loadWeeklyProgress();
  }

  void _initializeTracking() {
    // Initialize accelerometer listening
    accelerometerEvents.listen((AccelerometerEvent event) {
      _processAccelerometerData(event);
    });

    // Start periodic updates
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateStats();
      _saveStatsToFirebase();
    });
  }

  void _processAccelerometerData(AccelerometerEvent event) {
    DateTime now = DateTime.now();

    // Calculate acceleration magnitude
    double magnitude =
        sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

    // Update rolling window
    _accelerometerValues.add(magnitude);
    _timestampedValues.add(now);

    // Maintain window size
    if (_accelerometerValues.length > _windowSize) {
      _accelerometerValues.removeAt(0);
      _timestampedValues.removeAt(0);
    }

    // Process step detection
    if (_accelerometerValues.length == _windowSize) {
      _detectStep();
    }
  }

  void _detectStep() {
    // Calculate average and variance
    double avg = _accelerometerValues.reduce((a, b) => a + b) / _windowSize;
    double variance = _accelerometerValues
            .map((v) => pow(v - avg, 2))
            .reduce((a, b) => a + b) /
        _windowSize;

    // Get current threshold based on activity
    double threshold = _thresholds[currentActivity] ?? _thresholds['run']!;

    // Step detection with timing checks
    if (variance > 1.2 &&
        !_isStepInProgress &&
        _accelerometerValues.last > threshold) {
      if (_lastStepTime != null) {
        Duration timeSinceLastStep = DateTime.now().difference(_lastStepTime!);
        if (timeSinceLastStep.inMilliseconds < 200) return;
      }

      _isStepInProgress = true;
      _lastStepTime = DateTime.now();

      setState(() {
        steps++;
        _updateStats();
      });
    } else if (_accelerometerValues.last < threshold - 2) {
      _isStepInProgress = false;
    }
  }

  void _updateStats() {
    // Update calories based on activity and steps
    double caloriesPerStep = currentActivity == 'run'
        ? 0.1
        : currentActivity == 'cycle'
            ? 0.08
            : 0.05;

    setState(() {
      calories = steps * caloriesPerStep;
      distance = steps * (currentActivity == 'run' ? 0.0008 : 0.0006);
      timeInMinutes = steps ~/ (currentActivity == 'run' ? 140 : 110);
      avgPace = timeInMinutes > 0 ? distance / timeInMinutes : 0;
    });
  }

  Future<void> _loadTodayStats() async {
    if (userId.isEmpty) return;

    final today = DateTime.now().toString().split(' ')[0];
    final docRef = FirebaseFirestore.instance
        .collection('fitness_stats')
        .doc(userId)
        .collection('daily')
        .doc(today);

    final doc = await docRef.get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      setState(() {
        steps = data['steps'] ?? 0;
        calories = data['calories']?.toDouble() ?? 0.0;
        distance = data['distance']?.toDouble() ?? 0.0;
        timeInMinutes = data['timeInMinutes'] ?? 0;
        currentActivity = data['currentActivity'] ?? 'run';
      });
    }
  }

  Future<void> _saveStatsToFirebase() async {
    if (userId.isEmpty) return;

    final today = DateTime.now().toString().split(' ')[0];
    final statsRef = FirebaseFirestore.instance
        .collection('fitness_stats')
        .doc(userId)
        .collection('daily')
        .doc(today);

    await statsRef.set({
      'steps': steps,
      'calories': calories,
      'distance': distance,
      'timeInMinutes': timeInMinutes,
      'currentActivity': currentActivity,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _loadWeeklyProgress() async {
    if (userId.isEmpty) return;

    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final dateStr = date.toString().split(' ')[0];

      final doc = await FirebaseFirestore.instance
          .collection('fitness_stats')
          .doc(userId)
          .collection('daily')
          .doc(dateStr)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          weeklyProgress[i] = (data['steps'] ?? 0) >= 10000;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildMainStats(),
                const SizedBox(height: 20),
                _buildWeeklyProgress(),
                const SizedBox(height: 20),
                _buildActivitySelector(),
                const SizedBox(height: 20),
                _buildDetailedMetrics(),
                const SizedBox(height: 20),
                _buildNavigationCards(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Activities',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Connected: Samsung Health 4',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildMainStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            label: 'Steps',
            value: steps.toString(),
            color: Colors.blue[100]!,
            icon: Icons.directions_walk,
          ),
          _buildStatItem(
            label: 'Calories',
            value: '${calories.toStringAsFixed(0)} kcal',
            color: Colors.green[100]!,
            icon: Icons.local_fire_department,
          ),
          _buildStatItem(
            label: 'Distance',
            value: '${distance.toStringAsFixed(2)} mi',
            color: Colors.amber[100]!,
            icon: Icons.place,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(icon, size: 30),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgress() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your daily goal',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
              return Column(
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundColor:
                        weeklyProgress[index] ? Colors.green : Colors.grey[300],
                    child: Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    days[index],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySelector() {
    final activities = [
      {'icon': Icons.directions_run, 'label': 'Run', 'value': 'run'},
      {'icon': Icons.directions_bike, 'label': 'Cycle', 'value': 'cycle'},
      {'icon': Icons.self_improvement, 'label': 'Yoga', 'value': 'yoga'},
    ];

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Start new activity',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: activities
                .map((activity) => GestureDetector(
                      onTap: () => setState(
                          () => currentActivity = activity['value'] as String),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: currentActivity == activity['value']
                                  ? Colors.blue
                                  : Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              activity['icon'] as IconData,
                              color: currentActivity == activity['value']
                                  ? Colors.white
                                  : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            activity['label'] as String,
                            style: TextStyle(
                              color: currentActivity == activity['value']
                                  ? Colors.blue
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedMetrics() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Metrics',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricItem(
                label: 'Avg. Pace',
                value: '${avgPace.toStringAsFixed(2)}"',
                icon: Icons.speed,
              ),
              _buildMetricItem(
                label: 'Time',
                value: '${timeInMinutes}m',
                icon: Icons.timer,
              ),
              _buildMetricItem(
                label: 'Heart Rate',
                value: '$heartRate',
                icon: Icons.favorite,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[600]),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildNavCard(
                'Tasks',
                Icons.task_alt,
                'Track your fitness goals',
                Colors.blue[100]!,
                () => _navigateToTasks(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildNavCard(
                'Rewards',
                Icons.star,
                'View your achievements',
                Colors.amber[100]!,
                () => _navigateToRewards(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildNavCard(
          'AI Assistant',
          Icons.sports_gymnastics,
          'Get personalized workout advice',
          Colors.green[100]!,
          () => _navigateToAIAssistant(),
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildNavCard(
    String title,
    IconData icon,
    String description,
    Color color,
    VoidCallback onTap, {
    bool fullWidth = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToTasks() {
    // Navigation logic for Tasks page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Fitnesstask()),
    );
  }

  void _navigateToRewards() {
    // Navigation logic for Rewards page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RewardsPage()),
    );
  }

  void _navigateToAIAssistant() {
    // Navigation logic for AI Assistant page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Fitnessaiassistances()),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
