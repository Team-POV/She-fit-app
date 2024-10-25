import 'package:flutter/material.dart';
import 'package:she_fit_app/models/calculator_model.dart';
import '../../widgets/shared_widgets.dart';
import '../../utils/custom_date_utils.dart';

class DueDateCalculatorPage extends StatefulWidget {
  @override
  _DueDateCalculatorPageState createState() => _DueDateCalculatorPageState();
}

class _DueDateCalculatorPageState extends State<DueDateCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _lastPeriod;
  DateTime? _result;

  @override
  Widget build(BuildContext context) {
    return CalculatorBasePage(
      title: 'Due Date Calculator',
      description: '''
The Due Date Calculator helps you estimate your baby's arrival date. It calculates:
• Your estimated due date (EDD)
• Pregnancy milestones
Based on your last menstrual period (LMP), assuming a 28-day cycle.
''',
      content: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildDatePicker(),
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
          firstDate: DateTime.now().subtract(Duration(days: 280)),
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

  Widget _buildCalculateButton() {
    return ElevatedButton(
      onPressed: _lastPeriod == null
          ? null
          : () {
              if (_formKey.currentState!.validate()) {
                setState(() {
                  _result =
                      PregnancyCalculations.calculateDueDate(_lastPeriod!);
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
              'First Trimester Ends',
              CustomDateUtils.formatDate(
                _lastPeriod!.add(Duration(days: 90)),
              ),
            ),
            _buildResultRow(
              'Second Trimester Ends',
              CustomDateUtils.formatDate(
                _lastPeriod!.add(Duration(days: 180)),
              ),
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
