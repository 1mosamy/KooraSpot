part of 'player_home_cubit.dart';

sealed class PlayerHomeState extends Equatable {
  const PlayerHomeState();
  @override
  List<Object?> get props => [];
}

class PlayerHomeInitial extends PlayerHomeState {
  const PlayerHomeInitial();
}

class PlayerHomeLoading extends PlayerHomeState {
  const PlayerHomeLoading();
}

class PlayerHomeLoaded extends PlayerHomeState {
  final List<Court> courts;
  const PlayerHomeLoaded({required this.courts});
  @override
  List<Object?> get props => [courts];
}

class PlayerHomeFailure extends PlayerHomeState {
  final String message;
  const PlayerHomeFailure({required this.message});
  @override
  List<Object?> get props => [message];
}
