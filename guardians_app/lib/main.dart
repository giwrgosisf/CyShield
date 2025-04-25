import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardians_app/data/repositories/reports_repository.dart';
import 'package:guardians_app/presentation/screens/reports_screen.dart';
import 'bloc/reports/reports_bloc.dart';
import 'data/repositories/auth_repository.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/temp.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(CyShieldGuardiansApp());
}

class CyShieldGuardiansApp extends StatelessWidget {
  const CyShieldGuardiansApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => ReportsRepository()),
      ],
      child: MaterialApp(
        title: 'CyShieldGuardians',
        theme: ThemeData(primarySwatch: Colors.blue),
        routes: {
          '/': (_) => LoginScreen(),
          '/temp': (_) => TempScreen(),
        },
      ),
    );
  }
}
