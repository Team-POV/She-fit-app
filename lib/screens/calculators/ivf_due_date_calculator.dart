import 'package:flutter/material.dart';
import 'package:she_fit_app/models/calculator_model.dart';
import '../../widgets/shared_widgets.dart';
import '../../utils/custom_date_utils.dart';

class IVFDueDateCalculatorPage extends StatefulWidget {
  @override
  _IVFDueDateCalculatorPageState createState() =>
      _IVFDueDateCalculatorPageState();
}

class _IVFDueDateCalculatorPageState extends State<IVFDueDateCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _retrievalDate;
  int _transferDay = 5;
  DateTime? _result;

  @override
  Widget build(BuildContext context) {
    return CalculatorBasePage(
      title: 'IVF Due Date Calculator',
      description: '''
The IVF Due Date Calculator helps you estimate your due date for IVF pregnancies. It calculates:
• Estimated due date based on egg retrieval date
• Accounts for day 3 or day 5 transfers
Specific to IVF and FET pregnancies.
''',
      content: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildDatePicker(),
            SizedBox(height: 20),
            _buildTransferDayPicker(),
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
          initialDate: _retrievalDate ?? DateTime.now(),
          firstDate: DateTime.now().subtract(Duration(days: 30)),
          lastDate: DateTime.now().add(Duration(days: 30)),
        );
        if (date != null) {
          setState(() => _retrievalDate = date);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Egg Retrieval Date',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_retrievalDate == null
                ? 'Select date'
                : CustomDateUtils.formatDate(_retrievalDate!)),
            Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferDayPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Transfer Day'),
        Row(
          children: [
            Expanded(
              child: RadioListTile<int>(
                title: Text('Day 3'),
                value: 3,
                groupValue: _transferDay,
                onChanged: (value) {
                  setState(() => _transferDay = value!);
                },
              ),
            ),
            Expanded(
              child: RadioListTile<int>(
                title: Text('Day 5'),
                value: 5,
                groupValue: _transferDay,
                onChanged: (value) {
                  setState(() => _transferDay = value!);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCalculateButton() {
    return ElevatedButton(
      onPressed: _retrievalDate == null
          ? null
          : () {
              if (_formKey.currentState!.validate()) {
                setState(() {
                  _result = PregnancyCalculations.calculateIVFDueDate(
                    _retrievalDate!,
                    _transferDay,
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
              'Transfer Day',
              'Day $_transferDay',
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
