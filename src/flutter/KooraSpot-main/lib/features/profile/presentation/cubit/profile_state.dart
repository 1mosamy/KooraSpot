part of 'profile_cubit.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final User user;
  const ProfileLoaded({required this.user});
  @override
  List<Object?> get props => [user];
}

class ProfileUpdating extends ProfileState {
  const ProfileUpdating();
}

class ProfileImageUploading extends ProfileState {
  const ProfileImageUploading();
}

class ProfileFailure extends ProfileState {
  final String message;
  const ProfileFailure({required this.message});
  @override
  List<Object?> get props => [message];
}
