import 'package:equatable/equatable.dart';
import 'package:kids_app/data/models/kid_profile.dart';

enum PairingScreenStatus {
  loading,
  success,
  failure,
  pairingInProgress,
  pairingPending,      // New: Waiting for guardian response
  pairingSuccess,
  pairingFailure,
  pairingRejected,
  pairingTimeout       // New: Request timed out
}

class PairingScreenState extends Equatable {
  final PairingScreenStatus status;
  final KidProfile? profile;
  final String? errorMessage;
  final String? successMessage;
  final String? lastParentId;
  final String? lastNetworkType;

  const PairingScreenState({
    this.status = PairingScreenStatus.loading,
    this.profile,
    this.errorMessage,
    this.successMessage,
    this.lastParentId,
    this.lastNetworkType,
  });

  const PairingScreenState.loading() : this(status: PairingScreenStatus.loading);

  const PairingScreenState.success({required KidProfile profile})
      : this(
    status: PairingScreenStatus.success,
    profile: profile,
  );

  const PairingScreenState.failure(String error)
      : this(status: PairingScreenStatus.failure, errorMessage: error);

  const PairingScreenState.pairingInProgress({
    KidProfile? profile,
    String? parentId,
    String? networkType,
  }) : this(
    status: PairingScreenStatus.pairingInProgress,
    profile: profile,
    lastParentId: parentId,
    lastNetworkType: networkType,
  );

  const PairingScreenState.pairingPending({
    KidProfile? profile,
    String? parentId,
    String? networkType,
  }) : this(
    status: PairingScreenStatus.pairingPending,
    profile: profile,
    lastParentId: parentId,
    lastNetworkType: networkType,
  );

  const PairingScreenState.pairingSuccess({
    required KidProfile profile,
    String? message,
  }) : this(
    status: PairingScreenStatus.pairingSuccess,
    profile: profile,
    successMessage: message,
  );

  const PairingScreenState.pairingFailure({
    KidProfile? profile,
    required String error,
    String? parentId,
    String? networkType,
  }) : this(
    status: PairingScreenStatus.pairingFailure,
    profile: profile,
    errorMessage: error,
    lastParentId: parentId,
    lastNetworkType: networkType,
  );

  const PairingScreenState.pairingRejected({
    KidProfile? profile,
    String? parentId,
    String? networkType,
  }) : this(
    status: PairingScreenStatus.pairingRejected,
    profile: profile,
    errorMessage: 'Guardian rejected the pairing request',
    lastParentId: parentId,
    lastNetworkType: networkType,
  );

  const PairingScreenState.pairingTimeout({
    KidProfile? profile,
    String? parentId,
    String? networkType,
  }) : this(
    status: PairingScreenStatus.pairingTimeout,
    profile: profile,
    errorMessage: 'Pairing request timed out',
    lastParentId: parentId,
    lastNetworkType: networkType,
  );

  // Add copyWith method for easier state updates
  PairingScreenState copyWith({
    PairingScreenStatus? status,
    KidProfile? profile,
    String? errorMessage,
    String? successMessage,
    String? lastParentId,
    String? lastNetworkType,
  }) {
    return PairingScreenState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      lastParentId: lastParentId ?? this.lastParentId,
      lastNetworkType: lastNetworkType ?? this.lastNetworkType,
    );
  }

  @override
  List<Object?> get props => [
    status,
    profile,
    errorMessage,
    successMessage,
    lastParentId,
    lastNetworkType,
  ];
}