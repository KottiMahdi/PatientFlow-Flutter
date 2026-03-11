import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'package:management_cabinet_medical_mobile/features/appointment/presentation/pages/appointment_page.dart';
import 'package:management_cabinet_medical_mobile/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:management_cabinet_medical_mobile/features/auth/presentation/pages/inscription_page.dart';
import 'package:management_cabinet_medical_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:management_cabinet_medical_mobile/features/home/presentation/pages/navigation_bar.dart';
import 'package:management_cabinet_medical_mobile/features/patient/presentation/pages/add_patient_page.dart';
import 'package:management_cabinet_medical_mobile/features/patient/presentation/pages/patients_page.dart';

import 'package:management_cabinet_medical_mobile/features/appointment/presentation/providers/appointment_provider.dart';
import 'package:management_cabinet_medical_mobile/features/waiting_room/presentation/providers/waiting_room_provider.dart';
import 'package:management_cabinet_medical_mobile/features/patient/presentation/providers/patient_provider.dart';
import 'package:management_cabinet_medical_mobile/features/profile/presentation/providers/profile_provider.dart';
import 'package:management_cabinet_medical_mobile/features/weather/presentation/providers/weather_provider.dart';
import 'package:management_cabinet_medical_mobile/features/auth/presentation/providers/auth_provider.dart';

import 'firebase_options.dart';
import 'core/di/injection_container.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await di.init();

  try {
    // Try to initialize with a specific name
    await Firebase.initializeApp(
      name: 'MedicalCabinetApp',
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // If that fails, get the existing instance
    Firebase.app('MedicalCabinetApp');
  }

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<PatientProviderGlobal>(
        create: (_) => di.sl<PatientProviderGlobal>(),
      ),
      ChangeNotifierProvider<AppointmentProviderGlobal>(
        create: (_) => di.sl<AppointmentProviderGlobal>(),
      ),
      ChangeNotifierProvider<WaitingRoomProviderGlobal>(
        create: (_) => di.sl<WaitingRoomProviderGlobal>(),
      ),
      ChangeNotifierProvider<WeatherProviderGlobal>(
        create: (_) => di.sl<WeatherProviderGlobal>(),
      ),
      ChangeNotifierProvider<AuthProviderGlobal>(
        create: (_) => di.sl<AuthProviderGlobal>(),
      ),
      ChangeNotifierProvider<ProfileProviderGlobal>(
        create: (_) => di.sl<ProfileProviderGlobal>(),
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medical Cabinet',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E3A8A)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: FirebaseAuth.instance.currentUser == null
          ? const MedicalLoginPage()
          : const AppNavigationBar(),
      routes: {
        '/patients': (context) => const PatientsPage(),
        '/addPatient': (context) => const AddPatientPage(),
        //'/editPatient': (context) => EditPatientPage()
        'signup': (context) => const MedicalSignUpPage(),
        'login': (context) => const MedicalLoginPage(),
        'forgotPWD': (context) => const ForgotPasswordPage(),
        'navigationBar': (context) => const AppNavigationBar(),
        'appointment': (context) => const AppointmentPage()
      },
    );
  }
}
