import 'package:flutter/material.dart';
import 'package:she_fit_app/models/calculator_model.dart';
import '../../widgets/shared_widgets.dart';
import 'package:she_fit_app/utils/custom_date_utils.dart';

class ImplantationCalculatorPage extends StatefulWidget {
  @override
  _ImplantationCalculatorPageState createState() =>
      _ImplantationCalculatorPageState();
}

class _ImplantationCalculatorPageState
    extends State<ImplantationCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _ovulationDate;
  Map<String, DateTime>? _result;

  @override
  Widget build(BuildContext context) {
    return CalculatorBasePage(
      title: 'Implantation Calculator',
      description: '''
The Implantation Calculator helps you estimate when embryo implantation might occur. It calculates:
• Earliest possible implantation date
• Latest possible implantation date
Based on your ovulation date.
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
          initialDate: _ovulationDate ?? DateTime.now(),
          firstDate: DateTime.now().subtract(Duration(days: 30)),
          lastDate: DateTime.now().add(Duration(days: 30)),
        );
        if (date != null) {
          setState(() => _ovulationDate = date);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Ovulation Date',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_ovulationDate == null
                ? 'Select date'
                : CustomDateUtils.formatDate(_ovulationDate!)),
            Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculateButton() {
    return ElevatedButton(
      onPressed: _ovulationDate == null
          ? null
          : () {
              if (_formKey.currentState!.validate()) {
                setState(() {
                  _result = PregnancyCalculations.calculateImplantation(
                      _ovulationDate!);
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
              'Implantation Window',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 16),
            _buildResultRow(
              'Earliest Date',
              CustomDateUtils.formatDate(_result!['earliest']!),
            ),
            _buildResultRow(
              'Latest Date',
              CustomDateUtils.formatDate(_result!['latest']!),
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
