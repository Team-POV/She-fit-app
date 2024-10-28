import 'package:flutter/material.dart';
import 'package:she_fit_app/models/calculator_model.dart';
import '../../widgets/shared_widgets.dart';
import '../../utils/custom_date_utils.dart';

class OvulationCalculatorPage extends StatefulWidget {
  const OvulationCalculatorPage({Key? key}) : super(key: key);

  @override
  _OvulationCalculatorPageState createState() =>
      _OvulationCalculatorPageState();
}

class _OvulationCalculatorPageState extends State<OvulationCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _lastPeriod;
  int _cycleLength = 28;
  Map<String, DateTime>? _result;

  void _calculateOvulation() {
    if (_lastPeriod == null) return;

    try {
      final calculationResult = PregnancyCalculations.calculateOvulation(
        _lastPeriod!,
        _cycleLength,
      );

      setState(() {
        _result = {
          'ovulation': calculationResult['ovulation'] ?? DateTime.now(),
          'windowStart': calculationResult['windowStart'] ?? DateTime.now(),
          'windowEnd': calculationResult['windowEnd'] ?? DateTime.now(),
        };
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error calculating ovulation dates. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectDate() async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _lastPeriod ?? DateTime.now(),
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
        setState(() => _lastPeriod = picked);
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
            labelText: 'First Day of Last Period',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            errorText: _lastPeriod == null ? 'Please select a date' : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _lastPeriod == null
                    ? 'Select date'
                    : CustomDateUtils.formatDate(_lastPeriod!),
                style: TextStyle(
                  color: _lastPeriod == null
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

  Widget _buildCycleLengthPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Cycle Length (days)'),
        Slider(
          value: _cycleLength.toDouble(),
          min: 21,
          max: 35,
          divisions: 14,
          label: _cycleLength.toString(),
          onChanged: (value) {
            setState(() => _cycleLength = value.round());
          },
        ),
        Text(
          'Selected: $_cycleLength days',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildCalculateButton() {
    return ElevatedButton(
      onPressed: _lastPeriod == null ? null : _calculateOvulation,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: const Text('Calculate'),
    );
  }

  Widget _buildResult() {
    if (_result == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fertility Window',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildResultRow(
              'Ovulation Date',
              CustomDateUtils.formatDate(_result!['ovulation']!),
            ),
            _buildResultRow(
              'Fertile Window Starts',
              CustomDateUtils.formatDate(_result!['windowStart']!),
            ),
            _buildResultRow(
              'Fertile Window Ends',
              CustomDateUtils.formatDate(_result!['windowEnd']!),
            ),
            _buildResultRow(
              'Cycle Length',
              '$_cycleLength days',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
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

  @override
  Widget build(BuildContext context) {
    return CalculatorBasePage(
      title: 'Ovulation Calculator',
      description: '''
The Ovulation Calculator helps you determine your most fertile days to maximize your chances of conception. It calculates:
• Your estimated ovulation date
• Your fertile window (5 days before to 1 day after ovulation)
• Your best days for conception
Based on your cycle length, ovulation typically occurs 14 days before your next period.
''',
      content: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildDatePicker(),
            const SizedBox(height: 20),
            _buildCycleLengthPicker(),
            const SizedBox(height: 20),
            _buildCalculateButton(),
          ],
        ),
      ),
      result: _buildResult(),
    );
  }
}
