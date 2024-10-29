import 'package:flutter/material.dart';
import '../../widgets/shared_widgets.dart';
import '../../utils/custom_date_utils.dart';

class PrenatalMonitoringPage extends StatefulWidget {
  const PrenatalMonitoringPage({Key? key}) : super(key: key);

  @override
  _PrenatalMonitoringPageState createState() => _PrenatalMonitoringPageState();
}

class _PrenatalMonitoringPageState extends State<PrenatalMonitoringPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  int _gestationalWeek = 0;

  // Controllers for ultrasound measurements
  final _crownRumpController = TextEditingController();
  final _biparietal_diameterController = TextEditingController();
  final _femurLengthController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _maternalBPSystolicController = TextEditingController();
  final _maternalBPDiastolicController = TextEditingController();

  List<PrenatalReading> readings = [];
  Map<String, dynamic>? _latestStats;

  @override
  void dispose() {
    _crownRumpController.dispose();
    _biparietal_diameterController.dispose();
    _femurLengthController.dispose();
    _heartRateController.dispose();
    _maternalBPSystolicController.dispose();
    _maternalBPDiastolicController.dispose();
    super.dispose();
  }

  void _addReading() {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      return;
    }

    final reading = PrenatalReading(
      date: _selectedDate!,
      gestationalWeek: _gestationalWeek,
      crownRumpLength: double.tryParse(_crownRumpController.text),
      biparietalDiameter: double.tryParse(_biparietal_diameterController.text),
      femurLength: double.tryParse(_femurLengthController.text),
      fetalHeartRate: int.tryParse(_heartRateController.text),
      maternalBPSystolic: int.tryParse(_maternalBPSystolicController.text),
      maternalBPDiastolic: int.tryParse(_maternalBPDiastolicController.text),
    );

    setState(() {
      readings.add(reading);
      readings.sort((a, b) => b.date.compareTo(a.date));
      _updateStats(reading);
      _clearInputs();
    });
  }

  void _clearInputs() {
    _crownRumpController.clear();
    _biparietal_diameterController.clear();
    _femurLengthController.clear();
    _heartRateController.clear();
    _maternalBPSystolicController.clear();
    _maternalBPDiastolicController.clear();
    _selectedDate = null;
    _gestationalWeek = 0;
  }

  void _updateStats(PrenatalReading latestReading) {
    setState(() {
      _latestStats = {
        'gestationalWeek': latestReading.gestationalWeek,
        'fetalHeartRate': latestReading.fetalHeartRate,
        'maternalBP':
            '${latestReading.maternalBPSystolic}/${latestReading.maternalBPDiastolic}',
        'date': latestReading.date,
      };
    });
  }

  Future<void> _selectDate() async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate ?? DateTime.now(),
        firstDate:
            DateTime.now().subtract(const Duration(days: 280)), // ~40 weeks
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

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _selectDate,
      child: AbsorbPointer(
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Examination Date',
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
    );
  }

  Widget _buildGestationalWeekInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Gestational Week'),
        Slider(
          value: _gestationalWeek.toDouble(),
          min: 0,
          max: 42,
          divisions: 42,
          label: _gestationalWeek.toString(),
          onChanged: (value) {
            setState(() => _gestationalWeek = value.round());
          },
        ),
        Text(
          'Week $_gestationalWeek',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildMeasurementInput(
      String label, TextEditingController controller, String unit,
      {String? helperText}) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        suffixText: unit,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return null; // Making all measurements optional
        }
        if (double.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      },
    );
  }

  Widget _buildLatestStats() {
    if (_latestStats == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Latest Measurements',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatRow(
                'Gestational Week', 'Week ${_latestStats!['gestationalWeek']}'),
            _buildStatRow(
                'Fetal Heart Rate', '${_latestStats!['fetalHeartRate']} bpm'),
            _buildStatRow(
                'Maternal Blood Pressure', _latestStats!['maternalBP']),
            _buildStatRow(
                'Date', CustomDateUtils.formatDate(_latestStats!['date'])),
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

  Widget _buildReadingsHistory() {
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
              'Examination History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: readings.length,
              itemBuilder: (context, index) {
                final reading = readings[index];
                return ExpansionTile(
                  title: Text('Week ${reading.gestationalWeek}'),
                  subtitle: Text(CustomDateUtils.formatDate(reading.date)),
                  children: [
                    if (reading.crownRumpLength != null)
                      ListTile(
                        title: const Text('Crown-Rump Length'),
                        trailing: Text('${reading.crownRumpLength} mm'),
                      ),
                    if (reading.biparietalDiameter != null)
                      ListTile(
                        title: const Text('Biparietal Diameter'),
                        trailing: Text('${reading.biparietalDiameter} mm'),
                      ),
                    if (reading.femurLength != null)
                      ListTile(
                        title: const Text('Femur Length'),
                        trailing: Text('${reading.femurLength} mm'),
                      ),
                    if (reading.fetalHeartRate != null)
                      ListTile(
                        title: const Text('Fetal Heart Rate'),
                        trailing: Text('${reading.fetalHeartRate} bpm'),
                      ),
                    if (reading.maternalBPSystolic != null &&
                        reading.maternalBPDiastolic != null)
                      ListTile(
                        title: const Text('Maternal Blood Pressure'),
                        trailing: Text(
                            '${reading.maternalBPSystolic}/${reading.maternalBPDiastolic}'),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CalculatorBasePage(
      title: 'Prenatal Monitoring',
      description: '''
Track ultrasound measurements and cardiac health during pregnancy:
• Fetal measurements (Crown-Rump Length, Biparietal Diameter, Femur Length)
• Fetal heart rate monitoring
• Maternal blood pressure tracking
• Comprehensive examination history
Regular monitoring helps ensure healthy development of both mother and baby.
''',
      content: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildDatePicker(),
            const SizedBox(height: 20),
            _buildGestationalWeekInput(),
            const SizedBox(height: 20),
            _buildMeasurementInput(
                'Crown-Rump Length', _crownRumpController, 'mm',
                helperText: 'Measured in early pregnancy'),
            const SizedBox(height: 20),
            _buildMeasurementInput(
                'Biparietal Diameter', _biparietal_diameterController, 'mm'),
            const SizedBox(height: 20),
            _buildMeasurementInput(
                'Femur Length', _femurLengthController, 'mm'),
            const SizedBox(height: 20),
            _buildMeasurementInput(
                'Fetal Heart Rate', _heartRateController, 'bpm'),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildMeasurementInput(
                      'Systolic BP', _maternalBPSystolicController, 'mmHg'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMeasurementInput(
                      'Diastolic BP', _maternalBPDiastolicController, 'mmHg'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addReading,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text('Save Examination'),
            ),
          ],
        ),
      ),
      result: Column(
        children: [
          _buildLatestStats(),
          const SizedBox(height: 20),
          _buildReadingsHistory(),
        ],
      ),
    );
  }
}

class PrenatalReading {
  final DateTime date;
  final int gestationalWeek;
  final double? crownRumpLength;
  final double? biparietalDiameter;
  final double? femurLength;
  final int? fetalHeartRate;
  final int? maternalBPSystolic;
  final int? maternalBPDiastolic;

  PrenatalReading({
    required this.date,
    required this.gestationalWeek,
    this.crownRumpLength,
    this.biparietalDiameter,
    this.femurLength,
    this.fetalHeartRate,
    this.maternalBPSystolic,
    this.maternalBPDiastolic,
  });
}
