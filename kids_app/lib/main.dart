import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_app/bloc/pair/pairing_screen_cubit.dart';
import 'package:kids_app/data/repositories/auth_repository.dart';
import 'package:kids_app/data/repositories/kid_repository.dart';
import 'package:kids_app/presentation/AuthNavigator.dart';
import 'package:kids_app/presentation/screens/login_screen.dart';
import 'package:kids_app/presentation/screens/pairing_screen.dart';
import 'package:kids_app/presentation/screens/register_screen.dart';



import 'core/services/notification_service.dart';
import 'core/services/pairing_service.dart';
import 'firebase_options.dart';

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


  runApp(CyShieldKidsApp());
}

class CyShieldKidsApp extends StatefulWidget {

  const CyShieldKidsApp({ super.key});

  @override
  State<CyShieldKidsApp> createState() => _CyShieldKidsAppState();
}

class _CyShieldKidsAppState extends State<CyShieldKidsApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    NotificationService.initialize(
      navigatorKey: _navigatorKey,
      onTokenRefresh: (token) async {
        final kid = FirebaseAuth.instance.currentUser;
        if (kid != null && token != null) {
          FirebaseFirestore.instance.collection('kids').doc(kid.uid).update({
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
        RepositoryProvider<KidRepository>(
          create: (_) => FirebaseUserRepository(),
        ),

        RepositoryProvider<PairingService>(
          create: (ctx) =>
              PairingService(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CyShieldKids',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        home: const AuthNavigator(),
        navigatorKey: _navigatorKey,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/register':
              return MaterialPageRoute(builder: (_) => const RegisterScreen());
            case '/login':
              return MaterialPageRoute(builder: (_) => const LoginScreen());
            case '/pairing':
              return MaterialPageRoute(
                builder:
                    (_) => BlocProvider<PairingScreenCubit>(
                      create:
                          (ctx) => PairingScreenCubit(
                            ctx.read<KidRepository>(),
                            context.read<PairingService>(),
                          ),
                      child: const PairingScreen(),
                    ),
              );
          }
        },
      ),
    );
  }
}
