import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PregnancyTrackingPage extends StatefulWidget {
  @override
  _PregnancyTrackingPageState createState() => _PregnancyTrackingPageState();
}

class _PregnancyTrackingPageState extends State<PregnancyTrackingPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Initial setup controllers
  DateTime? _lastPeriodDate;
  DateTime? _dueDate;
  bool _isInitialSetup = true;

  // Tracking state
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  int _currentWeek = 0;
  int _remainingWeeks = 0;

  // Form controllers
  final _weightController = TextEditingController();
  final _bloodPressureController = TextEditingController();
  final _notesController = TextEditingController();

  // Advanced tracking features
  final List<String> _availableSymptoms = [
    'Morning Sickness',
    'Fatigue',
    'Headache',
    'Back Pain',
    'Swelling',
    'Heartburn',
    'Cramping',
    'Mood Swings',
    'Food Cravings',
    'Food Aversions',
    'Insomnia',
    'Breast Tenderness',
  ];
  List<String> _selectedSymptoms = [];
  int _kickCount = 0;
  DateTime? _kickCountStartTime;
  List<String> _medications = [];

  // Pregnancy milestones and information
  final Map<int, Map<String, dynamic>> _pregnancyStages = {
    1: {
      'title': 'First Week',
      'development': 'Fertilization occurs',
      'size': 'Microscopic',
      'tips': ['Start taking prenatal vitamins', 'Avoid alcohol and smoking'],
      'checkups': ['Schedule first prenatal visit'],
    },
    4: {
      'title': 'First Month',
      'development': 'Implantation complete, placenta forming',
      'size': 'Poppy seed',
      'tips': ['Track early pregnancy symptoms', 'Stay hydrated'],
      'checkups': ['First ultrasound'],
    },
    8: {
      'title': 'Second Month',
      'development': 'Major organs forming',
      'size': 'Kidney bean',
      'tips': ['Start pregnancy exercises', 'Get adequate rest'],
      'checkups': ['Check blood pressure and weight'],
    },
    // Add more weeks as needed...
    40: {
      'title': 'Final Week',
      'development': 'Baby is full term',
      'size': 'Watermelon',
      'tips': ['Monitor contractions', 'Pack hospital bag'],
      'checkups': ['Weekly doctor visits'],
    },
  };

  @override
  void initState() {
    super.initState();
    _checkInitialSetup();
  }

  Future<void> _checkInitialSetup() async {
    try {
      String userId = _auth.currentUser!.uid;
      var doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('pregnancy')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      setState(() {
        _isInitialSetup = doc.docs.isEmpty;
      });

      if (!_isInitialSetup) {
        var data = doc.docs.first.data();
        _loadPregnancyData(data);
      }
    } catch (e) {
      print('Error checking initial setup: $e');
    }
  }

  void _loadPregnancyData(Map<String, dynamic> data) {
    setState(() {
      _lastPeriodDate = (data['lastPeriodDate'] as Timestamp).toDate();
      _dueDate = (data['dueDate'] as Timestamp).toDate();
      _calculatePregnancyProgress();
    });
  }

  void _calculatePregnancyProgress() {
    if (_lastPeriodDate != null) {
      int daysSinceStart = DateTime.now().difference(_lastPeriodDate!).inDays;
      setState(() {
        _currentWeek = (daysSinceStart / 7).floor() + 1;
        _remainingWeeks = 40 - _currentWeek;
      });
    }
  }

  Widget _buildInitialSetupForm() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pregnancy Setup'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to Pregnancy Tracking!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Please provide your pregnancy information to get started:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ListTile(
              title: Text('Last Menstrual Period Date'),
              subtitle: _lastPeriodDate != null
                  ? Text(DateFormat('MMM dd, yyyy').format(_lastPeriodDate!))
                  : null,
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _lastPeriodDate ?? DateTime.now(),
                  firstDate: DateTime.now().subtract(Duration(days: 280)),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() {
                    _lastPeriodDate = picked;
                    // Automatically calculate due date (40 weeks from LMP)
                    _dueDate = picked.add(Duration(days: 280));
                  });
                }
              },
            ),
            SizedBox(height: 10),
            ListTile(
              title: Text('Estimated Due Date'),
              subtitle: _dueDate != null
                  ? Text(DateFormat('MMM dd, yyyy').format(_dueDate!))
                  : null,
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate:
                      _dueDate ?? DateTime.now().add(Duration(days: 280)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 280)),
                );
                if (picked != null) {
                  setState(() {
                    _dueDate = picked;
                  });
                }
              },
            ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _lastPeriodDate != null && _dueDate != null
                    ? _saveInitialSetup
                    : null,
                child: Text('Start Tracking'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveInitialSetup() async {
    try {
      String userId = _auth.currentUser!.uid;
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('pregnancy')
          .add({
        'lastPeriodDate': Timestamp.fromDate(_lastPeriodDate!),
        'dueDate': Timestamp.fromDate(_dueDate!),
        'createdAt': FieldValue.serverTimestamp(),
        'measurements': {},
        'symptoms': {},
        'medications': [],
      });

      setState(() {
        _isInitialSetup = false;
        _calculatePregnancyProgress();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving pregnancy data: $e')),
      );
    }
  }

  Widget _buildWeeklyProgress() {
    Map<String, dynamic> currentStageInfo = _pregnancyStages[_currentWeek] ??
        {
          'title': 'Week $_currentWeek',
          'development': 'Development in progress'
        };

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Week $_currentWeek of 40',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('$_remainingWeeks weeks until due date'),
            SizedBox(height: 15),
            LinearProgressIndicator(
              value: _currentWeek / 40,
              minHeight: 10,
            ),
            SizedBox(height: 20),
            Text(
              currentStageInfo['title'],
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Development: ${currentStageInfo['development']}'),
            if (currentStageInfo['size'] != null) ...[
              SizedBox(height: 5),
              Text('Baby Size: ${currentStageInfo['size']}'),
            ],
            if (currentStageInfo['tips'] != null) ...[
              SizedBox(height: 10),
              Text(
                'Tips:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...List<Widget>.from(
                (currentStageInfo['tips'] as List).map(
                  (tip) => Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text('• $tip'),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDailyTrackingForm() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Tracking',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            TextField(
              controller: _weightController,
              decoration: InputDecoration(
                labelText: 'Weight (kg)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _bloodPressureController,
              decoration: InputDecoration(
                labelText: 'Blood Pressure',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            Text(
              'Symptoms',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8,
              children: _availableSymptoms.map((symptom) {
                return FilterChip(
                  label: Text(symptom),
                  selected: _selectedSymptoms.contains(symptom),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedSymptoms.add(symptom);
                      } else {
                        _selectedSymptoms.remove(symptom);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKickCounter() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fetal Movement Counter',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Text(
                    '$_kickCount',
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (_kickCountStartTime == null) {
                          _kickCountStartTime = DateTime.now();
                        }
                        _kickCount++;
                      });
                    },
                    child: Text('Record Movement'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _kickCount = 0;
                        _kickCountStartTime = null;
                      });
                    },
                    child: Text('Reset'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveDailyTracking() async {
    try {
      String userId = _auth.currentUser!.uid;
      String dateKey = DateFormat('yyyy-MM-dd').format(_selectedDay);

      Map<String, dynamic> trackingData = {
        'weight': _weightController.text.isNotEmpty
            ? double.parse(_weightController.text)
            : null,
        'bloodPressure': _bloodPressureController.text,
        'symptoms': _selectedSymptoms,
        'kickCount': _kickCount,
        'notes': _notesController.text,
        'timestamp': FieldValue.serverTimestamp(),
      };

      var pregnancyRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('pregnancy')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (pregnancyRef.docs.isNotEmpty) {
        await pregnancyRef.docs.first.reference.update({
          'measurements.$dateKey': trackingData,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tracking data saved successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving tracking data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialSetup) {
      return _buildInitialSetupForm();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Pregnancy Tracker'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveDailyTracking,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildWeeklyProgress(),
            SizedBox(height: 16),
            TableCalendar(
              firstDay: _lastPeriodDate!,
              lastDay: _dueDate!,
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: _calendarFormat,
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                // Load data for selected date
                _loadDailyData(selectedDay);
              },
              // Calendar styling
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
              ),
            ),
            SizedBox(height: 16),
            _buildDailyTrackingForm(),
            SizedBox(height: 16),
            _buildKickCounter(),
            SizedBox(height: 16),
            // Notes section
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notes',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Add any notes or thoughts for the day...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            // Medication tracking
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Medications',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _medications.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_medications[index]),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _medications.removeAt(index);
                              });
                            },
                          ),
                        );
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Add Medication',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            // Add medication logic
                            if (_notesController.text.isNotEmpty) {
                              setState(() {
                                _medications.add(_notesController.text);
                                _notesController.clear();
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadDailyData(DateTime date) async {
    try {
      String userId = _auth.currentUser!.uid;
      String dateKey = DateFormat('yyyy-MM-dd').format(date);

      var pregnancyRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('pregnancy')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (pregnancyRef.docs.isNotEmpty) {
        var data = pregnancyRef.docs.first.data();
        var measurements = data['measurements'] ?? {};

        if (measurements[dateKey] != null) {
          var dayData = measurements[dateKey];
          setState(() {
            _weightController.text = dayData['weight']?.toString() ?? '';
            _bloodPressureController.text = dayData['bloodPressure'] ?? '';
            _selectedSymptoms = List<String>.from(dayData['symptoms'] ?? []);
            _kickCount = dayData['kickCount'] ?? 0;
            _notesController.text = dayData['notes'] ?? '';
            _medications = List<String>.from(dayData['medications'] ?? []);
          });
        } else {
          // Reset form if no data exists for selected date
          _resetForms();
        }
      }
    } catch (e) {
      print('Error loading daily data: $e');
    }
  }

  void _resetForms() {
    setState(() {
      _weightController.clear();
      _bloodPressureController.clear();
      _selectedSymptoms = [];
      _kickCount = 0;
      _notesController.clear();
      _medications = [];
    });
  }

  @override
  void dispose() {
    _weightController.dispose();
    _bloodPressureController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
