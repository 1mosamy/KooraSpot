import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/storage/user_storage.dart';
import '../../../courts/domain/entities/court.dart';
import '../../../courts/domain/repositories/court_repository.dart';

part 'player_home_state.dart';

class PlayerHomeCubit extends Cubit<PlayerHomeState> {
  final CourtRepository _courtRepository;
  final UserStorage _userStorage;

  PlayerHomeCubit({
    required CourtRepository courtRepository,
    required UserStorage userStorage,
  })  : _courtRepository = courtRepository,
        _userStorage = userStorage,
        super(const PlayerHomeInitial());

  String get userName => _userStorage.fullName ?? 'Player';
  String get userCity => _userStorage.city ?? 'Cairo';
  String? get userAvatar {
    final raw = _userStorage.profileImage;
    if (raw == null || raw.isEmpty) return null;
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    if (raw.startsWith('/')) return 'http://kooraspot.somee.com$raw';
    return 'http://kooraspot.somee.com/$raw';
  }

  Future<void> loadStadiums() async {
    emit(const PlayerHomeLoading());
    try {
      final courts = await _courtRepository.getNearbyStadiums(city: userCity);
      emit(PlayerHomeLoaded(courts: courts));
    } catch (e) {
      emit(PlayerHomeFailure(message: e.toString()));
    }
  }

  Future<void> searchStadiums(String query) async {
    try {
      final courts = await _courtRepository.getNearbyStadiums(query: query);
      emit(PlayerHomeLoaded(courts: courts));
    } catch (e) {
      emit(PlayerHomeFailure(message: e.toString()));
    }
  }
}
