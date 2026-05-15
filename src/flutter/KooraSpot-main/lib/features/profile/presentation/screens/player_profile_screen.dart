import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cached_network_image/cached_network_image.dart';

import '../../../../app/di/service_locator.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/profile_cubit.dart';

class PlayerProfileScreen extends StatefulWidget {
  const PlayerProfileScreen({super.key});

  @override
  State<PlayerProfileScreen> createState() => _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends State<PlayerProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadCachedProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: Text('Profile', style: GoogleFonts.lexend(fontSize: 20, fontWeight: FontWeight.w700))),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoaded) {
            final user = state.user;
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Avatar section
                Center(
                  child: Column(
                     children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        backgroundImage: user.normalizedProfileImageUrl != null
                            ? CachedNetworkImageProvider(user.normalizedProfileImageUrl!)
                            : null,
                        child: user.normalizedProfileImageUrl == null
                            ? Text(
                                user.displayInitial,
                                style: GoogleFonts.lexend(fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.primary),
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(user.name, style: GoogleFonts.lexend(fontSize: 22, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(user.email, style: GoogleFonts.lexend(fontSize: 14, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Info cards
                _infoCard(Icons.person_outline, 'Role', user.role),
                const SizedBox(height: 12),
                _infoCard(Icons.location_on_outlined, 'City', user.city ?? 'Not set'),
                const SizedBox(height: 12),
                _infoCard(
                  Icons.phone_outlined, 
                  'Phone Number', 
                  (user.phonenumber == null || user.phonenumber!.isEmpty) ? 'No phone number' : user.phonenumber!,
                ),
                const SizedBox(height: 32),

                // Edit profile
                OutlinedButton.icon(
                  onPressed: () {
                    if (user.isOwner) {
                      context.push('/owner/edit-profile');
                    } else {
                      context.push('/player/edit-profile');
                    }
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: Text('Edit Profile', style: GoogleFonts.lexend(fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
                    side: const BorderSide(color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 16),

                // Logout
                ElevatedButton.icon(
                  onPressed: () {
                    sl<AuthCubit>().logout();
                    context.go('/login');
                  },
                  icon: const Icon(Icons.logout),
                  label: Text('Logout', style: GoogleFonts.lexend(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
                  ),
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        },
      ),
    );
  }

  Widget _infoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: AppRadius.smAll),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.lexend(fontSize: 12, color: AppColors.textSecondary)),
                Text(value, style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
