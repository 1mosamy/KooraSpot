import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/di/service_locator.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../core/utils/ks_snackbar.dart';
import '../../../bookings/presentation/cubit/booking_cubit.dart';
import '../../../courts/domain/entities/court.dart';
import '../../../courts/domain/repositories/court_repository.dart';
import '../../../saved_courts/presentation/cubit/saved_courts_cubit.dart';
import '../../../slots/domain/entities/slot.dart';

class StadiumDetailsScreen extends StatefulWidget {
  final String stadiumId;
  const StadiumDetailsScreen({super.key, required this.stadiumId});

  @override
  State<StadiumDetailsScreen> createState() => _StadiumDetailsScreenState();
}

class _StadiumDetailsScreenState extends State<StadiumDetailsScreen> {
  Court? _court;
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();
  final List<DateTime> _dates = List.generate(7, (i) => DateTime.now().add(Duration(days: i)));

  @override
  void initState() {
    super.initState();
    _loadCourt();
  }

  Future<void> _loadCourt() async {
    try {
      final court = await sl<CourtRepository>().getCourtById(widget.stadiumId);
      if (mounted) {
        setState(() {
          _court = court;
          _isLoading = false;
        });
        context.read<BookingCubit>().loadSlots(widget.stadiumId, _selectedDate);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        KSSnackBar.error(context, 'Failed to load stadium details');
      }
    }
  }

  void _selectDate(DateTime date) {
    setState(() => _selectedDate = date);
    context.read<BookingCubit>().loadSlots(widget.stadiumId, date);
  }

  Future<void> _openPaymentUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || (!uri.hasScheme) || uri.host.isEmpty) {
      if (mounted) {
        KSSnackBar.error(context, 'Invalid payment URL.');
      }
      return;
    }
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        KSSnackBar.error(context, 'Could not open payment page.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_court == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.textHint),
              const SizedBox(height: 16),
              Text('Stadium not found', style: GoogleFonts.lexend(fontSize: 18, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Go Back')),
            ],
          ),
        ),
      );
    }

    final fieldId = int.tryParse(_court!.id);

    return BlocListener<BookingCubit, BookingState>(
      listener: (context, state) {
        if (state is BookingCreated) {
          KSSnackBar.success(context, state.response.message.isNotEmpty ? state.response.message : 'Booking confirmed!');
          debugPrint('[StadiumDetails] Booking created, refreshing slots');
          context.read<BookingCubit>().refreshSlots();
        } else if (state is BookingPaymentReady) {
          KSSnackBar.success(context, 'Booking created. Complete payment in Stripe.');
          debugPrint('[StadiumDetails] Payment URL ready, opening...');
          _openPaymentUrl(state.paymentUrl);
          // Refresh slots after returning from Stripe
          final cubit = context.read<BookingCubit>();
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              debugPrint('[StadiumDetails] Refreshing slots after payment');
              cubit.refreshSlots();
            }
          });
        } else if (state is BookingFailure) {
          KSSnackBar.error(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                // Hero image
                SliverAppBar(
                  expandedHeight: 240,
                  pinned: true,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.white,
                  flexibleSpace: FlexibleSpaceBar(
                    background: _court!.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: _court!.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(color: AppColors.shimmerBase),
                            errorWidget: (_, __, ___) => _imagePlaceholder(),
                          )
                        : _imagePlaceholder(),
                  ),
                  leading: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  actions: [
                    // Favorite button using SavedCourtsCubit
                    BlocBuilder<SavedCourtsCubit, SavedCourtsState>(
                      builder: (context, savedState) {
                        final isFav = fieldId != null &&
                            context.read<SavedCourtsCubit>().isFavorite(fieldId);
                        return Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.red : Colors.white,
                            ),
                            onPressed: () {
                              if (fieldId != null) {
                                context
                                    .read<SavedCourtsCubit>()
                                    .toggleFavorite(fieldId);
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),

                // Court info
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(_court!.name, style: GoogleFonts.lexend(fontSize: 24, fontWeight: FontWeight.w700)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.successLight,
                                borderRadius: AppRadius.fullAll,
                              ),
                              child: Text('Open Now', style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (_court!.location.isNotEmpty || _court!.city.isNotEmpty)
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Flexible(child: Text(_court!.location.isNotEmpty ? '${_court!.location}, ${_court!.city}' : _court!.city, style: GoogleFonts.lexend(fontSize: 14, color: AppColors.textSecondary))),
                            ],
                          ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.sports_soccer, size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(_court!.type, style: GoogleFonts.lexend(fontSize: 14, color: AppColors.textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_court!.pricePerHour.toInt()} ${_court!.currency}/hr',
                          style: GoogleFonts.lexend(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                // Book a slot header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: Text('Book a Slot', style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.w700)),
                  ),
                ),

                // Date picker
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _dates.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (_, i) {
                        final date = _dates[i];
                        final isSelected = date.day == _selectedDate.day && date.month == _selectedDate.month;
                        return GestureDetector(
                          onTap: () => _selectDate(date),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 70,
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : Colors.white,
                              borderRadius: AppRadius.mdAll,
                              border: Border.all(color: isSelected ? AppColors.primary : AppColors.inputBorder),
                              boxShadow: isSelected ? [BoxShadow(color: AppColors.primaryShadow, blurRadius: 8, offset: const Offset(0, 3))] : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(DateFormat('EEE').format(date), style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w500, color: isSelected ? Colors.white70 : AppColors.textSecondary)),
                                const SizedBox(height: 4),
                                Text('${date.day}', style: GoogleFonts.lexend(fontSize: 22, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : AppColors.onSurface)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Slot legend
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        _legendItem(Colors.white, AppColors.slotAvailableBorder, 'Available'),
                        const SizedBox(width: 12),
                        _legendItem(AppColors.primary, Colors.transparent, 'Selected'),
                        const SizedBox(width: 12),
                        _legendItem(AppColors.slotBooked, Colors.transparent, 'Booked'),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                // Slot grid
                BlocBuilder<BookingCubit, BookingState>(
                  // Ignore history states — they should not affect slot UI
                  buildWhen: (prev, curr) =>
                      curr is BookingLoading ||
                      curr is BookingSlotsLoaded ||
                      curr is BookingFailure ||
                      curr is BookingConfirming ||
                      curr is BookingCreated ||
                      curr is BookingPaymentReady,
                  builder: (context, state) {
                    if (state is BookingLoading) {
                      return const SliverToBoxAdapter(
                        child: Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: AppColors.primary))),
                      );
                    }
                    if (state is BookingSlotsLoaded) {
                      if (state.slots.isEmpty) {
                        return SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Center(
                              child: Text('No slots available for this date', style: GoogleFonts.lexend(fontSize: 16, color: AppColors.textHint)),
                            ),
                          ),
                        );
                      }
                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverGrid.count(
                          crossAxisCount: 2,
                          childAspectRatio: 2.5,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          children: state.slots.map((slot) => _SlotChip(slot: slot, court: _court!)).toList(),
                        ),
                      );
                    }
                    if (state is BookingFailure) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Center(
                            child: Column(
                              children: [
                                Text('Failed to load slots', style: GoogleFonts.lexend(fontSize: 14, color: AppColors.textHint)),
                                const SizedBox(height: 8),
                                TextButton(onPressed: () => context.read<BookingCubit>().loadSlots(widget.stadiumId, _selectedDate), child: const Text('Retry')),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    return const SliverToBoxAdapter(child: SizedBox());
                  },
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),

            // Bottom booking bar
            BlocBuilder<BookingCubit, BookingState>(
              buildWhen: (prev, curr) =>
                  curr is BookingLoading ||
                  curr is BookingSlotsLoaded ||
                  curr is BookingConfirming ||
                  curr is BookingCreated ||
                  curr is BookingPaymentReady ||
                  curr is BookingFailure,
              builder: (context, state) {
                final cubit = context.read<BookingCubit>();
                final selected = cubit.selectedSlots;
                if (selected.isEmpty) return const SizedBox.shrink();

                final total = cubit.calculateTotal(_court!.pricePerHour);
                final isConfirming = state is BookingConfirming;
                return Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, -4))],
                      border: const Border(top: BorderSide(color: AppColors.border)),
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Total Price', style: GoogleFonts.lexend(fontSize: 12, color: AppColors.textSecondary)),
                            Text('${total.toInt()} ${_court!.currency}', style: GoogleFonts.lexend(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary)),
                            Text('${selected.length} slot${selected.length > 1 ? 's' : ''} selected', style: GoogleFonts.lexend(fontSize: 12, color: AppColors.textHint)),
                          ],
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: isConfirming
                              ? null
                              : () => cubit.confirmBooking(widget.stadiumId),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(140, 48),
                            shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
                          ),
                          child: isConfirming
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text('Confirm & Pay', style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() => Container(
        color: AppColors.shimmerBase,
        child: const Center(child: Icon(Icons.stadium_outlined, size: 64, color: AppColors.textHint)),
      );

  Widget _legendItem(Color fill, Color border, String label) {
    return Row(
      children: [
        Container(
          width: 16, height: 16,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: border.withValues(alpha: border.a > 0 ? 1 : 0.3)),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.lexend(fontSize: 14, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _SlotChip extends StatelessWidget {
  final Slot slot;
  final Court court;
  const _SlotChip({required this.slot, required this.court});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    Color borderColor;

    switch (slot.status) {
      case SlotStatus.available:
        bgColor = Colors.white;
        textColor = AppColors.onSurface;
        borderColor = AppColors.slotAvailableBorder;
      case SlotStatus.selected:
        bgColor = AppColors.primary;
        textColor = Colors.white;
        borderColor = AppColors.primary;
      case SlotStatus.booked:
        bgColor = AppColors.slotBooked;
        textColor = AppColors.slotBookedText;
        borderColor = AppColors.slotBooked;
      case SlotStatus.unavailable:
        bgColor = AppColors.slotBooked;
        textColor = AppColors.slotBookedText;
        borderColor = AppColors.slotBooked;
    }

    return GestureDetector(
      onTap: slot.isAvailable || slot.isSelected
          ? () => context.read<BookingCubit>().toggleSlotSelection(slot.id)
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppRadius.smAll,
          border: Border.all(color: borderColor),
        ),
        child: Center(
          child: Text(
            slot.timeRange,
            style: GoogleFonts.lexend(fontSize: 15, fontWeight: FontWeight.w700, color: textColor),
          ),
        ),
      ),
    );
  }
}
