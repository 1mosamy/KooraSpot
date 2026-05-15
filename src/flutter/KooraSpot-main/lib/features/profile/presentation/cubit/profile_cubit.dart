import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/storage/user_storage.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/repositories/profile_repository.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _profileRepository;
  final UserStorage _userStorage;

  ProfileCubit({
    required ProfileRepository profileRepository,
    required UserStorage userStorage,
  })  : _profileRepository = profileRepository,
        _userStorage = userStorage,
        super(const ProfileInitial());

  void reset() {
    emit(const ProfileInitial());
  }

  void loadCachedProfile() {
    final user = User(
      id: _userStorage.userId,
      name: _userStorage.fullName ?? '', // 'name' in the entity
      email: _userStorage.email ?? '',
      role: _userStorage.role ?? 'Player',
      city: _userStorage.city ?? '',
      phonenumber: _userStorage.phonenumber,
      profileImageUrl: _userStorage.profileImage,
      firstLetter: _userStorage.firstLetter,
    );
    emit(ProfileLoaded(user: user));
  }

  Future<void> fetchProfile() async {
    emit(const ProfileLoading());
    try {
      final user = await _profileRepository.getProfile();
      await _userStorage.saveUserData(
        role: user.role,
        id: user.id,
        fullName: user.name, // The user entity uses 'name'
        email: user.email,
        city: user.city,
        phonenumber: user.phonenumber,
        profileImage: user.profileImageUrl,
        firstLetter: user.firstLetter,
      );
      emit(ProfileLoaded(user: user));
    } catch (e) {
      // Fall back to cached data
      loadCachedProfile();
    }
  }

  Future<void> updateProfile({
    required String fullName,
    required String city,
    String? phonenumber,
  }) async {
    emit(const ProfileUpdating());
    try {
      // 1. Update local cache immediately so the UI always reflects the new values,
      //    even if the server request fails.
      await _userStorage.saveUserData(
        role: _userStorage.role ?? 'Player',
        fullName: fullName,
        city: city,
        phonenumber: phonenumber,
        firstLetter: fullName.isNotEmpty ? fullName[0].toUpperCase() : _userStorage.firstLetter,
      );

      // 2. Emit the updated profile from cache right away.
      loadCachedProfile();

      // 3. Try to persist on the server (best-effort — don't block on failure).
      try {
        await _profileRepository.updateProfile(
          fullName: fullName,
          city: city,
          phonenumber: phonenumber,
        );
      } catch (e) {
        // ignore: avoid_print
        print('[ProfileCubit] Server update failed (non-critical): $e');
      }
    } catch (e) {
      emit(ProfileFailure(
        message: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> uploadImage(String filePath) async {
    emit(const ProfileImageUploading());
    try {
      final imageUrl = await _profileRepository.uploadProfileImage(filePath);
      if (imageUrl.isNotEmpty) {
        await _userStorage.saveUserData(
          role: _userStorage.role ?? 'Player',
          profileImage: imageUrl,
        );
      }
      // Load from cache to show the new image
      loadCachedProfile();
    } catch (e) {
      emit(ProfileFailure(
        message: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }
}
