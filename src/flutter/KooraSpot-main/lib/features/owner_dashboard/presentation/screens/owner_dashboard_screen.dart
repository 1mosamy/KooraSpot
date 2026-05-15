import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../owner_fields/presentation/cubit/owner_fields_cubit.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OwnerFieldsCubit>().loadFields();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: BlocBuilder<OwnerFieldsCubit, OwnerFieldsState>(
          builder: (context, state) {
            if (state is OwnerFieldsLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }
            if (state is OwnerFieldsLoaded) {
              return CustomScrollView(
                slivers: [
                  // Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      child: Text('Dashboard', style: GoogleFonts.lexend(fontSize: 28, fontWeight: FontWeight.w700)),
                    ),
                  ),

                  // Stat cards
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          _StatCard(icon: Icons.calendar_today, label: 'Today Booking', value: '${state.stats.todayBookings}', color: AppColors.primary),
                          const SizedBox(width: 12),
                          _StatCard(icon: Icons.trending_up, label: 'Total Earned', value: state.stats.formattedRevenue, color: Colors.blue),
                          const SizedBox(width: 12),
                          _StatCard(icon: Icons.stadium, label: 'Courts', value: '${state.stats.courtsCount}', color: Colors.orange),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // Your Fields header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text('Your Fields', style: GoogleFonts.lexend(fontSize: 20, fontWeight: FontWeight.w700)),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 12)),

                  // Fields list
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList.separated(
                      itemCount: state.fields.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final field = state.fields[i];
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: AppRadius.lgAll,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                                child: field.imageUrl.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: field.imageUrl,
                                        width: 100, height: 85, fit: BoxFit.cover,
                                        placeholder: (_, __) => Container(width: 100, height: 85, color: AppColors.shimmerBase),
                                        errorWidget: (_, __, ___) => Container(
                                          width: 100, height: 85, color: AppColors.shimmerBase,
                                          child: const Icon(Icons.stadium_outlined, color: AppColors.textHint),
                                        ),
                                      )
                                    : Container(
                                        width: 100, height: 85, color: AppColors.shimmerBase,
                                        child: const Icon(Icons.stadium_outlined, color: AppColors.textHint),
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(field.name, style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w700)),
                                      const SizedBox(height: 2),
                                      Text(field.location.isNotEmpty ? field.location : field.city, style: GoogleFonts.lexend(fontSize: 12, color: AppColors.textSecondary)),
                                      const SizedBox(height: 4),
                                      Text('${field.pricePerHour.toInt()} ${field.currency}/hr', style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: field.isActive ? AppColors.successLight : AppColors.warningLight,
                                    borderRadius: AppRadius.fullAll,
                                  ),
                                  child: Text(
                                    field.isActive ? 'Active' : 'Inactive',
                                    style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w600, color: field.isActive ? AppColors.primary : AppColors.warning),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              );
            }
            if (state is OwnerFieldsFailure) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppColors.textHint),
                    const SizedBox(height: 12),
                    Text('Failed to load dashboard', style: GoogleFonts.lexend(fontSize: 16, color: AppColors.textSecondary)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context.read<OwnerFieldsCubit>().loadFields(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.lgAll,
          border: Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: AppRadius.smAll),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 10),
            Text(value, style: GoogleFonts.lexend(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(label, style: GoogleFonts.lexend(fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
