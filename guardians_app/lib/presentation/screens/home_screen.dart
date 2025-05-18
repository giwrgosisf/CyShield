import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardians_app/presentation/widgets/custom_appbar.dart';
import '../../bloc/home/home_cubit.dart';
import '../../bloc/home/home_state.dart';
import '../../core/app_theme.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/card_button.dart';

class HomeScreen extends StatelessWidget {
  static const _navIndex = 0;

  static const _routes = ['/home', '/family', '/notifications', '/profile'];

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Cyshield'),
      body: SafeArea(
        child: BlocConsumer<HomeCubit, HomeState>(
          listenWhen:
              (prev, curr) =>
                  prev.status != curr.status &&
                  curr.status == HomeStatus.failure,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage ?? 'Error loading Home screen',
                ),
              ),
            );
          },
          builder: (context, state) {
            switch (state.status) {
              case HomeStatus.loading:
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                );

              case HomeStatus.failure:
                return Center(
                  child: Text(
                    state.errorMessage ?? 'Error loading Home screen',
                    style: const TextStyle(color: Colors.red),
                  ),
                );

              case HomeStatus.success:
                final firstName = state.profile!.firstName;
                return _Body(firstName: firstName);
            }
          },
        ),
      ),
      bottomNavigationBar: BottomNav(
        current: _navIndex,
        onTap: (i) {
          final target = _routes[i];
          // only navigate if we’re not already on that route
          if (ModalRoute.of(context)!.settings.name != target) {
            Navigator.pushReplacementNamed(context, target);
          }
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final String firstName;

  const _Body({required this.firstName});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 36, 16, 36),
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
