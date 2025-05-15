import 'dart:async';

import 'package:guardians_app/data/models/kid_profile.dart';
import 'package:rxdart/rxdart.dart';

import '../../data/repositories/user_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/kid_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'family_state.dart';

class FamilyCubit extends Cubit<FamilyState> {
  final UserRepository _userRepository;
  final KidRepository _kidRepository;
  StreamSubscription<List<KidProfile>>? _subscription;

  FamilyCubit(this._userRepository, this._kidRepository)
    : super(const FamilyState.loading()) {
    _subscription = _userRepository
        .watchCurrentUser()
        .map((user) => user.kids ?? <String>[])
        .switchMap(
          (kidId) =>
              kidId.isEmpty
                  ? Stream.value(<KidProfile>[])
                  : _kidRepository.watchKid(kidId),
        )
        .listen(
          (kidsList) => emit(FamilyState.success(kidsList)),
          onError: (e) => emit(FamilyState.failure(e.toString())),
        );
  }

  Future<void> removeKid(String kidId) => _userRepository.removeKid(kidId);

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
