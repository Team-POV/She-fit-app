import 'package:flutter/material.dart';
import 'package:she_fit_app/pages/reproductivehealth.dart';
import 'package:she_fit_app/services/auth_services.dart';

class HomePage extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'She-Fit',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.logout),
                onPressed: () async {
                  try {
                    await _authService.signOut();
                    // Add a small delay to ensure Firebase completes the sign-out
                    await Future.delayed(Duration(milliseconds: 500));

                    if (context.mounted) {
                      // Check if context is still valid
                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Successfully signed out'),
                          backgroundColor:
                              const Color.fromARGB(255, 120, 213, 188),
                        ),
                      );

                      // Navigate to login screen
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/signin',
                        (Route<dynamic> route) => false,
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      // Check if context is still valid
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
              // Replace CircleAvatar with a more reliable implementation
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                ),
                child: Icon(
                  Icons.person,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Hello, User!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Ready to focus on your well-being today?',
            style: TextStyle(fontSize: 16),
          ),
        ),
        SizedBox(height: 24),
        _buildCategoryCards(context),
      ],
    );
  }

  Widget _buildCategoryCards(BuildContext context) {
    return Column(
      children: [
        _buildCategoryCard(
          'Reproductive Health',
          Icons.favorite,
          Colors.pink[100]!,
          context,
        ),
        SizedBox(height: 16),
        _buildCategoryCard(
          'Fitness',
          Icons.fitness_center,
          Colors.blue[100]!,
          context,
        ),
        SizedBox(height: 16),
        _buildCategoryCard(
          'Mental Well-being',
          Icons.self_improvement,
          Colors.green[100]!,
          context,
        ),
      ],
    );
  }

  Widget _buildCategoryCard(
      String title, IconData icon, Color color, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (title == 'Reproductive Health') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ReproductiveHealthPage()),
          );
        }
      },
      child: Container(
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
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today), label: 'Track'),
        BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Community'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
