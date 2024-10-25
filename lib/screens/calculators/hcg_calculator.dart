import 'package:flutter/material.dart';
import 'package:she_fit_app/models/calculator_model.dart';
import '../../widgets/shared_widgets.dart';

class HCGCalculatorPage extends StatefulWidget {
  @override
  _HCGCalculatorPageState createState() => _HCGCalculatorPageState();
}

class _HCGCalculatorPageState extends State<HCGCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  double? _initialLevel;
  double? _finalLevel;
  int _hours = 48;
  Map<String, dynamic>? _result;

  @override
  Widget build(BuildContext context) {
    return CalculatorBasePage(
      title: 'hCG Calculator',
      description: '''
The hCG Calculator helps you monitor your pregnancy hormone progression. It calculates:
• hCG doubling time
• Whether the progression is within normal range
Normal doubling time is typically between 48-72 hours in early pregnancy.
''',
      content: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildNumberInput(
              label: 'Initial hCG Level (mIU/mL)',
              onChanged: (value) => _initialLevel = value,
            ),
            SizedBox(height: 20),
            _buildNumberInput(
              label: 'Final hCG Level (mIU/mL)',
              onChanged: (value) => _finalLevel = value,
            ),
            SizedBox(height: 20),
            _buildHoursPicker(),
            SizedBox(height: 20),
            _buildCalculateButton(),
          ],
        ),
      ),
      result: _result != null ? _buildResult() : null,
    );
  }

  Widget _buildNumberInput({
    required String label,
    required Function(double) onChanged,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a value';
        }
        if (double.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      },
      onChanged: (value) {
        if (double.tryParse(value) != null) {
          onChanged(double.parse(value));
        }
      },
    );
  }

  Widget _buildHoursPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hours Between Tests'),
        Slider(
          value: _hours.toDouble(),
          min: 24,
          max: 96,
          divisions: 72,
          label: _hours.toString(),
          onChanged: (value) {
            setState(() => _hours = value.round());
          },
        ),
      ],
    );
  }

  Widget _buildCalculateButton() {
    return ElevatedButton(
      onPressed: (_initialLevel != null && _finalLevel != null)
          ? () {
              if (_formKey.currentState!.validate()) {
                setState(() {
                  _result = PregnancyCalculations.calculateHCG(
                    _initialLevel!,
                    _finalLevel!,
                    _hours,
                  );
                });
              }
            }
          : null,
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
              'Doubling Time',
              '${_result!['doublingTime'].toStringAsFixed(1)} hours',
            ),
            _buildResultRow(
              'Status',
              _result!['isNormal'] ? 'Normal Range' : 'Outside Normal Range',
              textColor: _result!['isNormal'] ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {Color? textColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
