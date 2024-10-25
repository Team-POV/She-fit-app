import 'package:flutter/material.dart';
import 'package:she_fit_app/models/calculator_model.dart';
import '../../widgets/shared_widgets.dart';
import '../../utils/custom_date_utils.dart';

class PeriodCalculatorPage extends StatefulWidget {
  @override
  _PeriodCalculatorPageState createState() => _PeriodCalculatorPageState();
}

class _PeriodCalculatorPageState extends State<PeriodCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _lastPeriod;
  int _cycleLength = 28;
  int _monthsToPredict = 3;
  List<DateTime>? _result;

  @override
  Widget build(BuildContext context) {
    return CalculatorBasePage(
      title: 'Period Calculator',
      description: '''
The Period Calculator helps you predict your upcoming menstrual cycles. It calculates:
• Your next 3-6 period dates
• Cycle tracking information
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
            _buildMonthsPicker(),
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

  Widget _buildMonthsPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Number of Months to Predict'),
        Slider(
          value: _monthsToPredict.toDouble(),
          min: 3,
          max: 6,
          divisions: 3,
          label: _monthsToPredict.toString(),
          onChanged: (value) {
            setState(() => _monthsToPredict = value.round());
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
                  _result = PregnancyCalculations.calculateNextPeriods(
                    _lastPeriod!,
                    _cycleLength,
                    _monthsToPredict,
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
              'Predicted Period Dates',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 16),
            ...List.generate(_result!.length, (index) {
              return _buildResultRow(
                'Period ${index + 1}',
                CustomDateUtils.formatDate(_result![index]),
              );
            }),
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
