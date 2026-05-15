import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../core/utils/ks_snackbar.dart';
import '../../../slots/domain/entities/slot.dart';
import '../../../slots/presentation/cubit/slots_cubit.dart';

class ManageSlotsScreen extends StatefulWidget {
  final String fieldId;
  const ManageSlotsScreen({super.key, required this.fieldId});

  @override
  State<ManageSlotsScreen> createState() => _ManageSlotsScreenState();
}

class _ManageSlotsScreenState extends State<ManageSlotsScreen> {
  DateTime _selectedDate = DateTime.now();
  final List<DateTime> _dates = List.generate(7, (i) => DateTime.now().add(Duration(days: i)));

  @override
  void initState() {
    super.initState();
    context.read<SlotsCubit>().loadSlots(widget.fieldId, _selectedDate);
  }

  void _selectDate(DateTime date) {
    setState(() => _selectedDate = date);
    context.read<SlotsCubit>().loadSlots(widget.fieldId, date);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SlotsCubit, SlotsState>(
      listener: (context, state) {
        if (state is SlotsSaved) {
          KSSnackBar.success(context, 'Slots saved successfully');
        } else if (state is SlotsFailure) {
          KSSnackBar.error(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(title: Text('Manage Slots', style: GoogleFonts.lexend(fontSize: 20, fontWeight: FontWeight.w700))),
        body: Column(
          children: [
            // Date picker
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: _dates.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final date = _dates[i];
                  final isSelected = date.day == _selectedDate.day;
                  return GestureDetector(
                    onTap: () => _selectDate(date),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 56,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: AppRadius.mdAll,
                        border: Border.all(color: isSelected ? AppColors.primary : AppColors.inputBorder),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1], style: GoogleFonts.lexend(fontSize: 11, fontWeight: FontWeight.w500, color: isSelected ? Colors.white70 : AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          Text('${date.day}', style: GoogleFonts.lexend(fontSize: 20, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : AppColors.onSurface)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Legend
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  _legendItem(Colors.white, AppColors.slotAvailableBorder, 'Available'),
                  const SizedBox(width: 16),
                  _legendItem(AppColors.slotBooked, Colors.transparent, 'Booked'),
                  const SizedBox(width: 16),
                  _legendItem(Colors.red.shade50, Colors.red.shade200, 'Unavailable'),
                ],
              ),
            ),

            // Slots
            Expanded(
              child: BlocBuilder<SlotsCubit, SlotsState>(
                builder: (context, state) {
                  if (state is SlotsLoading) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }
                  if (state is SlotsLoaded) {
                    if (state.slots.isEmpty) {
                      return Center(
                        child: Text('No slots for this date', style: GoogleFonts.lexend(fontSize: 14, color: AppColors.textHint)),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: state.slots.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final slot = state.slots[i];
                        return _SlotRow(slot: slot, onToggle: () {
                          context.read<SlotsCubit>().toggleAvailability(slot.id);
                        });
                      },
                    );
                  }
                  if (state is SlotsFailure) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Failed to load slots', style: GoogleFonts.lexend(color: AppColors.textHint)),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => context.read<SlotsCubit>().loadSlots(widget.fieldId, _selectedDate),
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

            // Save button
            BlocBuilder<SlotsCubit, SlotsState>(
              builder: (context, state) {
                final isSaving = state is SlotsSaving;
                return Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  color: Colors.white,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : () => context.read<SlotsCubit>().saveChanges(),
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52), shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll)),
                    child: isSaving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text('Save Changes', style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(Color fill, Color border, String label) {
    return Row(
      children: [
        Container(width: 14, height: 14, decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(4), border: border != Colors.transparent ? Border.all(color: border) : null)),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.lexend(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _SlotRow extends StatelessWidget {
  final Slot slot;
  final VoidCallback onToggle;

  const _SlotRow({required this.slot, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String trailing;

    if (slot.isBooked) {
      bgColor = AppColors.slotBooked;
      textColor = AppColors.slotBookedText;
      trailing = slot.bookedByName ?? 'Booked';
    } else if (slot.isUnavailable) {
      bgColor = Colors.red.shade50;
      textColor = Colors.red.shade400;
      trailing = 'Unavailable';
    } else {
      bgColor = Colors.white;
      textColor = AppColors.onSurface;
      trailing = 'Available';
    }

    return GestureDetector(
      onTap: slot.isBooked ? null : onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppRadius.mdAll,
          border: Border.all(color: slot.isBooked ? AppColors.border : (slot.isUnavailable ? Colors.red.shade200 : AppColors.slotAvailableBorder)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(slot.timeRange, style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
            Text(trailing, style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w500, color: textColor)),
          ],
        ),
      ),
    );
  }
}
