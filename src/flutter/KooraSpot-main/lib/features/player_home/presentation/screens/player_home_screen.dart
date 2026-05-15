import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../courts/domain/entities/court.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../cubit/player_home_cubit.dart';

class PlayerHomeScreen extends StatefulWidget {
  const PlayerHomeScreen({super.key});

  @override
  State<PlayerHomeScreen> createState() => _PlayerHomeScreenState();
}

class _PlayerHomeScreenState extends State<PlayerHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Reload user profile from cache so the header shows the correct
    // name, city and avatar immediately after login/register.
    context.read<ProfileCubit>().loadCachedProfile();
    context.read<PlayerHomeCubit>().loadStadiums();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PlayerHomeCubit>();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // Sticky Header — reacts to ProfileCubit changes
          SliverToBoxAdapter(
            child: BlocConsumer<ProfileCubit, ProfileState>(
              listenWhen: (prev, curr) {
                // Only reload stadiums when the city actually changes
                if (curr is ProfileLoaded) {
                  final prevCity = prev is ProfileLoaded ? prev.user.city : null;
                  return prevCity != curr.user.city;
                }
                return false;
              },
              listener: (context, state) {
                cubit.loadStadiums();
              },
              builder: (context, profileState) {
                String userName = 'Player';
                String userCity = 'Cairo';
                String? userAvatar;

                if (profileState is ProfileLoaded) {
                  userName = profileState.user.name.isNotEmpty
                      ? profileState.user.name
                      : userName;
                  userCity = profileState.user.city?.isNotEmpty == true
                      ? profileState.user.city!
                      : userCity;
                  userAvatar = profileState.user.normalizedProfileImageUrl;
                } else {
                  // Fallback to storage values while cubit loads
                  userName = cubit.userName;
                  userCity = cubit.userCity;
                  userAvatar = cubit.userAvatar;
                }

                return Container(
                  color: Colors.white,
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        // Top row
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome back,',
                                      style: GoogleFonts.lexend(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      userName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.lexend(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.backgroundLight,
                                      borderRadius: AppRadius.fullAll,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          size: 16,
                                          color: AppColors.primary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$userCity, Egypt',
                                          style: GoogleFonts.lexend(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.onSurface,
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        const Icon(
                                          Icons.expand_more,
                                          size: 16,
                                          color: AppColors.textHint,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor:
                                        AppColors.surfaceContainerHigh,
                                    child: userAvatar != null
                                        ? ClipOval(
                                            child: CachedNetworkImage(
                                              imageUrl: userAvatar,
                                              fit: BoxFit.cover,
                                              width: 40,
                                              height: 40,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.person,
                                            color: AppColors.textSecondary,
                                          ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Search
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                          child: TextField(
                            onChanged: (q) => cubit.searchStadiums(q),
                            decoration: InputDecoration(
                              hintText: 'Search for stadiums...',
                              prefixIcon: const Icon(
                                Icons.search,
                                color: AppColors.textHint,
                              ),
                              filled: true,
                              fillColor: AppColors.backgroundLight,
                              border: OutlineInputBorder(
                                borderRadius: AppRadius.mdAll,
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                        const Divider(height: 1, color: AppColors.border),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Nearby Stadiums header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nearby Stadiums',
                    style: GoogleFonts.lexend(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'See All',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Court cards
          BlocBuilder<PlayerHomeCubit, PlayerHomeState>(
            builder: (context, state) {
              if (state is PlayerHomeLoading) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }
              if (state is PlayerHomeLoaded) {
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList.separated(
                    itemCount: state.courts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _CourtCard(court: state.courts[index]);
                    },
                  ),
                );
              }
              if (state is PlayerHomeFailure) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: AppColors.textHint),
                        const SizedBox(height: 12),
                        Text('Failed to load stadiums', style: GoogleFonts.lexend(fontSize: 16, color: AppColors.textSecondary)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => cubit.loadStadiums(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SliverToBoxAdapter(child: SizedBox());
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _CourtCard extends StatelessWidget {
  final Court court;
  const _CourtCard({required this.court});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/stadiums/${court.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.lgAll,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: court.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: court.imageUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(height: 180, color: AppColors.shimmerBase),
                      errorWidget: (_, __, ___) => Container(
                        height: 180,
                        color: AppColors.shimmerBase,
                        child: const Icon(Icons.stadium, size: 48, color: AppColors.textHint),
                      ),
                    )
                  : Container(
                      height: 180,
                      color: AppColors.shimmerBase,
                      child: const Center(child: Icon(Icons.stadium_outlined, size: 48, color: AppColors.textHint)),
                    ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              court.name,
                              style: GoogleFonts.lexend(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    court.location.isNotEmpty ? court.location : court.city,
                                    style: GoogleFonts.lexend(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${court.pricePerHour.toInt()}',
                            style: GoogleFonts.lexend(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          Text(
                            '${court.currency}/HR',
                            style: GoogleFonts.lexend(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.divider,
                        style: BorderStyle.solid,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () => context.push('/stadiums/${court.id}'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(100, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.mdAll,
                        ),
                      ),
                      child: Text(
                        'Details',
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
