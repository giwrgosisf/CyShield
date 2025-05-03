import 'package:equatable/equatable.dart';
import '../../data/models/user_profile.dart';

enum HomeStatus { loading, success, failure }

class HomeState extends Equatable {
  final HomeStatus status;
  final UserProfile? profile;
  final String? errorMessage;
  final int selectedTab;

  const HomeState({
    this.status = HomeStatus.loading,
    this.profile,
    this.errorMessage,
    this.selectedTab = 0,
  });

  const HomeState.loading() : this(status: HomeStatus.loading);

  const HomeState.success({required UserProfile profile, int selectedTab = 0})
    : this(
        status: HomeStatus.success,
        profile: profile,
        selectedTab: selectedTab,
      );

  const HomeState.failure(String error)
    : this(status: HomeStatus.failure, errorMessage: error);

  HomeState copyWith({int? selectedTab}) => HomeState(
    status: status,
    profile: profile,
    errorMessage: errorMessage,
    selectedTab: selectedTab ?? this.selectedTab,
  );

  @override
  List<Object?> get props => [status, profile, errorMessage, selectedTab];
}
