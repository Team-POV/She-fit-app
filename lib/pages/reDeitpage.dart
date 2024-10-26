import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class NutrientIntake {
  double protein;
  double iron;
  double calcium;
  double vitaminD;
  
  NutrientIntake({
    this.protein = 0,
    this.iron = 0,
    this.calcium = 0,
    this.vitaminD = 0,
  });
  
  Map<String, double> toMap() {
    return {
      'protein': protein,
      'iron': iron,
      'calcium': calcium,
      'vitaminD': vitaminD,
    };
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Period Tracker & Nutrition',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const UserInfoForm(),
    );
  }
}

class UserInfoForm extends StatefulWidget {
  const UserInfoForm({Key? key}) : super(key: key);

  @override
  _UserInfoFormState createState() => _UserInfoFormState();
}

class _UserInfoFormState extends State<UserInfoForm> {
  final _formKey = GlobalKey<FormState>();
  
  // Form fields
  String? name;
  int? age;
  double? weight;
  double? height;
  DateTime? lastPeriodDate;
  int? cycleDuration;
  String? activityLevel;
  
  // Cycle phases colors
  final Map<String, Color> phaseColors = {
    'Menstrual': Colors.pink.shade100,
    'Follicular': Colors.orange.shade100,
    'Ovulatory': Colors.green.shade100,
    'Luteal': Colors.purple.shade100,
  };

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      // Calculate BMR and protein requirements
      double bmr = calculateBMR();
      double proteinRequirement = calculateProteinRequirement();
      
      // Save to Firebase
      try {
        await FirebaseFirestore.instance.collection('users').add({
          'name': name,
          'age': age,
          'weight': weight,
          'height': height,
          'lastPeriodDate': lastPeriodDate,
          'cycleDuration': cycleDuration,
          'activityLevel': activityLevel,
          'bmr': bmr,
          'proteinRequirement': proteinRequirement,
          'timestamp': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardScreen(
              lastPeriodDate: lastPeriodDate!,
              cycleDuration: cycleDuration!,
              proteinRequirement: proteinRequirement,
            ),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving data: $e')),
        );
      }
    }
  }

  double calculateBMR() {
    // Harris-Benedict Formula for women
    return 655.1 + (9.563 * weight!) + (1.850 * height!) - (4.676 * age!);
  }

  double calculateProteinRequirement() {
    double multiplier = 0.8; // Base requirement
    
    switch (activityLevel) {
      case 'Sedentary':
        multiplier = 0.8;
        break;
      case 'Moderately Active':
        multiplier = 1.2;
        break;
      case 'Very Active':
        multiplier = 1.6;
        break;
    }
    
    return weight! * multiplier;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Information'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                onSaved: (value) => name = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                onSaved: (value) => age = int.tryParse(value ?? ''),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                onSaved: (value) => weight = double.tryParse(value ?? ''),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Height (cm)'),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                onSaved: (value) => height = double.tryParse(value ?? ''),
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Activity Level'),
                items: ['Sedentary', 'Moderately Active', 'Very Active']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) => value == null ? 'Required' : null,
                onChanged: (value) => setState(() => activityLevel = value),
              ),
              ListTile(
                title: const Text('Last Period Date'),
                subtitle: Text(lastPeriodDate == null
                    ? 'Not selected'
                    : DateFormat.yMMMd().format(lastPeriodDate!)),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2023),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => lastPeriodDate = date);
                  }
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Cycle Duration (days)'),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                onSaved: (value) => cycleDuration = int.tryParse(value ?? ''),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Continue to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  final DateTime lastPeriodDate;
  final int cycleDuration;
  final double proteinRequirement;

  const DashboardScreen({
    Key? key,
    required this.lastPeriodDate,
    required this.cycleDuration,
    required this.proteinRequirement,
  }) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  NutrientIntake dailyIntake = NutrientIntake();
  DateTime selectedDay = DateTime.now();
  
  Map<String, Map<String, double>> phaseNutrientGoals = {
    'Menstrual': {
      'protein': 0.0, // Will be set based on proteinRequirement
      'iron': 18.0,
      'calcium': 1000.0,
      'vitaminD': 600.0,
    },
    'Follicular': {
      'protein': 0.0,
      'iron': 18.0,
      'calcium': 1000.0,
      'vitaminD': 600.0,
    },
    'Ovulatory': {
      'protein': 0.0,
      'iron': 18.0,
      'calcium': 1000.0,
      'vitaminD': 600.0,
    },
    'Luteal': {
      'protein': 0.0,
      'iron': 18.0,
      'calcium': 1200.0,
      'vitaminD': 800.0,
    },
  };

  Map<String, List<String>> phaseAvoidFoods = {
    'Menstrual': [
      'Caffeine',
      'Alcohol',
      'Salty foods',
      'Processed sugar',
      'Red meat'
    ],
    'Follicular': [
      'Heavy dairy',
      'Processed foods',
      'Excessive sugar'
    ],
    'Ovulatory': [
      'Inflammatory foods',
      'Excessive caffeine',
      'Spicy foods'
    ],
    'Luteal': [
      'High-sodium foods',
      'Caffeine',
      'Alcohol',
      'Refined carbs'
    ],
  };

  Map<String, List<String>> phaseRecommendedFoods = {
    'Menstrual': [
      'Lean meat',
      'Fish',
      'Lentils',
      'Eggs',
      'Dark leafy greens',
      'Iron-rich foods'
    ],
    'Follicular': [
      'Chicken breast',
      'Quinoa',
      'Greek yogurt',
      'Almonds',
      'Fresh fruits',
      'Fermented foods'
    ],
    'Ovulatory': [
      'Salmon',
      'Tofu',
      'Chickpeas',
      'Pumpkin seeds',
      'Cruciferous vegetables',
      'Berries'
    ],
    'Luteal': [
      'Turkey',
      'Black beans',
      'Cottage cheese',
      'Chia seeds',
      'Sweet potatoes',
      'Magnesium-rich foods'
    ],
  };

  @override
  void initState() {
    super.initState();
    // Set protein requirements for each phase
    for (var phase in phaseNutrientGoals.keys) {
      phaseNutrientGoals[phase]!['protein'] = widget.proteinRequirement;
    }
  }

  String getCurrentPhase(DateTime date) {
    final daysSinceStart = date.difference(widget.lastPeriodDate).inDays % widget.cycleDuration;
    
    if (daysSinceStart < 5) return 'Menstrual';
    if (daysSinceStart < 14) return 'Follicular';
    if (daysSinceStart < 17) return 'Ovulatory';
    return 'Luteal';
  }

  void _addNutrientIntake() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Nutrient Intake'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNutrientInput('Protein (g)', (value) {
                dailyIntake.protein += value;
              }),
              _buildNutrientInput('Iron (mg)', (value) {
                dailyIntake.iron += value;
              }),
              _buildNutrientInput('Calcium (mg)', (value) {
                dailyIntake.calcium += value;
              }),
              _buildNutrientInput('Vitamin D (IU)', (value) {
                dailyIntake.vitaminD += value;
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
              // Save to Firebase here if needed
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientInput(String label, Function(double) onChanged) {
    return TextField(
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        final numValue = double.tryParse(value) ?? 0;
        onChanged(numValue);
      },
    );
  }

  Widget _buildNutrientProgress(String nutrient, double current, double goal) {
    final percentage = (current / goal).clamp(0.0, 1.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$nutrient: ${current.toStringAsFixed(1)} / ${goal.toStringAsFixed(1)}',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            percentage < 0.6 ? Colors.orange : Colors.green,
          ),
          minHeight: 10,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRecommendationCard(String title, List<String> items, {Color? iconColor, IconData? iconData}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(
                    iconData ?? Icons.check_circle_outline,
                    color: iconColor,
                  ),
                  title: Text(items[index]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

 // Previous code remains the same until DashboardScreen's build method

  @override
  Widget build(BuildContext context) {
    final currentPhase = getCurrentPhase(selectedDay);
    final currentGoals = phaseNutrientGoals[currentPhase]!;
    final avoidFoods = phaseAvoidFoods[currentPhase]!;
    final recommendedFoods = phaseRecommendedFoods[currentPhase]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Period & Nutrition Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calendar Card moved to the top
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Calendar',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TableCalendar(
                      firstDay: DateTime.utc(2023, 1, 1),
                      lastDay: DateTime.utc(2025, 12, 31),
                      focusedDay: selectedDay,
                      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                      onDaySelected: (selected, focused) {
                        setState(() {
                          selectedDay = selected;
                        });
                      },
                      calendarFormat: CalendarFormat.month,
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        markerDecoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, date, events) {
                          final phase = getCurrentPhase(date);
                          return Container(
                            margin: const EdgeInsets.all(4.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _getPhaseColor(phase).withOpacity(0.3),
                            ),
                            width: 8,
                            height: 8,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Current Phase and Nutrient Progress Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Phase: $currentPhase',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nutrient Progress',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    _buildNutrientProgress(
                      'Protein',
                      dailyIntake.protein,
                      currentGoals['protein']!,
                    ),
                    _buildNutrientProgress(
                      'Iron',
                      dailyIntake.iron,
                      currentGoals['iron']!,
                    ),
                    _buildNutrientProgress(
                      'Calcium',
                      dailyIntake.calcium,
                      currentGoals['calcium']!,
                    ),
                    _buildNutrientProgress(
                      'Vitamin D',
                      dailyIntake.vitaminD,
                      currentGoals['vitaminD']!,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildRecommendationCard(
              'Recommended Foods for $currentPhase Phase',
              recommendedFoods,
              iconColor: Colors.green,
              iconData: Icons.check_circle,
            ),
            const SizedBox(height: 20),
            _buildRecommendationCard(
              'Foods to Avoid in $currentPhase Phase',
              avoidFoods,
              iconColor: Colors.red,
              iconData: Icons.not_interested,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNutrientIntake,
        child: const Icon(Icons.add),
        tooltip: 'Add Nutrient Intake',
      ),
    );
  }
  Color _getPhaseColor(String phase) {
    switch (phase) {
      case 'Menstrual':
        return Colors.red;
      case 'Follicular':
        return Colors.orange;
      case 'Ovulatory':
        return Colors.green;
      case 'Luteal':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

// Add this extension at the end of the file
extension DateTimeExtension on DateTime {
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

extension StringExtensions on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}