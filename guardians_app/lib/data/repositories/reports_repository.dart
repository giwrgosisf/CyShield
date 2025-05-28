import '../models/kid_profile.dart';
import 'kid_repository.dart';


class ReportsRepository {
  final KidRepository _kidRepo;

  ReportsRepository(this._kidRepo);

  /// Streams profiles with their flaggedMessages already loaded
  Stream<List<KidProfile>> watchFlaggedReports(List<String> kidIds) {
    return _kidRepo.watchKidsWithFlags(kidIds);
  }
}