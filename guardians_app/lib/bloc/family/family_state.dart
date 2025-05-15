import 'package:equatable/equatable.dart';
import '../../data/models/kid_profile.dart';

enum FamilyStatus {loading, success, failure}

class FamilyState extends Equatable{
  final FamilyStatus status;
  final String? error;
  final List<KidProfile> kids;

  const FamilyState({
    required this.status,
    this.kids = const [],
    this.error
});

  const FamilyState.loading(): this(status: FamilyStatus.loading);
  const FamilyState.success(List<KidProfile> kids): this(status: FamilyStatus.success, kids: kids);
  const FamilyState.failure(String e): this(status: FamilyStatus.failure, error: e);

  @override
  List<Object?> get props => [status, kids, error];

}