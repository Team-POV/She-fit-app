import 'package:flutter/material.dart';
import 'package:she_fit_app/Fiteness/fitnessHomepage.dart';
import 'package:she_fit_app/MentalWellbeing/MentalHomepage.dart';
import 'package:she_fit_app/services/auth_services.dart';
import 'package:she_fit_app/pages/repHomepage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE0F2F1),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildMainContent(context)),
            _buildBottomNavBar(),
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
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
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
                'SHEFTT',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF26A69A),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Color(0xFF26A69A)),
            onPressed: () async {
              try {
                await _authService.signOut();
                await Future.delayed(Duration(milliseconds: 500));

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Successfully signed out'),
                      backgroundColor: Color(0xFF26A69A),
                    ),
                  );
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/signin',
                    (Route<dynamic> route) => false,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to sign out: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
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
              'Welcome Back!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF26A69A),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your wellness journey continues here!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 30),
            _buildCategoryCards(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCards(BuildContext context) {
    return Column(
      children: [
        _buildCategoryCard(
          'Reproductive Health',
          'Track and manage your reproductive health journey',
          Icons.favorite,
          context,
          gradientColors: [Color(0xFF26A69A), Color(0xFF80CBC4)],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Rephomepage()),
          ),
        ),
        SizedBox(height: 20),
        _buildCategoryCard(
          'Fitness',
          'Personalized workouts and activity tracking',
          Icons.fitness_center,
          context,
          gradientColors: [Color(0xFF00897B), Color(0xFF4DB6AC)],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DashboardPage()),
          ),
        ),
        SizedBox(height: 20),
        _buildCategoryCard(
          'Mental Well-being',
          'Mindfulness exercises and mood tracking',
          Icons.self_improvement,
          context,
          gradientColors: [Color(0xFF00796B), Color(0xFF26A69A)],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MentalWellbeingChatbot()),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(
    String title,
    String subtitle,
    IconData icon,
    BuildContext context, {
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
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
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 32, color: Colors.white),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: BottomNavigationBar(
        selectedItemColor: Color(0xFF26A69A),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          if (index == 1) {
            Navigator.pushNamed(context, '/calculator');
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calculate), label: 'Calculator'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Track'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Community'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
