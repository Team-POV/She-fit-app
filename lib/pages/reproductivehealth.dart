import 'package:flutter/material.dart';

class ReproductiveHealthPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reproductive Health'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildMainContent()),
            _buildBottomNavBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Reproductive Health',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Learn more about Puberty and Pregnancy.',
            style: TextStyle(fontSize: 16),
          ),
        ),
        SizedBox(height: 24),
        _buildCategoryCards(),
      ],
    );
  }

  Widget _buildCategoryCards() {
    return Column(
      children: [
        _buildCategoryCard(
          'Puberty',
          Icons.local_florist,
          Colors.purple[100]!,
        ),
        SizedBox(height: 16),
        _buildCategoryCard(
          'Pregnancy',
          Icons.child_care,
          Colors.orange[100]!,
        ),
      ],
    );
  }

  Widget _buildCategoryCard(String title, IconData icon, Color color) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 48),
          SizedBox(width: 16),
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
            icon: Icon(Icons.local_florist), label: 'Puberty'),
        BottomNavigationBarItem(
            icon: Icon(Icons.child_care), label: 'Pregnancy'),
      ],
    );
  }
}
