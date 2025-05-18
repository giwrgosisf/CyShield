import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/user_profile.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/auth_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  StreamSubscription<UserProfile>? _sub;

  ProfileCubit(this._authRepository, this._userRepository)
    : super(const ProfileState.loading()) {
    _sub = _userRepository.watchCurrentUser().listen(
      (profile) {
        emit(ProfileState.success(profile: profile));
      },
      onError: (e) {
        emit(ProfileState.failure(e.toString()));
      },
    );
  }

  Future<void> updateName(String newFirstName) async {
    emit(state.copyWith(status: ProfileStatus.updating));
    try {
      await _userRepository.updateUsername(newFirstName);
      final refreshed = await _userRepository.fetchCurrentUser();
      emit(ProfileState.success(profile: refreshed));
    } catch (e) {
      emit(ProfileState.failure(e.toString()));
    }
  }

  Future<void> deleteProfile({String? password}) async {
    emit(state.copyWith(status: ProfileStatus.updating));
    try {
      final user = _authRepository.currentUser;
      if (password != null && user != null) {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
      }
      await _sub?.cancel();
      await _userRepository.deleteProfile();
      await _authRepository.logOut();
      emit(const ProfileState.deleted());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        emit(ProfileState.failure('requires-recent-login'));
      } else if (e.code == 'wrong-password') {
        emit(ProfileState.failure('wrong-password'));
      } else {
        emit(ProfileState.failure(e.message ?? e.toString()));
      }
    } catch (e) {
      emit(ProfileState.failure(e.toString()));
    }
  }

  Future<void> logout() async {
    await _sub?.cancel();
    await _authRepository.logOut();
    await close();
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
