import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/home/home_cubit.dart';
import '../../bloc/home/home_state.dart';
import '../../core/app_theme.dart';
import '../../core/containers/strings.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/card_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listenWhen:
          (prev, curr) =>
              prev.status != curr.status && curr.status == HomeStatus.failure,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage ?? 'Error loading Home screen'),
          ),
        );
      },
      builder: (context, state) {
        if (state.status == HomeStatus.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.status == HomeStatus.failure) {
          return Scaffold(
            body: Center(
              child: Text(state.errorMessage ?? 'Error loading Home screen'),
            ),
          );
        }

        final firstName = state.profile!.firstName;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppTheme.secondary,
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) {},
                itemBuilder:
                    (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'settings',
                        child: Text('Settings'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'help',
                        child: Text('Help'),
                      ),
                    ],
              ),
            ],
            elevation: 10,
            shadowColor: Colors.black.withAlpha((255).round()),
            title: Text(
              MyText.appTitle,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'ArbutusSlab',
                fontSize: 30,
                letterSpacing: 1,
              ),
            ),
            centerTitle: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
          ),
          body: _Body(firstName: firstName),
          bottomNavigationBar: BottomNav(
            current: state.selectedTab,
            onTap: (i) => context.read<HomeCubit>().selectTab(i),
          ),
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  final String firstName;

  const _Body({required this.firstName});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 36, 16, 12),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Γειά σου, $firstName !',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 4),
            const Text(
              'Ενημερώσου σχετικά με την ασφάλεια του παιδιού σου.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CardButton(
              asset: 'assets/images/home_reports.png',
              label: 'Αναφορές',
              onTap: () {
                Navigator.pushNamed(context, '/reports');
              },
            ),
            const SizedBox(height: 60),
            CardButton(
              asset: 'assets/images/home_statistics.png',
              label: 'Στατιστικά',
              onTap: () {
                Navigator.pushNamed(context, '/statistics');
              },
            ),
          ],
        ),
      ),
    );
  }
}
