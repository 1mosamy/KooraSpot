import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../core/utils/ks_snackbar.dart';
import '../../../courts/domain/entities/court.dart';
import '../cubit/saved_courts_cubit.dart';

class SavedCourtsScreen extends StatefulWidget {
  const SavedCourtsScreen({super.key});

  @override
  State<SavedCourtsScreen> createState() => _SavedCourtsScreenState();
}

class _SavedCourtsScreenState extends State<SavedCourtsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SavedCourtsCubit>().loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Saved Courts',
          style: GoogleFonts.lexend(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: BlocConsumer<SavedCourtsCubit, SavedCourtsState>(
        listener: (context, state) {
          if (state is SavedCourtsFailure) {
            KSSnackBar.error(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is SavedCourtsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is SavedCourtsLoaded) {
            if (state.courts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No favorite fields yet',
                      style: GoogleFonts.lexend(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the heart icon on any field\nto save it here.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () =>
                  context.read<SavedCourtsCubit>().loadFavorites(),
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: state.courts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _FavoriteCourtCard(court: state.courts[index]);
                },
              ),
            );
          }

          if (state is SavedCourtsFailure) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: AppColors.textHint),
                  const SizedBox(height: 12),
                  Text(
                    'Failed to load favorites',
                    style: GoogleFonts.lexend(
                        fontSize: 16, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<SavedCourtsCubit>().loadFavorites(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}

class _FavoriteCourtCard extends StatelessWidget {
  final Court court;
  const _FavoriteCourtCard({required this.court});

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
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              child: court.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: court.imageUrl,
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        width: 110,
                        height: 110,
                        color: AppColors.shimmerBase,
                      ),
                      errorWidget: (_, __, ___) => Container(
                        width: 110,
                        height: 110,
                        color: AppColors.shimmerBase,
                        child: const Icon(Icons.stadium,
                            size: 32, color: AppColors.textHint),
                      ),
                    )
                  : Container(
                      width: 110,
                      height: 110,
                      color: AppColors.shimmerBase,
                      child: const Center(
                        child: Icon(Icons.stadium_outlined,
                            size: 32, color: AppColors.textHint),
                      ),
                    ),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      court.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            court.location.isNotEmpty
                                ? court.location
                                : court.city,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.lexend(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${court.pricePerHour.toInt()} ${court.currency}/hr',
                      style: GoogleFonts.lexend(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Remove favorite button
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red, size: 24),
                onPressed: () {
                  final fieldId = int.tryParse(court.id);
                  if (fieldId != null) {
                    context.read<SavedCourtsCubit>().toggleFavorite(fieldId);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
