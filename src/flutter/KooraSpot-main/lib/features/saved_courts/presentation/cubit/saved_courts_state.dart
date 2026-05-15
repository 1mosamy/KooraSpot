part of 'saved_courts_cubit.dart';

sealed class SavedCourtsState extends Equatable {
  const SavedCourtsState();
  @override
  List<Object?> get props => [];
}

class SavedCourtsInitial extends SavedCourtsState {
  const SavedCourtsInitial();
}

class SavedCourtsLoading extends SavedCourtsState {
  const SavedCourtsLoading();
}

class SavedCourtsLoaded extends SavedCourtsState {
  final List<Court> courts;
  const SavedCourtsLoaded({required this.courts});
  @override
  List<Object?> get props => [courts];
}

class SavedCourtsFailure extends SavedCourtsState {
  final String message;
  const SavedCourtsFailure({required this.message});
  @override
  List<Object?> get props => [message];
}
