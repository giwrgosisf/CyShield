import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_app/bloc/pair/pairing_screen_cubit.dart';
import 'package:kids_app/bloc/pair/pairing_screen_state.dart';
import 'package:kids_app/presentation/widgets/custom_appbar.dart';
import 'package:kids_app/presentation/widgets/pairing_form.dart';

import '../../core/app_theme.dart';
import '../widgets/pairing_failure_dialog.dart';
import '../widgets/pairing_dialog.dart';
import '../widgets/pairing_succes_dialog.dart';

class PairingScreen extends StatefulWidget {
  const PairingScreen({super.key});

  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen> {
  bool _isDialogShowing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Cyshield'),
      body: SafeArea(
        child: BlocConsumer<PairingScreenCubit, PairingScreenState>(
          listenWhen: (prev, curr) {

            return prev.status != curr.status &&
                (curr.status == PairingScreenStatus.failure ||
                    curr.status == PairingScreenStatus.pairingSuccess ||
                    curr.status == PairingScreenStatus.pairingFailure ||
                    curr.status == PairingScreenStatus.pairingRejected ||
                    curr.status == PairingScreenStatus.pairingTimeout ||
                    curr.status == PairingScreenStatus.pairingPending);
          },
          listener: (context, state) {

            if (_isDialogShowing && Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
              _isDialogShowing = false;
            }

            switch (state.status) {
              case PairingScreenStatus.failure:
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.errorMessage ?? 'Error loading pairing screen',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                break;

              case PairingScreenStatus.pairingSuccess:
                _isDialogShowing = true;
                PairingSuccessDialog.show(
                  context,
                  message: state.successMessage ?? 'Successfully paired with guardian!',
                  onContinue: () {
                    Navigator.of(context).pop();
                    _isDialogShowing = false;
                  },
                );
                break;

              case PairingScreenStatus.pairingFailure:
                _isDialogShowing = true;
                PairingFailureDialog.show(
                  context,
                  errorMessage: state.errorMessage ?? 'Failed to send pairing request',
                  onCancel: () {
                    Navigator.of(context).pop();
                    _isDialogShowing = false;
                  },
                  onRetry: () {
                    Navigator.of(context).pop();
                    _isDialogShowing = false;
                    context.read<PairingScreenCubit>().retryPairing();
                  },
                );
                break;

              case PairingScreenStatus.pairingPending:
                _isDialogShowing = true;
                PairingPendingDialog.show(
                  context,
                  message: 'Your guardian will receive a notification to accept the pairing request.',
                ).then((_) {
                  _isDialogShowing = false;
                });
                break;

              case PairingScreenStatus.pairingRejected:
                _isDialogShowing = true;
                PairingFailureDialog.show(
                  context,
                  errorMessage: 'Guardian rejected the pairing request',
                  onCancel: () {
                    Navigator.of(context).pop();
                    _isDialogShowing = false;
                  },
                  onRetry: () {
                    Navigator.of(context).pop();
                    _isDialogShowing = false;
                    context.read<PairingScreenCubit>().resetPairingStatus();
                  },
                );
                break;

              case PairingScreenStatus.pairingTimeout:
                _isDialogShowing = true;
                PairingFailureDialog.show(
                  context,
                  errorMessage: 'Pairing request timed out. Guardian didn\'t respond.',
                  onCancel: () {
                    Navigator.of(context).pop();
                    _isDialogShowing = false;
                  },
                  onRetry: () {
                    Navigator.of(context).pop();
                    _isDialogShowing = false;
                    context.read<PairingScreenCubit>().retryPairing();
                  },
                );
                break;

              default:
                break;
            }
          },
          builder: (context, state) {
            switch (state.status) {
              case PairingScreenStatus.loading:
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                );

              case PairingScreenStatus.failure:
                return Center(
                  child: Text(
                    state.errorMessage ?? 'Error loading Pairing screen',
                    style: const TextStyle(color: Colors.red),
                  ),
                );

              case PairingScreenStatus.success:
                final firstName = state.profile!.firstName;
                return _Body(firstName: firstName, isFormEnabled: !_isDialogShowing);

              case PairingScreenStatus.pairingInProgress:
                final firstName = state.profile?.firstName ?? '';
                return _Body(
                  firstName: firstName,
                  showLoading: true,
                  loadingMessage: 'Sending pairing request...',
                  isFormEnabled: false,
                );

              case PairingScreenStatus.pairingPending:
                final firstName = state.profile?.firstName ?? '';
                return _Body(
                  firstName: firstName,
                  showLoading: true,
                  loadingMessage: 'Waiting for guardian to accept...',
                  showCancelOption: true,
                  isFormEnabled: false,
                );

              case PairingScreenStatus.pairingSuccess:
              case PairingScreenStatus.pairingFailure:
              case PairingScreenStatus.pairingRejected:
              case PairingScreenStatus.pairingTimeout:
              // Keep showing the form while dialogs are displayed
                final firstName = state.profile?.firstName ?? '';
                return _Body(firstName: firstName, isFormEnabled: !_isDialogShowing);
            }
          },
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final String firstName;
  final bool showLoading;
  final String? loadingMessage;
  final bool showCancelOption;
  final bool isFormEnabled;

  const _Body({
    required this.firstName,
    this.showLoading = false,
    this.loadingMessage,
    this.showCancelOption = false,
    this.isFormEnabled = true,
  });

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
            const SizedBox(height: 24),
            Image.asset(
              'assets/cyshield_logo.png',
              width: 300,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 66),
            IgnorePointer(
              ignoring: !isFormEnabled,
              child: Opacity(
                opacity: isFormEnabled ? 1.0 : 0.6,
                child: PairingForm(
                  onSubmit: (parentId, network) {
                    context.read<PairingScreenCubit>().connectToGuardian(
                      parentId: parentId,
                      networkType: network,
                    );
                  },
                  isLoading: showLoading,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}