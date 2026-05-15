import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/constants/app_strings.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/domain/entities/user.dart';
import '../cubit/profile_cubit.dart';

class PlayerEditProfileScreen extends StatefulWidget {
  const PlayerEditProfileScreen({super.key});

  @override
  State<PlayerEditProfileScreen> createState() => _PlayerEditProfileScreenState();
}

class _PlayerEditProfileScreenState extends State<PlayerEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedCity;
  String? _profileImageUrl;
  bool _initialized = false;
  bool _isSaving = false; // true only while waiting for updateProfile to finish
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Always ensure the cubit has fresh cached data before the form reads it.
    // loadCachedProfile() is synchronous — it emits ProfileLoaded immediately.
    context.read<ProfileCubit>().loadCachedProfile();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final state = context.read<ProfileCubit>().state;
      User? user;
      if (state is ProfileLoaded) {
        user = state.user;
      }

      if (user != null) {
        _fullNameController.text = user.name;
        _phoneController.text = user.phonenumber ?? '';
        _selectedCity = user.city?.isNotEmpty == true ? user.city : null;
        _profileImageUrl = user.normalizedProfileImageUrl;
        _initialized = true; // only lock once we actually got data
      }
      // if user is null (cubit not ready yet), leave _initialized = false
      // so didChangeDependencies retries on next rebuild
    }
  }

  Future<void> _pickAndUploadImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (mounted) {
        context.read<ProfileCubit>().uploadImage(image.path);
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      _isSaving = true;
      context.read<ProfileCubit>().updateProfile(
            fullName: _fullNameController.text.trim(),
            city: _selectedCity ?? '',
            phonenumber: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        // Only pop when WE triggered the save (not on initial cache load or image upload)
        if (state is ProfileLoaded && _isSaving) {
          _isSaving = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully'), backgroundColor: AppColors.primary),
          );
          Navigator.pop(context);
        } else if (state is ProfileFailure) {
          _isSaving = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(title: Text('Edit Profile', style: GoogleFonts.lexend(fontSize: 20, fontWeight: FontWeight.w700))),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, state) {
                  bool isUploading = false;
                  if (state is ProfileLoaded) {
                    _profileImageUrl = state.user.normalizedProfileImageUrl;
                  } else if (state is ProfileImageUploading) {
                    isUploading = true;
                  }

                  return Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          backgroundImage: _profileImageUrl != null
                              ? CachedNetworkImageProvider(_profileImageUrl!)
                              : null,
                          child: _profileImageUrl == null
                              ? Text(
                                  _fullNameController.text.isNotEmpty ? _fullNameController.text[0].toUpperCase() : 'U',
                                  style: GoogleFonts.lexend(fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.primary),
                                )
                              : null,
                        ),
                        if (isUploading)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withValues(alpha: 0.3),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(color: Colors.white),
                              ),
                            ),
                          ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: isUploading ? null : _pickAndUploadImage,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              Text('FULL NAME', style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant, letterSpacing: 0.96)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _fullNameController,
                validator: (v) => Validators.required(v, 'Full name'),
                decoration: InputDecoration(hintText: 'Enter your full name', prefixIcon: const Icon(Icons.person_outline, size: 20, color: AppColors.textHint)),
              ),
              const SizedBox(height: 20),
              Text('PHONE NUMBER', style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant, letterSpacing: 0.96)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: Validators.egyptianPhone,
                decoration: InputDecoration(hintText: 'Enter your phone number (e.g. 01012345678)', prefixIcon: const Icon(Icons.phone_outlined, size: 20, color: AppColors.textHint)),
              ),
              const SizedBox(height: 20),
              Text('CITY', style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant, letterSpacing: 0.96)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedCity,
                validator: Validators.city,
                decoration: InputDecoration(hintText: 'Select city', prefixIcon: const Icon(Icons.location_on_outlined, size: 20, color: AppColors.textHint)),
                items: AppStrings.cities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _selectedCity = v),
              ),
              const SizedBox(height: 32),
              BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, state) {
                  final isLoading = state is ProfileUpdating || state is ProfileImageUploading;
                  return ElevatedButton(
                    onPressed: isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52), shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll)),
                    child: isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text('Save Changes', style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w700)),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
