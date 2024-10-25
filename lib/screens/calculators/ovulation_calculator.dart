import 'package:flutter/material.dart';
import 'package:she_fit_app/models/calculator_model.dart';
import '../../widgets/shared_widgets.dart';
import '../../utils/custom_date_utils.dart';

class OvulationCalculatorPage extends StatefulWidget {
  @override
  _OvulationCalculatorPageState createState() =>
      _OvulationCalculatorPageState();
}

class _OvulationCalculatorPageState extends State<OvulationCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _lastPeriod;
  int _cycleLength = 28;
  Map<String, DateTime>? _result;

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
            SizedBox(height: 20),
            _buildCycleLengthPicker(),
            SizedBox(height: 20),
            _buildCalculateButton(),
          ],
        ),
      ),
      result: _result != null ? _buildResult() : null,
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _lastPeriod ?? DateTime.now(),
          firstDate: DateTime.now().subtract(Duration(days: 90)),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          setState(() => _lastPeriod = date);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'First Day of Last Period',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_lastPeriod == null
                ? 'Select date'
                : CustomDateUtils.formatDate(_lastPeriod!)),
            Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Widget _buildCycleLengthPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cycle Length (days)'),
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
      ],
    );
  }

  Widget _buildCalculateButton() {
    return ElevatedButton(
      onPressed: _lastPeriod == null
          ? null
          : () {
              if (_formKey.currentState!.validate()) {
                setState(() {
                  final calculationResult =
                      PregnancyCalculations.calculateOvulation(
                    _lastPeriod!,
                    _cycleLength,
                  );
                  _result = Map<String, DateTime>.from(calculationResult);
                });
              }
            },
      child: Text('Calculate'),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  Widget _buildResult() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(16),
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
            SizedBox(height: 16),
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
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
