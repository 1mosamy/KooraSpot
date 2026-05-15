import '../../../courts/domain/entities/court.dart';

/// Court repository interface.
abstract class CourtRepository {
  Future<List<Court>> getNearbyStadiums({String? city, String? query});
  Future<Court> getCourtById(String id);
}
