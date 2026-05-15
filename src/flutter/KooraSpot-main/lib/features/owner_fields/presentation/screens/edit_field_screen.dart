import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../core/utils/ks_snackbar.dart';
import '../../../../core/utils/validators.dart';
import '../../../courts/domain/entities/court.dart';
import '../cubit/owner_fields_cubit.dart';

class EditFieldScreen extends StatefulWidget {
  final String fieldId;
  const EditFieldScreen({super.key, required this.fieldId});

  @override
  State<EditFieldScreen> createState() => _EditFieldScreenState();
}

class _EditFieldScreenState extends State<EditFieldScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<File> _newImages = [];
  Court? _court;
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _initFields(Court court) {
    if (_initialized) return;
    _initialized = true;
    _court = court;
    _nameController.text = court.name;
    _addressController.text = court.location;
    _cityController.text = court.city;
    _priceController.text = court.pricePerHour.toInt().toString();
    // description is not in Court entity — leave empty for now
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() {
        _newImages.addAll(picked.map((xf) => File(xf.path)));
      });
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final fieldId = int.tryParse(widget.fieldId);
    if (fieldId == null) return;

    context.read<OwnerFieldsCubit>().updateField(
          fieldId: fieldId,
          name: _nameController.text.trim(),
          address: _addressController.text.trim(),
          city: _cityController.text.trim(),
          pricePerHour: double.tryParse(_priceController.text.trim()) ?? 0,
          description: _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : null,
          images: _newImages.isNotEmpty ? _newImages : null,
        );
  }

  void _confirmDelete() {
    final fieldId = int.tryParse(widget.fieldId);
    if (fieldId == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
        title: Text('Delete Field',
            style: GoogleFonts.lexend(fontWeight: FontWeight.w700)),
        content: Text(
          'Are you sure you want to delete "${_court?.name ?? 'this field'}"?\nThis action cannot be undone.',
          style: GoogleFonts.lexend(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.lexend(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<OwnerFieldsCubit>().deleteField(fieldId);
            },
            child: Text('Delete',
                style: GoogleFonts.lexend(
                    color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OwnerFieldsCubit, OwnerFieldsState>(
      listener: (context, state) {
        if (state is OwnerFieldUpdated) {
          KSSnackBar.success(context, 'Field updated successfully.');
          context.pop();
        } else if (state is OwnerFieldDeleted) {
          KSSnackBar.success(context, 'Field deleted successfully.');
          context.pop();
        } else if (state is OwnerFieldsFailure) {
          KSSnackBar.error(context, state.message);
        } else if (state is OwnerFieldsLoaded && !_initialized) {
          // Initialize from loaded fields
          final court = state.fields.firstWhere(
            (f) => f.id == widget.fieldId,
            orElse: () => Court(
                id: '', name: '', location: '', city: '',
                pricePerHour: 0, imageUrl: ''),
          );
          if (court.id.isNotEmpty) {
            _initFields(court);
          }
        }
      },
      builder: (context, state) {
        // Initialize from already-loaded data
        if (state is OwnerFieldsLoaded && !_initialized) {
          final court = state.fields.firstWhere(
            (f) => f.id == widget.fieldId,
            orElse: () => Court(
                id: '', name: '', location: '', city: '',
                pricePerHour: 0, imageUrl: ''),
          );
          if (court.id.isNotEmpty) {
            _initFields(court);
          }
        }

        final isUpdating = state is OwnerFieldUpdating;
        final isDeleting = state is OwnerFieldDeleting;
        final isLoading = isUpdating || isDeleting;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            title: Text('Edit Field',
                style: GoogleFonts.lexend(fontWeight: FontWeight.w700)),
            backgroundColor: Colors.white,
            foregroundColor: AppColors.onSurface,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
          ),
          body: !_initialized
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Current image preview
                        if (_court != null && _court!.imageUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: AppRadius.mdAll,
                            child: CachedNetworkImage(
                              imageUrl: _court!.imageUrl,
                              height: 160,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                height: 160,
                                color: AppColors.shimmerBase,
                              ),
                              errorWidget: (_, __, ___) => Container(
                                height: 160,
                                color: AppColors.shimmerBase,
                                child: const Icon(Icons.stadium,
                                    size: 48, color: AppColors.textHint),
                              ),
                            ),
                          ),
                        if (_court != null && _court!.imageUrl.isNotEmpty)
                          const SizedBox(height: 16),

                        // New images
                        if (_newImages.isNotEmpty) ...[
                          Text('New Images',
                              style: GoogleFonts.lexend(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary)),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 80,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _newImages.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (_, i) => Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: AppRadius.smAll,
                                    child: Image.file(
                                      _newImages[i],
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 2,
                                    right: 2,
                                    child: GestureDetector(
                                      onTap: () => setState(
                                          () => _newImages.removeAt(i)),
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close,
                                            size: 14, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Add images button
                        OutlinedButton.icon(
                          onPressed: _pickImages,
                          icon: const Icon(Icons.add_photo_alternate_outlined,
                              size: 20),
                          label: Text(
                            _newImages.isEmpty
                                ? 'Replace Images'
                                : 'Add More Images',
                            style: GoogleFonts.lexend(fontSize: 14),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                                borderRadius: AppRadius.mdAll),
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Name
                        _label('FIELD NAME'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _nameController,
                          validator: (v) => Validators.required(v, 'Name'),
                          decoration: _inputDecor('Field name'),
                        ),
                        const SizedBox(height: 16),

                        // Address
                        _label('ADDRESS'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _addressController,
                          validator: (v) => Validators.required(v, 'Address'),
                          decoration: _inputDecor('Address'),
                        ),
                        const SizedBox(height: 16),

                        // City
                        _label('CITY'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _cityController,
                          validator: (v) => Validators.required(v, 'City'),
                          decoration: _inputDecor('City'),
                        ),
                        const SizedBox(height: 16),

                        // Price
                        _label('PRICE PER HOUR (EGP)'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Price is required';
                            }
                            if (double.tryParse(v.trim()) == null) {
                              return 'Enter a valid number';
                            }
                            return null;
                          },
                          decoration: _inputDecor('200'),
                        ),
                        const SizedBox(height: 16),

                        // Description
                        _label('DESCRIPTION (optional)'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 3,
                          decoration: _inputDecor('Describe your field...'),
                        ),

                        const SizedBox(height: 32),

                        // Save button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.mdAll),
                              elevation: 4,
                              shadowColor: AppColors.primaryShadow,
                            ),
                            child: isUpdating
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : Text('Save Changes',
                                    style: GoogleFonts.lexend(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700)),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Delete button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: isLoading ? null : _confirmDelete,
                            icon: isDeleting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.error),
                                  )
                                : const Icon(Icons.delete_outline, size: 20),
                            label: Text(
                              isDeleting ? 'Deleting...' : 'Delete Field',
                              style: GoogleFonts.lexend(
                                  fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error),
                              shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.mdAll),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.lexend(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 1,
        ),
      );

  InputDecoration _inputDecor(String hint) => InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
      );
}
