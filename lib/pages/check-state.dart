import 'package:flutter/material.dart';

class StatementCheckerPage extends StatefulWidget {
  const StatementCheckerPage({Key? key}) : super(key: key);

  @override
  State<StatementCheckerPage> createState() => _StatementCheckerPageState();
}

class _StatementCheckerPageState extends State<StatementCheckerPage> {
  final TextEditingController _controller = TextEditingController();
  String _result = '';
  Color _resultColor = Colors.black;

  // List of problematic patterns based on the research document
  final List<Map<String, dynamic>> _abusivePatterns = [
    {
      'category': 'Religious/Patriarchal Discrimination',
      'patterns': [
        'stay in kitchen',
        'belong in home',
        'should not work',
        'should not speak',
        'dress properly',
        'be modest',
        'your place is'
      ]
    },
    {
      'category': 'Derogatory Terms',
      'patterns': [
        'bitch',
        'whore',
        'slut',
        'pussy',
        'loose',
        'stupid woman',
        'weak woman',
        'pokpok',
        'puta'
      ]
    },
    {
      'category': 'Victim Blaming',
      'patterns': [
        'asking for it',
        'deserve it',
        'your fault',
        'should have dressed',
        'should not have been',
        'what were you wearing',
        'were you drinking'
      ]
    },
    {
      'category': 'Opinion Suppression',
      'patterns': [
        'shut up woman',
        'women dont understand',
        'stay quiet',
        'who asked you',
        'know your place',
        'stick to'
      ]
    }
  ];

  void _analyzeStatement() {
    String statement = _controller.text.toLowerCase();
    List<String> foundPatterns = [];
    String category = '';

    for (var patternGroup in _abusivePatterns) {
      for (var pattern in patternGroup['patterns'] as List<String>) {
        if (statement.contains(pattern)) {
          foundPatterns.add(pattern);
          category = patternGroup['category'] as String;
          break;
        }
      }
    }

    setState(() {
      if (foundPatterns.isEmpty) {
        _result =
            'No obvious abusive content detected. However, if you feel uncomfortable, trust your instincts and seek support.';
        _resultColor = Colors.green;
      } else {
        _result =
            'WARNING: Potentially abusive content detected.\n\nCategory: $category\n\nThis statement contains concerning language. Consider reporting this incident and seeking support from relevant authorities or support groups.';
        _resultColor = Colors.red;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statement Abuse Detector'),
        backgroundColor: Colors.purple.shade100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter the statement someone made towards you:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Type the statement here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _analyzeStatement,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Analyze Statement',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            if (_result.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _resultColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _resultColor),
                ),
                child: Text(
                  _result,
                  style: TextStyle(
                    color: _resultColor,
                    fontSize: 16,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            const Text(
              'Note: This is a basic detection tool. If you feel unsafe or threatened, please contact local authorities or support services immediately.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
