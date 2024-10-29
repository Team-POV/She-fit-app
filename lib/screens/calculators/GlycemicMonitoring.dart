import 'package:flutter/material.dart';
import 'package:she_fit_app/utils/custom_date_utils.dart';
import '../../widgets/shared_widgets.dart';

class GlycemicMonitoringPage extends StatefulWidget {
  const GlycemicMonitoringPage({Key? key}) : super(key: key);

  @override
  _GlycemicMonitoringPageState createState() => _GlycemicMonitoringPageState();
}

class _GlycemicMonitoringPageState extends State<GlycemicMonitoringPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _readingController = TextEditingController();

  static const double HIGH_THRESHOLD = 17.0; // Upper limit in mmol/L
  List<GlucoseReading> readings = [];
  Map<String, dynamic>? _stats;

  @override
  void dispose() {
    _readingController.dispose();
    super.dispose();
  }

  void _calculateStats() {
    if (readings.isEmpty) {
      setState(() => _stats = null);
      return;
    }

    double average =
        readings.map((r) => r.value).reduce((a, b) => a + b) / readings.length;
    double maxReading =
        readings.map((r) => r.value).reduce((a, b) => a > b ? a : b);
    double minReading =
        readings.map((r) => r.value).reduce((a, b) => a < b ? a : b);
    int highReadings = readings.where((r) => r.value > HIGH_THRESHOLD).length;

    setState(() {
      _stats = {
        'average': average,
        'maxReading': maxReading,
        'minReading': minReading,
        'highReadings': highReadings,
      };
    });
  }

  Future<void> _selectDate() async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate ?? DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 90)),
        lastDate: DateTime.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: Theme.of(context).primaryColor,
                  ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null && mounted) {
        setState(() => _selectedDate = picked);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error selecting date. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectTime() async {
    try {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: _selectedTime ?? TimeOfDay.now(),
      );

      if (picked != null && mounted) {
        setState(() => _selectedTime = picked);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error selecting time. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addReading() {
    if (!_formKey.currentState!.validate() ||
        _selectedDate == null ||
        _selectedTime == null) {
      return;
    }

    final reading = GlucoseReading(
      value: double.parse(_readingController.text),
      dateTime: DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      ),
    );

    setState(() {
      readings.add(reading);
      readings.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      _readingController.clear();
      _selectedDate = null;
      _selectedTime = null;
    });

    _calculateStats();
  }

  Widget _buildDateTimePickers() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _selectDate,
            child: AbsorbPointer(
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  errorText: _selectedDate == null ? 'Required' : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDate == null
                          ? 'Select date'
                          : CustomDateUtils.formatDate(_selectedDate!),
                      style: TextStyle(
                        color: _selectedDate == null
                            ? Theme.of(context).hintColor
                            : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: _selectTime,
            child: AbsorbPointer(
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Time',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  errorText: _selectedTime == null ? 'Required' : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedTime == null
                          ? 'Select time'
                          : _selectedTime!.format(context),
                      style: TextStyle(
                        color: _selectedTime == null
                            ? Theme.of(context).hintColor
                            : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const Icon(Icons.access_time),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadingInput() {
    return TextFormField(
      controller: _readingController,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Blood Glucose Reading (mmol/L)',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a reading';
        }
        final reading = double.tryParse(value);
        if (reading == null) {
          return 'Please enter a valid number';
        }
        if (reading < 0 || reading > 50) {
          return 'Please enter a realistic reading';
        }
        return null;
      },
    );
  }

  Widget _buildStats() {
    if (_stats == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatRow(
                'Average', '${_stats!['average'].toStringAsFixed(1)} mmol/L'),
            _buildStatRow('Highest',
                '${_stats!['maxReading'].toStringAsFixed(1)} mmol/L'),
            _buildStatRow(
                'Lowest', '${_stats!['minReading'].toStringAsFixed(1)} mmol/L'),
            _buildStatRow('High Readings', '${_stats!['highReadings']}'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingsList() {
    if (readings.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reading History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            ...readings.map((reading) {
              final isHigh = reading.value > HIGH_THRESHOLD;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${reading.value.toStringAsFixed(1)} mmol/L',
                      style: TextStyle(
                        color: isHigh ? Colors.red : Colors.black,
                        fontWeight:
                            isHigh ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    Text(
                      CustomDateUtils.formatDate(reading.dateTime),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CalculatorBasePage(
      title: 'Glycemic Monitoring',
      description: '''
The Glycemic Monitoring Calculator helps track blood glucose levels during pregnancy:
• Standard upper limit: 17 mmol/L
• Readings above this may indicate high stress
• Regular monitoring helps maintain healthy glucose levels
• Consult healthcare provider for personalized advice
''',
      content: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildReadingInput(),
            const SizedBox(height: 20),
            _buildDateTimePickers(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addReading,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text('Add Reading'),
            ),
          ],
        ),
      ),
      result: Column(
        children: [
          _buildStats(),
          const SizedBox(height: 20),
          _buildReadingsList(),
        ],
      ),
    );
  }
}

class GlucoseReading {
  final double value;
  final DateTime dateTime;

  GlucoseReading({
    required this.value,
    required this.dateTime,
  });
}
