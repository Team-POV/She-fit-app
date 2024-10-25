import 'package:flutter/material.dart';
import 'package:she_fit_app/models/calculator_model.dart';
import '../../widgets/shared_widgets.dart';
import '../../utils/custom_date_utils.dart';

class PregnancyTestCalculatorPage extends StatefulWidget {
  @override
  _PregnancyTestCalculatorPageState createState() =>
      _PregnancyTestCalculatorPageState();
}

class _PregnancyTestCalculatorPageState
    extends State<PregnancyTestCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _lastPeriod;
  int _cycleLength = 28;
  Map<String, DateTime>? _result;

  @override
  Widget build(BuildContext context) {
    return CalculatorBasePage(
      title: 'Pregnancy Test Calculator',
      description: '''
The Pregnancy Test Calculator helps you determine the best time to take a pregnancy test. It calculates:
• Earliest possible test date
• Most accurate test date
Based on your last period and typical cycle length.
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
                  _result = PregnancyCalculations.calculatePregnancyTest(
                    _lastPeriod!,
                    _cycleLength,
                  );
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
              'Results',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 16),
            _buildResultRow(
              'Earliest Test Date',
              CustomDateUtils.formatDate(_result!['earliestTest']!),
            ),
            _buildResultRow(
              'Most Accurate Test Date',
              CustomDateUtils.formatDate(_result!['mostAccurate']!),
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
