import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardians_app/data/repositories/reports_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'bloc/home/home_cubit.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/user_repository.dart';

import 'presentation/screens/login_screen.dart';
import 'presentation/screens/register_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/reports_screen.dart';
import 'presentation/screens/statistics_screen.dart';

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
        RepositoryProvider<AuthRepository>(
          create: (_) => AuthRepository(firestore: FirebaseFirestore.instance),
        ),
        RepositoryProvider<ReportsRepository>(
          create: (_) => ReportsRepository(),
        ),
        RepositoryProvider<UserRepository>(
          create: (_) => FirebaseUserRepository(),
        ),
      ],
      child: MaterialApp(
        title: 'CyShieldGuardians',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(builder: (_) => const LoginScreen());
            case '/register':
              return MaterialPageRoute(builder: (_) => const RegisterScreen());
            case '/home':
              return MaterialPageRoute(
                builder:
                    (ctx) => BlocProvider(
                      create: (_) => HomeCubit(ctx.read<UserRepository>()),
                      child: const HomeScreen(),
                    ),
              );
            case '/reports':
              return MaterialPageRoute(builder: (_) => ReportsScreen());
            case '/statistics':
              return MaterialPageRoute(builder: (_) => StatisticsScreen());
            default:
              return MaterialPageRoute(
                builder:
                    (_) => const Scaffold(
                      body: Center(child: Text('404 – Page not found')),
                    ),
              );
          }
        },
      ),
    );
  }
}
