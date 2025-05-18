import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardians_app/data/repositories/kid_repository.dart';
import 'package:guardians_app/data/repositories/notifications_repository.dart';
import 'package:guardians_app/data/repositories/reports_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guardians_app/presentation/AuthNavigator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:guardians_app/presentation/screens/family_screen.dart';
import 'package:guardians_app/presentation/screens/home_screen.dart';
import 'package:guardians_app/presentation/screens/login_screen.dart';
import 'package:guardians_app/presentation/screens/notifications_screen.dart';
import 'package:guardians_app/presentation/screens/profile_screen.dart';
import 'bloc/family/family_cubit.dart';
import 'bloc/home/home_cubit.dart';
import 'bloc/notifications/notifications_cubit.dart';
import 'bloc/profile/profile_cubit.dart';
import 'core/services/notification_service.dart';
import 'firebase_options.dart';

import 'data/repositories/auth_repository.dart';
import 'data/repositories/user_repository.dart';

import 'presentation/screens/register_screen.dart';
import 'presentation/screens/reports_screen.dart';
import 'presentation/screens/statistics_screen.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(CyShieldGuardiansApp());
}

class CyShieldGuardiansApp extends StatefulWidget {
  const CyShieldGuardiansApp({super.key});

  @override
  State<CyShieldGuardiansApp> createState() => _CyshieldGuardiansAppState();
}

class _CyshieldGuardiansAppState extends State<CyShieldGuardiansApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    NotificationService.initialize(
      navigatorKey: _navigatorKey,
      onTokenRefresh: (token) async {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && token != null) {
          FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'fcmTokens': FieldValue.arrayUnion([token]),
          });
        }
      },
    );
  }

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
        RepositoryProvider<KidRepository>(create: (_) => KidRepository()),
        RepositoryProvider<NotificationRepository>(
          create: (_) => NotificationRepository(),
        ),
      ],
      child: MaterialApp(
        title: 'CyShieldGuardians',
        theme: ThemeData(primarySwatch: Colors.blue,useMaterial3: true),
        home: const AuthNavigator(),
        navigatorKey: _navigatorKey,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/home':
              return MaterialPageRoute(
                builder: (_) => BlocProvider<HomeCubit>(
                  create: (ctx) => HomeCubit(ctx.read<UserRepository>()),
                  child: const HomeScreen(),
                ),
              );
            case '/family':
              return MaterialPageRoute(
                builder: (_) => BlocProvider<FamilyCubit>(
                  create: (ctx) =>
                      FamilyCubit(ctx.read<UserRepository>(), ctx.read<KidRepository>()),
                  child: const FamilyScreen(),
                ),
              );
            case '/register':
              return MaterialPageRoute(builder: (_) => const RegisterScreen());
            case '/login':
              return MaterialPageRoute(builder: (_) => const LoginScreen());
            case '/reports':
              return MaterialPageRoute(builder: (_) => ReportsScreen());
            case '/statistics':
              return MaterialPageRoute(builder: (_) => StatisticsScreen());
            case '/notifications':
              return MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (ctx) =>
                      NotificationsCubit(ctx.read<NotificationRepository>()),
                  child: const NotificationsScreen(),
                ),
              );
            case '/profile':
              return MaterialPageRoute(
                builder: (_) => BlocProvider<ProfileCubit>(
                  create: (ctx) =>
                      ProfileCubit(ctx.read<AuthRepository>(), ctx.read<UserRepository>()),
                  child: const ProfileScreen(),
                ),
              );
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
