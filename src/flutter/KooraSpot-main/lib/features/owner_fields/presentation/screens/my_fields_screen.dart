import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../core/utils/ks_snackbar.dart';
import '../cubit/owner_fields_cubit.dart';

class MyFieldsScreen extends StatefulWidget {
  const MyFieldsScreen({super.key});

  @override
  State<MyFieldsScreen> createState() => _MyFieldsScreenState();
}

class _MyFieldsScreenState extends State<MyFieldsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OwnerFieldsCubit>().loadFields();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('My Fields',
            style: GoogleFonts.lexend(
                fontSize: 20, fontWeight: FontWeight.w700)),
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/owner/fields/new'),
            icon: const Icon(Icons.add, color: AppColors.primary),
            label: Text('Add',
                style: GoogleFonts.lexend(
                    fontWeight: FontWeight.w600, color: AppColors.primary)),
          ),
        ],
      ),
      body: BlocConsumer<OwnerFieldsCubit, OwnerFieldsState>(
        listener: (context, state) {
          if (state is OwnerFieldUpdated) {
            KSSnackBar.success(context, 'Field updated.');
          } else if (state is OwnerFieldDeleted) {
            KSSnackBar.success(context, 'Field deleted.');
          } else if (state is OwnerFieldsFailure) {
            KSSnackBar.error(context, state.message);
          }
        },
        // Rebuild on every meaningful state change, including OwnerFieldsLoaded
        // (which now carries togglingFieldId for per-switch spinners).
        buildWhen: (prev, curr) =>
            curr is OwnerFieldsLoading ||
            curr is OwnerFieldsLoaded ||
            curr is OwnerFieldsFailure,
        builder: (context, state) {
          if (state is OwnerFieldsLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (state is OwnerFieldsLoaded) {
            final fields = state.fields;
            final togglingId = state.togglingFieldId;

            if (fields.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.stadium_outlined,
                        size: 64,
                        color: AppColors.textHint.withValues(alpha: 0.4)),
                    const SizedBox(height: 16),
                    Text('No fields yet',
                        style: GoogleFonts.lexend(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Text(
                        'Add your first field to start\nreceiving bookings.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lexend(
                            fontSize: 14, color: AppColors.textHint)),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(250, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.lgAll,
                        ),
                      ),
                      onPressed: () => context.push('/owner/fields/new'),
                      icon: const Icon(Icons.add),
                      label: Text('Add Field',
                          style: GoogleFonts.lexend(
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () =>
                  context.read<OwnerFieldsCubit>().loadFields(),
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: fields.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (_, i) {
                  final field = fields[i];
                  final fieldIntId = int.tryParse(field.id);
                  final isThisFieldToggling =
                      togglingId != null && togglingId == fieldIntId;
                  final isInactive = !field.isActive;

                  return Opacity(
                    // Slightly mute inactive cards visually, but keep them
                    // fully interactive.
                    opacity: isInactive ? 0.72 : 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppRadius.lgAll,
                        border: Border.all(
                          color: isInactive
                              ? AppColors.border
                              : AppColors.border,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Field image
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16)),
                            child: field.imageUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: field.imageUrl,
                                    height: 140,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(
                                        height: 140,
                                        color: AppColors.shimmerBase),
                                    errorWidget: (_, __, ___) => Container(
                                      height: 140,
                                      color: AppColors.shimmerBase,
                                      child: const Center(
                                          child: Icon(
                                              Icons.stadium_outlined,
                                              size: 40,
                                              color: AppColors.textHint)),
                                    ),
                                  )
                                : Container(
                                    height: 140,
                                    color: AppColors.shimmerBase,
                                    child: const Center(
                                        child: Icon(Icons.stadium_outlined,
                                            size: 40,
                                            color: AppColors.textHint)),
                                  ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Name + active toggle row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(field.name,
                                          style: GoogleFonts.lexend(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: isInactive
                                                  ? AppColors.textSecondary
                                                  : AppColors.onSurface)),
                                    ),
                                    // Toggle area
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          field.isActive
                                              ? 'Active'
                                              : 'Inactive',
                                          style: GoogleFonts.lexend(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: field.isActive
                                                ? AppColors.primary
                                                : AppColors.textHint,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        // Spinner while this specific field
                                        // is being toggled, switch otherwise.
                                        SizedBox(
                                          width: 44,
                                          height: 28,
                                          child: isThisFieldToggling
                                              ? const Center(
                                                  child: SizedBox(
                                                    width: 18,
                                                    height: 18,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: AppColors.primary,
                                                    ),
                                                  ),
                                                )
                                              : Switch(
                                                  value: field.isActive,
                                                  activeThumbColor:
                                                      AppColors.primary,
                                                  materialTapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                  onChanged: fieldIntId !=
                                                          null
                                                      ? (_) => context
                                                          .read<
                                                              OwnerFieldsCubit>()
                                                          .toggleFieldActive(
                                                              fieldIntId)
                                                      : null,
                                                ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 6),

                                // Location
                                Row(
                                  children: [
                                    const Icon(Icons.location_on,
                                        size: 14,
                                        color: AppColors.textSecondary),
                                    const SizedBox(width: 4),
                                    Flexible(
                                        child: Text(
                                            field.location.isNotEmpty
                                                ? field.location
                                                : field.city,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.lexend(
                                                fontSize: 13,
                                                color:
                                                    AppColors.textSecondary))),
                                  ],
                                ),

                                const SizedBox(height: 4),

                                // Price
                                Text(
                                    '${field.pricePerHour.toInt()} ${field.currency}/hr',
                                    style: GoogleFonts.lexend(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: isInactive
                                            ? AppColors.textSecondary
                                            : AppColors.primary)),

                                const SizedBox(height: 12),

                                // Action buttons — always enabled
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => context.push(
                                            '/owner/fields/${field.id}/edit'),
                                        style: OutlinedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    AppRadius.smAll)),
                                        child: Text('Edit',
                                            style: GoogleFonts.lexend(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => context.push(
                                            '/owner/fields/${field.id}/slots'),
                                        style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    AppRadius.smAll)),
                                        child: Text('Manage Slots',
                                            style: GoogleFonts.lexend(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }

          if (state is OwnerFieldsFailure) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: AppColors.textHint),
                  const SizedBox(height: 12),
                  Text('Failed to load fields',
                      style: GoogleFonts.lexend(
                          fontSize: 16, color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<OwnerFieldsCubit>().loadFields(),
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
