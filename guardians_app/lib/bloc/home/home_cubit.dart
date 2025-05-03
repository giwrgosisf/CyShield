import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/user_profile.dart';
import '../../data/repositories/user_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final UserRepository _userRepo;
  StreamSubscription<UserProfile>? _sub;

  HomeCubit(this._userRepo) : super(const HomeState.loading()) {
    _sub = _userRepo.watchCurrentUser().listen(
      (profile) {
        emit(
          HomeState.success(profile: profile, selectedTab: state.selectedTab),
        );
      },
      onError: (e) {
        emit(HomeState.failure(e.toString()));
      },
    );
  }

  void selectTab(int i) => emit(state.copyWith(selectedTab: i));

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
