import 'dart:async';
import 'dart:ffi';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_app/bloc/pair/pairing_screen_state.dart';
import 'package:kids_app/core/services/backend_services.dart';
import '../../core/services/pairing_service.dart';
import '../../data/models/kid_profile.dart';
import '../../data/repositories/kid_repository.dart';

class PairingScreenCubit extends Cubit<PairingScreenState>{
  final KidRepository _kidRepository;
  final PairingService _pairingService;
  StreamSubscription<KidProfile>? _sub;
  StreamSubscription<String>? _pairingStatusSub;
  KidProfile? _currentProfile;
  final BackendServices server = BackendServices(baseUrl:'http://192.168.1.88');

  PairingScreenCubit(
      this._kidRepository,
      this._pairingService,
      ) : super(const PairingScreenState.loading()) {
    _initializeUser();
  }

  void _initializeUser() {
    _sub = _kidRepository.watchCurrentUser().listen(
          (profile) {
        _currentProfile = profile;
        emit(PairingScreenState.success(profile: profile));
      },
      onError: (e) {
        emit(PairingScreenState.failure(e.toString()));
      },
    );
  }

 Future<bool> hasAlreadyInitializedTelegram(){
    return server.getTelegramState();
 }

 Future<bool> hasAlreadyInitializedSignal(){
    return server.getSignalState();
 }



  Future<void> connectToGuardian({
    required String parentId,
    required String networkType,
  }) async {

    if (parentId.isEmpty) {
      emit(PairingScreenState.pairingFailure(
        profile: _currentProfile,
        error: 'Parent ID cannot be empty',
        parentId: parentId,
        networkType: networkType,
      ));
      return;
    }


    _pairingStatusSub?.cancel();

    emit(PairingScreenState.pairingInProgress(
      profile: _currentProfile,
      parentId: parentId,
      networkType: networkType,
    ));

    try {

      if (! await _pairingService.hasThisParentAlready(parentId: parentId)) {
        await _sendPairingRequest(parentId, networkType);
        await _waitForGuardianResponse(parentId, networkType);
      }else{
        emit(PairingScreenState.pairingSuccess(
          profile: _currentProfile!,
          message: 'Successfully connected to guardian!',
        ));

      }


    } on TimeoutException {
      emit(PairingScreenState.pairingTimeout(
        profile: _currentProfile,
        parentId: parentId,
        networkType: networkType,
      ));
    } on FormatException catch (e) {
      emit(PairingScreenState.pairingFailure(
        profile: _currentProfile,
        error: 'Invalid parent ID format: ${e.message}',
        parentId: parentId,
        networkType: networkType,
      ));
    } catch (e) {
      emit(PairingScreenState.pairingFailure(
        profile: _currentProfile,
        error: 'Connection failed: ${e.toString()}',
        parentId: parentId,
        networkType: networkType,
      ));
    }
  }

  Future<void> _sendPairingRequest(String parentId, String networkType) async {

    final guardianExists = await _pairingService.doesGuardianExist(parentId);
    if (!guardianExists) {
      throw FormatException('Guardian with ID $parentId not found');
    }


    await _pairingService.sendPairingRequest(
      parentId: parentId,
      kidProfile: _currentProfile!,
    );

    await _pairingService.notifyParentOfPairing(
        parentID: parentId,
        kidName: _currentProfile!.firstName
    );
  }



  Future<void> _waitForGuardianResponse(String parentId, String networkType) async {

    emit(PairingScreenState.pairingPending(
      profile: _currentProfile,
      parentId: parentId,
      networkType: networkType,
    ));


    final completer = Completer<void>();


    const timeout = Duration(minutes: 5);
    Timer? timeoutTimer;


    _pairingStatusSub = _pairingService.watchPairingRequestStatus(
      parentId: parentId,
      kidId: _currentProfile!.uid,
    ).listen((status) {
      switch (status) {
        case 'accepted':
          timeoutTimer?.cancel();
          _pairingStatusSub?.cancel();
          if (!completer.isCompleted) {
            emit(PairingScreenState.pairingSuccess(
              profile: _currentProfile!,
              message: 'Successfully connected to guardian!',
            ));
            completer.complete();
          }
          break;

        case 'rejected':
          timeoutTimer?.cancel();
          _pairingStatusSub?.cancel();
          if (!completer.isCompleted) {
            emit(PairingScreenState.pairingRejected(
              profile: _currentProfile,
              parentId: parentId,
              networkType: networkType,
            ));
            completer.completeError(Exception('Guardian rejected the pairing request'));
          }
          break;

        case 'pending':

          break;
      }
    }, onError: (error) {
      timeoutTimer?.cancel();
      _pairingStatusSub?.cancel();
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
    });


    timeoutTimer = Timer(timeout, () {
      _pairingStatusSub?.cancel();
      if (!completer.isCompleted) {
        completer.completeError(TimeoutException('Request timed out', timeout));
      }
    });


    return completer.future;
  }


  void resetPairingStatus() {
    _pairingStatusSub?.cancel();
    emit(PairingScreenState.success(profile: _currentProfile!));
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    _pairingStatusSub?.cancel();
    return super.close();
  }
}