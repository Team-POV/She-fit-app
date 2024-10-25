import 'package:flutter/material.dart';
import 'package:she_fit_app/models/calculator_model.dart';
import '../../widgets/shared_widgets.dart';
import '../../utils/custom_date_utils.dart';

class UltrasoundDueDateCalculatorPage extends StatefulWidget {
  @override
  _UltrasoundDueDateCalculatorPageState createState() =>
      _UltrasoundDueDateCalculatorPageState();
}

class _UltrasoundDueDateCalculatorPageState
    extends State<UltrasoundDueDateCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _ultrasoundDate;
  double _gestationalAge = 6.0;
  DateTime? _result;

  @override
  Widget build(BuildContext context) {
    return CalculatorBasePage(
      title: 'Ultrasound Due Date Calculator',
      description: '''
The Ultrasound Due Date Calculator helps estimate your due date based on ultrasound measurements. It calculates:
• Due date based on gestational age from ultrasound
• Accounts for crown-rump length measurements
Most accurate in first trimester.
''',
      content: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildDatePicker(),
            SizedBox(height: 20),
            _buildGestationalAgePicker(),
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
          initialDate: _ultrasoundDate ?? DateTime.now(),
          firstDate: DateTime.now().subtract(Duration(days: 90)),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          setState(() => _ultrasoundDate = date);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Ultrasound Date',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_ultrasoundDate == null
                ? 'Select date'
                : CustomDateUtils.formatDate(_ultrasoundDate!)),
            Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Widget _buildGestationalAgePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gestational Age (weeks)'),
        Slider(
          value: _gestationalAge,
          min: 6.0,
          max: 13.0,
          divisions: 14,
          label: _gestationalAge.toStringAsFixed(1),
          onChanged: (value) {
            setState(() => _gestationalAge = value);
          },
        ),
      ],
    );
  }

  Widget _buildCalculateButton() {
    return ElevatedButton(
      onPressed: _ultrasoundDate == null
          ? null
          : () {
              if (_formKey.currentState!.validate()) {
                setState(() {
                  _result = PregnancyCalculations.calculateUltrasoundDueDate(
                    _ultrasoundDate!,
                    _gestationalAge,
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
              'Estimated Due Date',
              CustomDateUtils.formatDate(_result!),
            ),
            _buildResultRow(
              'Gestational Age at Ultrasound',
              '${_gestationalAge.toStringAsFixed(1)} weeks',
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
