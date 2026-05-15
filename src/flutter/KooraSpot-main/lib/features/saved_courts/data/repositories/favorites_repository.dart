import '../../../courts/domain/entities/court.dart';

/// Favorites repository interface (Player role).
abstract class FavoritesRepository {
  /// Add a field to favorites.
  Future<void> addToFavorites(int fieldId);

  /// Get all favorite fields.
  Future<List<Court>> getMyFavorites();

  /// Remove a field from favorites.
  Future<void> removeFromFavorites(int fieldId);
}
