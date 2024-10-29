import 'package:flutter/material.dart';
import 'package:she_fit_app/routes/calculator_routes.dart';

class CalculatorHome extends StatelessWidget {
  final List<CalculatorInfo> calculators = [
    CalculatorInfo(
      title: 'Ovulation Calculator',
      description: 'Track your fertile window to optimize conception chances',
      route: CalculatorRoutes.ovulation,
      icon: Icons.calendar_today,
    ),
    CalculatorInfo(
      title: 'hCG Calculator',
      description: 'Monitor pregnancy hormone progression',
      route: CalculatorRoutes.hcg,
      icon: Icons.trending_up,
    ),
    CalculatorInfo(
      title: 'Pregnancy Test Calculator',
      description: 'Find the best time to take a pregnancy test',
      route: CalculatorRoutes.pregnancyTest,
      icon: Icons.science,
    ),
    CalculatorInfo(
      title: 'Period Calculator',
      description: 'Predict your next menstrual cycles',
      route: CalculatorRoutes.period,
      icon: Icons.date_range,
    ),
    CalculatorInfo(
      title: 'Implantation Calculator',
      description: 'Estimate when implantation might occur',
      route: CalculatorRoutes.implantation,
      icon: Icons.favorite,
    ),
    CalculatorInfo(
      title: 'Glycemic Monitoring',
      description: 'GMB (Glycemic Monitoring in Blood Sugar)',
      route: CalculatorRoutes.GlycemicMonitoringPage,
      icon: Icons.bloodtype,
    ),
    CalculatorInfo(
      title: 'Due Date Calculator',
      description: 'Calculate your estimated delivery date',
      route: CalculatorRoutes.dueDate,
      icon: Icons.child_care,
    ),
    CalculatorInfo(
      title: 'Prenatal Monitoring',
      description:
          'Ultrasound is a routine part of prenatal care to monitor fetal development',
      route: CalculatorRoutes.PrenatalMonitoring,
      icon: Icons.woman_outlined,
    ),
    CalculatorInfo(
      title: 'IVF Due Date Calculator',
      description: 'Calculate due date for IVF pregnancies',
      route: CalculatorRoutes.ivfDueDate,
      icon: Icons.medical_services,
    ),
    CalculatorInfo(
      title: 'Ultrasound Due Date',
      description: 'Calculate due date based on ultrasound',
      route: CalculatorRoutes.ultrasoundDueDate,
      icon: Icons.waves_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pregnancy Calculators'),
        backgroundColor: Color(0xFF2B8C96),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2B8C96).withOpacity(0.1),
              Colors.white,
              Color(0xFF40E0D0).withOpacity(0.1),
            ],
          ),
        ),
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: calculators.length,
          itemBuilder: (context, index) {
            return _buildCalculatorCard(context, calculators[index]);
          },
        ),
      ),
    );
  }

  Widget _buildCalculatorCard(BuildContext context, CalculatorInfo info) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, info.route),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF2B8C96).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  info.icon,
                  color: Color(0xFF2B8C96),
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2B8C96),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      info.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF2B8C96),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CalculatorInfo {
  final String title;
  final String description;
  final String route;
  final IconData icon;

  CalculatorInfo({
    required this.title,
    required this.description,
    required this.route,
    required this.icon,
  });
}
