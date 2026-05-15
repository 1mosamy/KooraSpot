import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../courts/domain/entities/court.dart';
import '../../data/repositories/favorites_repository.dart';

part 'saved_courts_state.dart';

/// Manages favorites using the real Favorites API.
class SavedCourtsCubit extends Cubit<SavedCourtsState> {
  final FavoritesRepository _favoritesRepository;

  /// In-memory set of favorite field IDs for quick lookup.
  final Set<int> _favoriteIds = {};

  SavedCourtsCubit({required FavoritesRepository favoritesRepository})
      : _favoritesRepository = favoritesRepository,
        super(const SavedCourtsInitial());

  /// Whether a field is currently in favorites.
  bool isFavorite(int fieldId) => _favoriteIds.contains(fieldId);

  Future<void> loadFavorites() async {
    emit(const SavedCourtsLoading());
    try {
      final courts = await _favoritesRepository.getMyFavorites();
      _favoriteIds
        ..clear()
        ..addAll(courts.map((c) => int.tryParse(c.id) ?? 0));
      emit(SavedCourtsLoaded(courts: courts));
    } catch (e) {
      emit(SavedCourtsFailure(
          message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  /// Toggle favorite: add if not saved, remove if saved.
  Future<void> toggleFavorite(int fieldId) async {
    try {
      if (_favoriteIds.contains(fieldId)) {
        _favoriteIds.remove(fieldId);
        await _favoritesRepository.removeFromFavorites(fieldId);
      } else {
        _favoriteIds.add(fieldId);
        await _favoritesRepository.addToFavorites(fieldId);
      }
      // Reload full list to get consistent data
      await loadFavorites();
    } catch (e) {
      emit(SavedCourtsFailure(
          message: e.toString().replaceFirst('Exception: ', '')));
      // Reload to resync state
      await loadFavorites();
    }
  }
}
