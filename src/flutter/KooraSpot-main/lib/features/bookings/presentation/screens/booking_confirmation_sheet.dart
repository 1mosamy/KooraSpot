import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../courts/domain/entities/court.dart';
import '../../../slots/domain/entities/slot.dart';

/// Shows a booking confirmation bottom sheet.
Future<bool?> showBookingConfirmation({
  required BuildContext context,
  required Court court,
  required List<Slot> selectedSlots,
  required double totalPrice,
  required DateTime date,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
    ),
    builder: (_) => BookingConfirmationSheet(
      court: court,
      selectedSlots: selectedSlots,
      totalPrice: totalPrice,
      date: date,
    ),
  );
}

class BookingConfirmationSheet extends StatelessWidget {
  final Court court;
  final List<Slot> selectedSlots;
  final double totalPrice;
  final DateTime date;

  const BookingConfirmationSheet({
    super.key,
    required this.court,
    required this.selectedSlots,
    required this.totalPrice,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textHint,
              borderRadius: AppRadius.fullAll,
            ),
          ),
          const SizedBox(height: 24),

          // Check icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.successLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: 16),

          Text('Booking Confirmation', style: GoogleFonts.lexend(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 24),

          // Details
          _row('Stadium', court.name),
          const Divider(height: 24),
          _row('Slots', '${selectedSlots.length} slot${selectedSlots.length > 1 ? 's' : ''}'),
          const Divider(height: 24),
          _row('Total', '${totalPrice.toInt()} ${court.currency}', isBold: true),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
              ),
              child: Text('Confirm & Pay', style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.lexend(fontSize: 14, color: AppColors.textSecondary)),
        Text(value, style: GoogleFonts.lexend(fontSize: 14, fontWeight: isBold ? FontWeight.w700 : FontWeight.w600, color: isBold ? AppColors.primary : AppColors.onSurface)),
      ],
    );
  }
}
