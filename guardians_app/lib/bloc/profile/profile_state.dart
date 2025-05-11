import 'package:equatable/equatable.dart';
import '../../data/models/user_profile.dart';

enum ProfileStatus { loading, updating, success, failure, deleted }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final UserProfile? profile;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.loading,
    this.profile,
    this.errorMessage,
  });

  const ProfileState.loading() : this(status: ProfileStatus.loading);

  const ProfileState.success({required UserProfile profile})
    : this(status: ProfileStatus.success, profile: profile);

  const ProfileState.failure(String error)
    : this(status: ProfileStatus.failure, errorMessage: error);

  const ProfileState.deleted() : this(status: ProfileStatus.deleted);

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfile? profile,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, profile, errorMessage];
}
