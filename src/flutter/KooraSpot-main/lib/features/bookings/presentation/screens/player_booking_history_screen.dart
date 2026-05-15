import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../data/models/booking_model.dart';
import '../cubit/booking_cubit.dart';

class PlayerBookingHistoryScreen extends StatefulWidget {
  const PlayerBookingHistoryScreen({super.key});

  @override
  State<PlayerBookingHistoryScreen> createState() => _PlayerBookingHistoryScreenState();
}

class _PlayerBookingHistoryScreenState extends State<PlayerBookingHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<BookingCubit>().loadMyBookings(forceRefresh: true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await context.read<BookingCubit>().loadMyBookings(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('Booking History', style: GoogleFonts.lexend(fontSize: 20, fontWeight: FontWeight.w700)),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w600),
          tabs: const [Tab(text: 'Upcoming'), Tab(text: 'Past')],
        ),
      ),
      body: BlocBuilder<BookingCubit, BookingState>(
        // Only rebuild for history-related states
        buildWhen: (prev, curr) =>
            curr is BookingHistoryLoading ||
            curr is BookingHistoryLoaded ||
            curr is BookingHistoryFailure,
        builder: (context, state) {
          if (state is BookingHistoryLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state is BookingHistoryLoaded) {
            final upcoming = state.bookings.where((b) => b.isUpcoming).toList();
            final past = state.bookings.where((b) => !b.isUpcoming).toList();
            return TabBarView(
              controller: _tabController,
              children: [
                _buildRefreshableList(upcoming),
                _buildRefreshableList(past),
              ],
            );
          }
          if (state is BookingHistoryFailure) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.textHint),
                  const SizedBox(height: 12),
                  Text('Failed to load bookings', style: GoogleFonts.lexend(fontSize: 16, color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<BookingCubit>().loadMyBookings(forceRefresh: true),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          // Any other state (e.g. slot states from stadium screen) — show loading
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        },
      ),
    );
  }

  Widget _buildRefreshableList(List<PlayerBookingModel> bookings) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _onRefresh,
      child: bookings.isEmpty
          ? ListView(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 64, color: AppColors.textHint.withValues(alpha: 0.4)),
                        const SizedBox(height: 16),
                        Text('No bookings yet', style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        Text('Your bookings will appear here', style: GoogleFonts.lexend(fontSize: 14, color: AppColors.textHint)),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: bookings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _BookingCard(booking: bookings[i]),
            ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final PlayerBookingModel booking;
  const _BookingCard({required this.booking});

  Color get _statusColor {
    switch (booking.status.toLowerCase()) {
      case 'confirmed':
        return AppColors.primary;
      case 'cancelled':
        return const Color(0xFFBA1A1A);
      default:
        return const Color(0xFFE68A00);
    }
  }

  Color get _statusBg {
    switch (booking.status.toLowerCase()) {
      case 'confirmed':
        return AppColors.successLight;
      case 'cancelled':
        return const Color(0xFFBA1A1A).withValues(alpha: 0.1);
      default:
        return const Color(0xFFE68A00).withValues(alpha: 0.1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: AppRadius.mdAll,
            ),
            child: const Icon(Icons.stadium_rounded, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(booking.fieldName, style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('${booking.dayName}, ${booking.bookingDate}', style: GoogleFonts.lexend(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(booking.slotTime, style: GoogleFonts.lexend(fontSize: 12, color: AppColors.textHint)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${booking.totalPrice.toInt()} EGP',
                style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _statusBg,
                  borderRadius: AppRadius.fullAll,
                ),
                child: Text(
                  booking.status.toUpperCase(),
                  style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w600, color: _statusColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
