import 'package:flutter/material.dart';

class Rephomepage extends StatelessWidget {
  const Rephomepage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE0F2F1),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _buildMainContent(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Color(0xFF26A69A)),
            onPressed: () => Navigator.pop(context),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF26A69A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.favorite,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Reproductive Health',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF26A69A),
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Your Journey',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF26A69A),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Track and monitor your reproductive health',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 30),
            _buildHealthCards(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthCards(BuildContext context) {
    return Column(
      children: [
        _buildHealthCard(
          title: 'Track Menstrual Cycle',
          description: 'Monitor your cycle, symptoms, and get predictions',
          imagePath: 'assets/images/menstrual_cycle.png',
          gradientColors: [Color(0xFFE91E63), Color(0xFFF06292)],
          onTap: () => Navigator.pushNamed(context, '/menstrual-tracker'),
          icon: Icons.calendar_today,
        ),
        SizedBox(height: 20),
        _buildHealthCard(
          title: 'Track Pregnancy',
          description: 'Journey through your pregnancy milestones',
          imagePath: 'assets/images/pregnancy.png',
          gradientColors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
          onTap: () => Navigator.pushNamed(context, '/pregnancy-tracker'),
          icon: Icons.child_care,
        ),
        SizedBox(height: 20),
        _buildHealthCard(
          title: 'She Fit Chat Bot',
          description: ' feel free to Learn about body changes and health',
          imagePath: 'assets/images/chats.png',
          gradientColors: [Color(0xFF7B1FA2), Color(0xFFAB47BC)],
          onTap: () => Navigator.pushNamed(context, '/shefit-chat'),
          icon: Icons.book,
        ),
      ],
    );
  }

  Widget _buildHealthCard({
    required String title,
    required String description,
    required String imagePath,
    required List<Color> gradientColors,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Pattern
            Positioned(
              right: -30,
              bottom: -30,
              child: Icon(
                icon,
                size: 150,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
