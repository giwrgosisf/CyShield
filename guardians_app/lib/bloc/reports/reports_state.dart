import '../../data/models/kid_profile.dart';
import 'package:equatable/equatable.dart';

abstract class ReportsState extends Equatable {
  const ReportsState();

  @override
  List<Object> get props => [];
}

class ReportsInitial extends ReportsState {
  const ReportsInitial();
}

class ReportsLoading extends ReportsState {
  const ReportsLoading();
}

class ReportsLoaded extends ReportsState {
  final List<KidProfile> kidsWithFlags;
  final bool isRefreshing;

  const ReportsLoaded({required this.kidsWithFlags, this.isRefreshing = false});

  @override
  List<Object> get props => [kidsWithFlags, isRefreshing];

  ReportsLoaded copyWith({
    List<KidProfile>? kidsWithFlags,
    bool? isRefreshing,
  }) {
    return ReportsLoaded(
      kidsWithFlags: kidsWithFlags ?? this.kidsWithFlags,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  List<KidProfile> get kidsWithFlaggedMessages =>
      kidsWithFlags.where((kid) => kid.flaggedMessages.isNotEmpty).toList();

  int get totalFlaggedMessages =>
      kidsWithFlags.fold(0, (sum, kid) => sum + kid.flaggedMessages.length);

  bool get hasAnyFlags => totalFlaggedMessages > 0;

}

class ReportsError extends ReportsState {
  final String message;

  const ReportsError(this.message);

  @override
  List<Object> get props => [message];
}