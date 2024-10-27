import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:she_fit_app/pages/reDeitpage.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
// Enhanced model class for daily tracking data
class DailyTrackingData {
  final DateTime date;
  final String? flowIntensity;
  final List<String> symptoms;
  final String mood;
  final List<String> cleanlinessPractices;
  final bool isFertile;
  final String notes;
  final String cyclePhase;

  DailyTrackingData({
    required this.date,
    this.flowIntensity,
    required this.symptoms,
    required this.mood,
    required this.cleanlinessPractices,
    required this.isFertile,
    required this.notes,
    required this.cyclePhase,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'flowIntensity': flowIntensity,
      'symptoms': symptoms,
      'mood': mood,
      'cleanlinessPractices': cleanlinessPractices,
      'isFertile': isFertile,
      'notes': notes,
      'cyclePhase': cyclePhase,
    };
  }

  factory DailyTrackingData.fromMap(Map<String, dynamic> map) {
    return DailyTrackingData(
      date: (map['date'] as Timestamp).toDate(),
      flowIntensity: map['flowIntensity'],
      symptoms: List<String>.from(map['symptoms'] ?? []),
      mood: map['mood'] ?? 'neutral',
      cleanlinessPractices: List<String>.from(map['cleanlinessPractices'] ?? []),
      isFertile: map['isFertile'] ?? false,
      notes: map['notes'] ?? '',
      cyclePhase: map['cyclePhase'] ?? 'none',
    );
  }
}

// Enhanced model for cycle information
class CycleInfo {
  final DateTime startDate;
  final DateTime? endDate;
  final int cycleLength;
  final int periodLength;

  CycleInfo({
    required this.startDate,
    this.endDate,
    required this.cycleLength,
    required this.periodLength,
  });

  Map<String, dynamic> toMap() {
    return {
      'startDate': startDate,
      'endDate': endDate,
      'cycleLength': cycleLength,
      'periodLength': periodLength,
    };
  }

  factory CycleInfo.fromMap(Map<String, dynamic> map) {
    return CycleInfo(
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: map['endDate'] != null ? (map['endDate'] as Timestamp).toDate() : null,
      cycleLength: map['cycleLength'] ?? 28,
      periodLength: map['periodLength'] ?? 5,
    );
  }
}

class CyclePhaseInfo {
  final String name;
  final Color color;
  final List<String> symptoms;
  final List<String> recommendations;
  final List<String> cleanlinessPractices;

  CyclePhaseInfo({
    required this.name,
    required this.color,
    required this.symptoms,
    required this.recommendations,
    required this.cleanlinessPractices,
  });
}

class CycleService {
 final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _userId;

 Future<void> initializeUser() async {
    // Wait for Firebase Auth to initialize
    await Future.delayed(Duration(seconds: 1));
    
    // Get current user
    final user = FirebaseAuth.instance.currentUser;
    _userId = user?.uid;
    
    if (_userId == null) {
      throw Exception('User not authenticated');
    }
  }

  final Map<String, CyclePhaseInfo> phaseInfo = {
    'menstrual': CyclePhaseInfo(
      name: 'Menstrual Phase',
      color: Colors.red.shade100,
      symptoms: ['Cramps', 'Fatigue', 'Lower back pain'],
      recommendations: [
        'Take rest',
        'Drink warm water',
        'Eat iron-rich foods',
      ],
      cleanlinessPractices: [
        'Change pad/tampon every 4-6 hours',
        'Take warm shower',
        'Wear comfortable cotton underwear',
        'Keep intimate area clean and dry',
      ],
    ),
    'follicular': CyclePhaseInfo(
      name: 'Follicular Phase',
      color: Colors.orange.shade100,
      symptoms: ['Increased energy', 'Better mood', 'Improved skin'],
      recommendations: [
        'Exercise regularly',
        'Start new projects',
        'Socialize more',
      ],
      cleanlinessPractices: [
        'Maintain regular hygiene',
        'Wear breathable clothing',
      ],
    ),
    'ovulation': CyclePhaseInfo(
      name: 'Ovulation Phase',
      color: Colors.green.shade100,
      symptoms: ['Mild pain', 'Changes in discharge', 'Increased libido'],
      recommendations: [
        'Track fertility signs',
        'Monitor temperature',
        'Note any pain',
      ],
      cleanlinessPractices: [
        'Pay attention to discharge changes',
        'Maintain intimate hygiene',
        'Wear clean, cotton underwear',
      ],
    ),
    'luteal': CyclePhaseInfo(
      name: 'Luteal Phase',
      color: Colors.purple.shade100,
      symptoms: ['Mood changes', 'Breast tenderness', 'Bloating'],
      recommendations: [
        'Practice self-care',
        'Avoid caffeine',
        'Stay hydrated',
      ],
      cleanlinessPractices: [
        'Maintain regular hygiene',
        'Wear comfortable clothing',
      ],
    ),
  };
    String get userId {
    if (_userId == null) {
      throw Exception('CycleService not initialized. Call initializeUser() first.');
    }
    return _userId!;
  }


  // Store cycle information
 
  // Store daily tracking data
   Future<void> saveCycleInfo(CycleInfo cycleInfo) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)  // Using getter instead of direct access
          .collection('cycleInfo')
          .add(cycleInfo.toMap());
    } catch (e) {
      print('Error saving cycle info: $e');
      throw e;
    }
  }

  Future<void> saveDailyData(DailyTrackingData data) async {
    try {
      String dateString = DateFormat('yyyy-MM-dd').format(data.date);
      await _firestore
          .collection('users')
          .doc(userId)  // Using getter instead of direct access
          .collection('dailyData')
          .doc(dateString)
          .set(data.toMap());
    } catch (e) {
      print('Error saving daily data: $e');
      throw e;
    }
  }
  // Get daily tracking data for a specific date
Future<DailyTrackingData?> getDailyData(DateTime date) async {
    try {
      String dateString = DateFormat('yyyy-MM-dd').format(date);
      final doc = await _firestore
          .collection('users')
          .doc(userId)  // Using getter instead of direct access
          .collection('dailyData')
          .doc(dateString)
          .get();

      if (doc.exists) {
        return DailyTrackingData.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting daily data: $e');
      return null;
    }
  }

  // Get all cycle information
  Future<List<CycleInfo>> getAllCycleInfo() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)  // Using getter instead of direct access
          .collection('cycleInfo')
          .orderBy('startDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CycleInfo.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting cycle info: $e');
      return [];
    }
  }
  // Stream daily data for real-time updates
  Stream<Map<DateTime, DailyTrackingData>> streamDailyData() {
    return _firestore
        .collection('users')
        .doc(userId)  // Using getter instead of direct access
        .collection('dailyData')
        .snapshots()
        .map((snapshot) {
      Map<DateTime, DailyTrackingData> dataMap = {};
      for (var doc in snapshot.docs) {
        DailyTrackingData data = DailyTrackingData.fromMap(doc.data());
        dataMap[data.date] = data;
      }
      return dataMap;
    });
  }
}

class ReproductiveHealthPage extends StatefulWidget {
  @override
  _ReproductiveHealthPageState createState() => _ReproductiveHealthPageState();
}

class _ReproductiveHealthPageState extends State<ReproductiveHealthPage> {
  late CycleService _cycleService;
  bool _isInitialized = false;  
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  
  // Form controllers - Initialize with empty strings
  final _startDateController = TextEditingController(text: '');
  final _endDateController = TextEditingController(text: '');
  final _cycleLengthController = TextEditingController(text: '28');
  final _periodLengthController = TextEditingController(text: '5');
  final _notesController = TextEditingController(text: '');
  // Tracking selections
   List<String> selectedSymptoms = [];
  String selectedFlow = 'medium';
  String selectedMood = 'neutral';
  List<String> selectedCleanlinessPractices = [];
  bool isFertile = false;

  final List<String> allSymptoms = [
    'Cramps',
    'Headache',
    'Backache',
    'Fatigue',
    'Bloating',
    'Breast Pain',
    'Mood Swings',
    'Acne',
    'Discharge Changes',
    'Spotting',
  ];

  final Map<String, IconData> flowIcons = {
    'light': Icons.water_drop_outlined,
    'medium': Icons.water_drop,
    'heavy': Icons.opacity,
    'spotting': Icons.circle_outlined,
  };

  final Map<String, String> moodEmojis = {
    'happy': '😊',
    'neutral': '😐',
    'sad': '😢',
    'tired': '😴',
    'anxious': '😰',
  };

   @override
  void initState() {
    super.initState();
    _cycleService = CycleService();
    _initializeService();
  }
  @override
  void dispose() {
    // Properly dispose of controllers
    _startDateController.dispose();
    _endDateController.dispose();
    _cycleLengthController.dispose();
    _periodLengthController.dispose();
    _notesController.dispose();
    super.dispose();
  }

 Future<void> _initializeService() async {
    try {
      await _cycleService.initializeUser();
      setState(() {
        _isInitialized = true;
      });
      _checkFirstTimeUser();
    } catch (e) {
      print('Error initializing service: $e');
      // Handle initialization error (e.g., show error message or redirect to login)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please login to continue'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  Future<void> _checkFirstTimeUser() async {
    final prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

    if (isFirstTime) {
      _showInitialSetupDialog();
      await prefs.setBool('isFirstTime', false);
    }
  }

  void _showInitialSetupDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Welcome to Period Tracker'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Please enter your last period details to get started:'),
              SizedBox(height: 16),
              TextField(
                controller: _startDateController,
                decoration: InputDecoration(
                  labelText: 'Last Period Start Date',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(_startDateController),
                  ),
                ),
                readOnly: true,
              ),
              TextField(
                controller: _endDateController,
                decoration: InputDecoration(
                  labelText: 'Last Period End Date',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(_endDateController),
                  ),
                ),
                readOnly: true,
              ),
              TextField(
                controller: _cycleLengthController,
                decoration: InputDecoration(
                  labelText: 'Average Cycle Length (days)',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _periodLengthController,
                decoration: InputDecoration(
                  labelText: 'Average Period Length (days)',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _saveInitialCycleInfo();
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

 Future<void> _saveInitialCycleInfo() async {
    try {
      // Add null checks and default values
      if (_startDateController.text.isEmpty) {
        throw Exception('Start date is required');
      }

      final startDate = DateFormat('yyyy-MM-dd').parse(_startDateController.text);
      final endDate = _endDateController.text.isNotEmpty
          ? DateFormat('yyyy-MM-dd').parse(_endDateController.text)
          : null;
      final cycleLength = int.tryParse(_cycleLengthController.text) ?? 28;
      final periodLength = int.tryParse(_periodLengthController.text) ?? 5;

      CycleInfo cycleInfo = CycleInfo(
        startDate: startDate,
        endDate: endDate,
        cycleLength: cycleLength,
        periodLength: periodLength,
      );

      await _cycleService.saveCycleInfo(cycleInfo);
      
      if (mounted) {  // Check if widget is still mounted
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cycle information saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {  // Check if widget is still mounted
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving cycle information: $e')),
        );
      }
    }
  }
  String _getCyclePhase(DateTime date, List<CycleInfo> cycles) {
    if (cycles.isEmpty) return 'none';

    try {
      CycleInfo? lastCycle = cycles.firstWhere(
        (cycle) => cycle.startDate.isBefore(date) || 
                   cycle.startDate.isAtSameMomentAs(date),
        orElse: () => cycles.last,
      );

      int dayOfCycle = date.difference(lastCycle.startDate).inDays + 1;

      if (dayOfCycle <= (lastCycle.periodLength)) return 'menstrual';
      if (dayOfCycle <= 13) return 'follicular';
      if (dayOfCycle <= 15) return 'ovulation';
      return 'luteal';
    } catch (e) {
      return 'none';
    }
  }

  // Add these methods to your _ReproductiveHealthPageState class

  // Calculate current cycle day
  int getCurrentCycleDay(List<CycleInfo> cycles) {
    if (cycles.isEmpty) return 0;
    
    CycleInfo? currentCycle = cycles.firstWhere(
      (cycle) => cycle.startDate.isBefore(_selectedDay) || 
                 cycle.startDate.isAtSameMomentAs(_selectedDay),
      orElse: () => cycles.last,
    );
    
    return _selectedDay.difference(currentCycle.startDate).inDays + 1;
  }


  // Calculate fertility rate (0-100)
  int getFertilityRate(int cycleDay, int cycleLength) {
    if (cycleDay == 0) return 0;
    
    // Highest fertility around ovulation (usually around day 14 in a 28-day cycle)
    int ovulationDay = (cycleLength / 2).round();
    int fertileDaysStart = ovulationDay - 5;
    int fertileDaysEnd = ovulationDay + 2;
    
    if (cycleDay >= fertileDaysStart && cycleDay <= fertileDaysEnd) {
      // Highest fertility on ovulation day
      if (cycleDay == ovulationDay) return 100;
      // High fertility 2 days before and after ovulation
      if ((ovulationDay - cycleDay).abs() <= 2) return 80;
      // Moderate fertility in the wider fertile window
      return 60;
    }
    
    return 20; // Low fertility outside fertile window
  }

  void _showEditCycleDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Cycle Start Date'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _startDateController,
              decoration: InputDecoration(
                labelText: 'Cycle Start Date',
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(_startDateController),
                ),
              ),
              readOnly: true,
            ),
            TextField(
              controller: _cycleLengthController,
              decoration: InputDecoration(
                labelText: 'Cycle Length (days)',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _saveInitialCycleInfo();
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildCycleInfo(List<CycleInfo> cycles) {
    int cycleDay = getCurrentCycleDay(cycles);
    int cycleLength = cycles.isNotEmpty ? cycles.last.cycleLength : 28;
    int fertilityRate = getFertilityRate(cycleDay, cycleLength);

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cycle Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: _showEditCycleDialog,
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Cycle Day',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(
                    'Day $cycleDay of $cycleLength',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Fertility Rate',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(
                    '$fertilityRate%',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _getFertilityColor(fertilityRate),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getFertilityColor(int rate) {
    if (rate >= 80) return Colors.red;
    if (rate >= 60) return Colors.orange;
    return Colors.green;
  }

// Update your build method to include the new cycle info widget

Widget _buildCalendar(Map<DateTime, DailyTrackingData> dailyData, List<CycleInfo> cycles) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
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
          _loadDayData(selectedDay);
        },
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            String phase = _getCyclePhase(day, cycles);
            return Container(
              margin: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _cycleService.phaseInfo[phase]?.color ?? Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    color: dailyData.containsKey(day) ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            );
          },
          selectedBuilder: (context, day, focusedDay) {
            String phase = _getCyclePhase(day, cycles);
            return Container(
              margin: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _cycleService.phaseInfo[phase]?.color ?? Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).primaryColor, width: 2),
              ),
              child: Center(
                child: Text(
                  '${day.day}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _loadDayData(DateTime day) async {
    try {
      DailyTrackingData? data = await _cycleService.getDailyData(day);
      if (mounted) {  // Check if widget is still mounted
        setState(() {
          if (data != null) {
            selectedSymptoms = data.symptoms;
            selectedFlow = data.flowIntensity ?? 'medium';
            selectedMood = data.mood;
            selectedCleanlinessPractices = data.cleanlinessPractices;
            isFertile = data.isFertile;
            _notesController.text = data.notes;
          } else {
            // Reset to default values if no data
            selectedSymptoms = [];
            selectedFlow = 'medium';
            selectedMood = 'neutral';
            selectedCleanlinessPractices = [];
            isFertile = false;
            _notesController.text = '';
          }
        });
      }
    } catch (e) {
      if (mounted) {  // Check if widget is still mounted
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  // Update CyclePhaseInfo to handle null phases
  Widget _buildPhaseIndicator(String phase) {
    // Add null check for phase info
    final info = _cycleService.phaseInfo[phase];
    if (info == null) {
      return Container(); // Return empty container if phase info is null
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: info.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            info.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (phase == 'ovulation') 
            _buildFertilityToggle(),
          SizedBox(height: 8),
          _buildSectionTitle('Common Symptoms'),
          ...info.symptoms.map((symptom) => _buildListItem(symptom)),
          SizedBox(height: 8),
          _buildSectionTitle('Recommendations'),
          ...info.recommendations.map((rec) => _buildListItem(rec)),
          if (phase == 'menstrual' && info.cleanlinessPractices.isNotEmpty) ...[
            SizedBox(height: 8),
            _buildSectionTitle('Cleanliness Practices'),
            ...info.cleanlinessPractices.map((practice) => _buildListItem(practice)),
          ],
        ],
      ),
    );
  }

  Widget _buildFertilityToggle() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text('Fertility Tracking: '),
          Switch(
            value: isFertile,
            onChanged: (value) {
              setState(() {
                isFertile = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildListItem(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 8, top: 4),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8),
          SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

   Widget _buildCleanlinessPractices() {
    final menstrualPhase = _cycleService.phaseInfo['menstrual'];
    if (menstrualPhase == null) {
      return Container(); // Return empty container if phase info is null
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cleanliness Practices',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: menstrualPhase.cleanlinessPractices
                .map((practice) => ChoiceChip(
                      label: Text(practice),
                      selected: selectedCleanlinessPractices.contains(practice),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedCleanlinessPractices.add(practice);
                          } else {
                            selectedCleanlinessPractices.remove(practice);
                          }
                        });
                      },
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }


  Widget _buildNotes() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Add any additional notes here...',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
    
  }
Widget _buildSymptomTracker() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Symptoms',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: allSymptoms.map((symptom) => ChoiceChip(
              label: Text(symptom),
              selected: selectedSymptoms.contains(symptom),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedSymptoms.add(symptom);
                  } else {
                    selectedSymptoms.remove(symptom);
                  }
                });
              },
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFlowTracker() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Flow Intensity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: flowIcons.entries.map((entry) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedFlow = entry.key;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: selectedFlow == entry.key
                        ? Theme.of(context).primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        entry.value,
                        color: selectedFlow == entry.key
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                        size: 28,
                      ),
                      SizedBox(height: 4),
                      Text(
                        entry.key.capitalize(),
                        style: TextStyle(
                          color: selectedFlow == entry.key
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodTracker() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mood',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: moodEmojis.entries.map((entry) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedMood = entry.key;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: selectedMood == entry.key
                        ? Theme.of(context).primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        entry.value,
                        style: TextStyle(fontSize: 28),
                      ),
                      SizedBox(height: 4),
                      Text(
                        entry.key.capitalize(),
                        style: TextStyle(
                          color: selectedMood == entry.key
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }


@override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  return Scaffold(
    backgroundColor: Color(0xFFE0F2F1),
    body: SafeArea(
      child: StreamBuilder<Map<DateTime, DailyTrackingData>>(
        stream: _cycleService.streamDailyData(),
        builder: (context, dailyDataSnapshot) {
          return FutureBuilder<List<CycleInfo>>(
            future: _cycleService.getAllCycleInfo(),
            builder: (context, cycleSnapshot) {
              if (!dailyDataSnapshot.hasData || !cycleSnapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              Map<DateTime, DailyTrackingData> dailyData = dailyDataSnapshot.data!;
              List<CycleInfo> cycles = cycleSnapshot.data!;
              String currentPhase = _getCyclePhase(_selectedDay, cycles);

              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCalendar(dailyData, cycles),
                      const SizedBox(height: 16),
                      _buildCycleInfo(cycles), // Add the new cycle info widget
                      const SizedBox(height: 16),
                      _buildPhaseIndicator(currentPhase),
                      const SizedBox(height: 16),
                      _buildSymptomTracker(),
                      const SizedBox(height: 16),
                      _buildFlowTracker(),
                      const SizedBox(height: 16),
                      _buildMoodTracker(),
                      if (currentPhase == 'menstrual') ...[
                        const SizedBox(height: 16),
                        _buildCleanlinessPractices(),
                      ],
                      const SizedBox(height: 16),
                      _buildNotes(),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    floatingActionButton: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FloatingActionButton(
            heroTag: "saveButton",
            backgroundColor: Color(0xFF26A69A),
            child: Icon(Icons.save),
            onPressed: _saveDailyData,
          ),
          FloatingActionButton(
            heroTag: "nextButton",
            backgroundColor: Color(0xFF26A69A),
            child: Icon(Icons.arrow_forward),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserInfoForm()),
              );
            },
          ),
        ],
      ),
    ),
  );
}

  Future<void> _saveDailyData() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      List<CycleInfo> cycles = await _cycleService.getAllCycleInfo();
      String currentPhase = _getCyclePhase(_selectedDay, cycles);

      DailyTrackingData dailyData = DailyTrackingData(
        date: _selectedDay,
        flowIntensity: selectedFlow,
        symptoms: selectedSymptoms,
        mood: selectedMood,
        cleanlinessPractices: selectedCleanlinessPractices,
        isFertile: isFertile,
        notes: _notesController.text,
        cyclePhase: currentPhase,
      );

      await _cycleService.saveDailyData(dailyData);

      Navigator.pop(context); // Hide loading indicator

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Hide loading indicator
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving data: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

