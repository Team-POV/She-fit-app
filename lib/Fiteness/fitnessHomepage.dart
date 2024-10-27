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

class _DashboardPageState extends State<DashboardPage> {
  // Activity tracking variables
  int steps = 0;
  double calories = 0;
  String currentActivity = 'run';
  double distance = 0;
  int timeInMinutes = 0;
  double avgPace = 0;
  int heartRate = 70;
  
  // Enhanced activity metrics
  double currentSpeed = 0;
  double maxSpeed = 0;
  double averageSpeed = 0;
  int cadence = 0;
  List<double> speedHistory = [];
  double elevationGain = 0;
  
  // Activity-specific constants
  final Map<String, ActivityMetrics> _activityMetrics = {
    'run': ActivityMetrics(
      caloriesPerStep: 0.063,
      strideLength: 0.75,
      minStepInterval: 150,
      maxStepInterval: 400,
      targetCadence: 180,
    ),
    'cycle': ActivityMetrics(
      caloriesPerStep: 0.1,
      strideLength: 2.5,
      minStepInterval: 500,
      maxStepInterval: 1200,
      targetCadence: 80,
    ),
  };

  // Step detection variables
  List<double> _accelerometerValues = [];
  List<DateTime> _timestampedValues = [];
  static const int _windowSize = 20;
  DateTime? _lastStepTime;
  bool _isStepInProgress = false;
  Timer? _timer;
  DateTime _activityStartTime = DateTime.now();
  
  // Firebase variables
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  
  // Activity thresholds
  final Map<String, double> _thresholds = {
    'run': 12.5,
    'cycle': 8.0,
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
    _activityStartTime = DateTime.now();
    
    accelerometerEvents.listen((AccelerometerEvent event) {
      _processAccelerometerData(event);
    });
    
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _updateStats();
      _saveStatsToFirebase();
    });
  }

  void _processAccelerometerData(AccelerometerEvent event) {
    DateTime now = DateTime.now();
    
    double magnitude = sqrt(pow(event.x, 2) + pow(event.y, 2) + pow(event.z, 2));
    
    if (_accelerometerValues.isNotEmpty) {
      magnitude = 0.8 * _accelerometerValues.last + 0.2 * magnitude;
    }
    
    _accelerometerValues.add(magnitude);
    _timestampedValues.add(now);
    
    if (_accelerometerValues.length > _windowSize) {
      _accelerometerValues.removeAt(0);
      _timestampedValues.removeAt(0);
    }
    
    if (_accelerometerValues.length == _windowSize) {
      _detectStep();
      _updateRealTimeMetrics();
    }
  }

  void _detectStep() {
    ActivityMetrics metrics = _activityMetrics[currentActivity]!;
    double threshold = _thresholds[currentActivity]!;
    
    double dynamicThreshold = _calculateDynamicThreshold();
    
    if (_accelerometerValues.length >= 3) {
      double prev = _accelerometerValues[_accelerometerValues.length - 2];
      double current = _accelerometerValues.last;
      
      if (!_isStepInProgress && 
          current > dynamicThreshold && 
          prev <= dynamicThreshold) {
        
        if (_lastStepTime != null) {
          Duration timeSinceLastStep = DateTime.now().difference(_lastStepTime!);
          
          if (timeSinceLastStep.inMilliseconds >= metrics.minStepInterval &&
              timeSinceLastStep.inMilliseconds <= metrics.maxStepInterval) {
            _recordStep();
          }
        } else {
          _recordStep();
        }
      }
      
      _isStepInProgress = current > threshold;
    }
  }

  void _recordStep() {
    _lastStepTime = DateTime.now();
    setState(() {
      steps++;
      _updateCadence();
    });
  }

  double _calculateDynamicThreshold() {
    if (_accelerometerValues.length < _windowSize) return _thresholds[currentActivity]!;
    
    double mean = _accelerometerValues.reduce((a, b) => a + b) / _windowSize;
    double variance = _accelerometerValues
        .map((v) => pow(v - mean, 2))
        .reduce((a, b) => a + b) / _windowSize;
    
    return mean + sqrt(variance) * 1.5;
  }

  void _updateRealTimeMetrics() {
    ActivityMetrics metrics = _activityMetrics[currentActivity]!;
    
    if (_lastStepTime != null) {
      Duration activityDuration = DateTime.now().difference(_activityStartTime);
      timeInMinutes = activityDuration.inMinutes;
      
      if (steps > 0) {
        distance = steps * metrics.strideLength / 1000;
        currentSpeed = distance / (activityDuration.inSeconds / 3600);
        
        speedHistory.add(currentSpeed);
        if (speedHistory.length > 10) speedHistory.removeAt(0);
        
        maxSpeed = max(maxSpeed, currentSpeed);
        averageSpeed = speedHistory.reduce((a, b) => a + b) / speedHistory.length;
      }
    }
  }

  void _updateCadence() {
    if (_lastStepTime != null) {
      Duration window = const Duration(seconds: 60);
      DateTime windowStart = DateTime.now().subtract(window);
      
      int recentSteps = _timestampedValues
          .where((timestamp) => timestamp.isAfter(windowStart))
          .length;
      
      cadence = recentSteps;
    }
  }

  void _updateStats() {
    ActivityMetrics metrics = _activityMetrics[currentActivity]!;
    
    setState(() {
      double intensityFactor = currentSpeed / (currentActivity == 'run' ? 10 : 20);
      double weightFactor = 70;
      
      calories = steps * metrics.caloriesPerStep * intensityFactor * (weightFactor / 70);
      
      if (distance > 0 && timeInMinutes > 0) {
        avgPace = timeInMinutes / distance;
      }
      
      heartRate = 70 + (currentActivity == 'run' ? 
          (steps ~/ 100 * 5).clamp(0, 100) :
          (steps ~/ 150 * 3).clamp(0, 80));
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
      'currentSpeed': currentSpeed,
      'maxSpeed': maxSpeed,
      'averageSpeed': averageSpeed,
      'cadence': cadence,
      'heartRate': heartRate,
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
                const SizedBox(height: 15),
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
          'She-FIT Fitness Activities',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '',
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
            value: '${distance.toStringAsFixed(2)} km',
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
          'Weekly Progress',
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
                  backgroundColor: weeklyProgress[index]
                      ? Colors.green
                      : Colors.grey[300],
                  child: const Icon(
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
            'Select Activity',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActivityButton('run', 'Running', Icons.directions_run),
              _buildActivityButton('cycle', 'Cycling', Icons.directions_bike),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityButton(String activity, String label, IconData icon) {
    bool isSelected = currentActivity == activity;
    return GestureDetector(
      onTap: () {
        setState(() {
          currentActivity = activity;
          _activityStartTime = DateTime.now();
          steps = 0;
          distance = 0;
          calories = 0;
          speedHistory.clear();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.black54,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
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
            'Detailed Metrics',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          _buildMetricRow('Current Speed', '${currentSpeed.toStringAsFixed(1)} km/h'),
          _buildMetricRow('Average Speed', '${averageSpeed.toStringAsFixed(1)} km/h'),
          _buildMetricRow('Max Speed', '${maxSpeed.toStringAsFixed(1)} km/h'),
          _buildMetricRow('Cadence', '$cadence spm'),
          _buildMetricRow('Heart Rate', '$heartRate bpm'),
          _buildMetricRow('Time', '$timeInMinutes min'),
          _buildMetricRow('Avg Pace', '${avgPace.toStringAsFixed(2)} min/km'),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildNavigationCards() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSmallCard(
                'Tasks',
                Icons.check_circle_outline,
                'Track your fitness goals',
                const Color.fromARGB(255, 128, 193, 240),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Fitnesstask()),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSmallCard(
                'Rewards',
                Icons.star_outline,
                'View your achievements',
                const Color.fromARGB(255, 242, 231, 81),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Fitnesssreward()),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildLargeCard(
          'AI Assistant',
          Icons.sports_gymnastics,
          'Get personalized workout advice',
          const Color.fromARGB(255, 89, 236, 101),
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Fitnessaiassistances()),
          ),
        ),
      ],
    ),
  );
}

Widget _buildSmallCard(
  String title,
  IconData icon,
  String subtitle,
  Color backgroundColor,
  VoidCallback onTap,
) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
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

Widget _buildLargeCard(
  String title,
  IconData icon,
  String subtitle,
  Color backgroundColor,
  VoidCallback onTap,
) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: const Color.fromARGB(255, 90, 89, 88),
            ),
          ),
        ],
        
      ),
    ),
  );
}

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class ActivityMetrics {
  final double caloriesPerStep;
  final double strideLength;
  final int minStepInterval;
  final int maxStepInterval;
  final int targetCadence;

  ActivityMetrics({
    required this.caloriesPerStep,
    required this.strideLength,
    required this.minStepInterval,
    required this.maxStepInterval,
    required this.targetCadence,
  });
}