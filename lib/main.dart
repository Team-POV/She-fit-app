import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:she_fit_app/firebase_options.dart';
import 'package:she_fit_app/homepage/homepage.dart';
import 'package:she_fit_app/pages/reproductivehealth.dart';
import 'package:she_fit_app/signIn-Up-Screen/signin_page.dart';
import 'package:she_fit_app/signIn-Up-Screen/signup_page.dart';
import 'package:she_fit_app/screens/calculator_home.dart';
import 'package:she_fit_app/pages/preg-tracking.dart';

// calculators
import 'package:she_fit_app/routes/calculator_routes.dart';
import 'package:she_fit_app/screens/calculators/due_date_calculator.dart';
import 'package:she_fit_app/screens/calculators/hcg_calculator.dart';
import 'package:she_fit_app/screens/calculators/implantation_calculator.dart';
import 'package:she_fit_app/screens/calculators/ivf_due_date_calculator.dart';
import 'package:she_fit_app/screens/calculators/ovulation_calculator.dart';
import 'package:she_fit_app/screens/calculators/period_calculator.dart';
import 'package:she_fit_app/screens/calculators/pregnancy_test_calculator.dart';
import 'package:she_fit_app/screens/calculators/ultrasound_due_date_calculator.dart';
import 'package:she_fit_app/screens/calculators/GlycemicMonitoring.dart';
import 'package:she_fit_app/screens/calculators/PrenatalMonitoring.dart';
import 'package:she_fit_app/pages/she-fit-chat-boat.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'She-Fit',
      theme: ThemeData(
        primaryColor: Color(0xFF2B8C96),
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF2B8C96)),
        useMaterial3: true,
      ),
      initialRoute: '/signin',
      routes: {
        // Authentication routes
        '/home': (context) => HomePage(),
        '/signin': (context) => SignInPage(),
        '/signup': (context) => SignUpPage(),
        '/menstrual-tracker': (context) => ReproductiveHealthPage(),
        '/pregnancy-tracker': (context) => PregnancyTrackingPage(),
        '/shefit-chat': (context) => SheHelpChatbot(),

        // Calculator routes
        '/calculator': (context) => CalculatorHome(),
        CalculatorRoutes.ovulation: (context) => OvulationCalculatorPage(),
        CalculatorRoutes.GlycemicMonitoringPage: (context) =>
            GlycemicMonitoringPage(),
        CalculatorRoutes.hcg: (context) => HCGCalculatorPage(),
        CalculatorRoutes.PrenatalMonitoring: (context) =>
            PrenatalMonitoringPage(),
        CalculatorRoutes.pregnancyTest: (context) =>
            PregnancyTestCalculatorPage(),
        CalculatorRoutes.period: (context) => PeriodCalculatorPage(),
        CalculatorRoutes.implantation: (context) =>
            ImplantationCalculatorPage(),
        CalculatorRoutes.dueDate: (context) => DueDateCalculatorPage(),
        CalculatorRoutes.ivfDueDate: (context) => IVFDueDateCalculatorPage(),
        CalculatorRoutes.ultrasoundDueDate: (context) =>
            UltrasoundDueDateCalculatorPage(),
      },
    );
  }
}
