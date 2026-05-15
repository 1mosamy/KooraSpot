import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../core/utils/ks_snackbar.dart';
import '../../../../core/utils/validators.dart';
import '../cubit/owner_fields_cubit.dart';

class AddCourtModal extends StatefulWidget {
  const AddCourtModal({super.key});

  @override
  State<AddCourtModal> createState() => _AddCourtModalState();
}

class _AddCourtModalState extends State<AddCourtModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCity = 'Cairo';
  final List<File> _selectedImages = [];
  bool _isSubmitting = false;

  final _cities = ['Cairo', 'Giza', 'Alexandria', 'Mansoura', 'Tanta', 'Ismailia'];

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images.map((e) => File(e.path)));
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    context.read<OwnerFieldsCubit>().addCourt(
          name: _nameController.text.trim(),
          address: _locationController.text.trim(),
          city: _selectedCity,
          pricePerHour: double.tryParse(_priceController.text) ?? 0,
          description: _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : null,
          images: _selectedImages.isNotEmpty ? _selectedImages : null,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OwnerFieldsCubit, OwnerFieldsState>(
      listener: (context, state) {
        if (state is OwnerFieldAdded) {
          KSSnackBar.success(context, 'Court added successfully!');
          Navigator.pop(context);
        } else if (state is OwnerFieldsFailure) {
          setState(() => _isSubmitting = false);
          KSSnackBar.error(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(title: Text('Add Field', style: GoogleFonts.lexend(fontSize: 20, fontWeight: FontWeight.w700))),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _label('COURT NAME'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                validator: (v) => Validators.required(v, 'Court name'),
                decoration: const InputDecoration(hintText: 'Enter court name', prefixIcon: Icon(Icons.stadium_outlined, size: 20, color: AppColors.textHint)),
              ),
              const SizedBox(height: 16),
              _label('LOCATION / ADDRESS'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _locationController,
                validator: (v) => Validators.required(v, 'Location'),
                decoration: const InputDecoration(hintText: 'Enter address', prefixIcon: Icon(Icons.location_on_outlined, size: 20, color: AppColors.textHint)),
              ),
              const SizedBox(height: 16),
              _label('CITY'),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedCity,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.location_city, size: 20, color: AppColors.textHint)),
                items: _cities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _selectedCity = v ?? 'Cairo'),
              ),
              const SizedBox(height: 16),
              _label('PRICE PER HOUR (EGP)'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                validator: (v) => Validators.required(v, 'Price'),
                decoration: const InputDecoration(hintText: 'e.g. 150', prefixIcon: Icon(Icons.attach_money, size: 20, color: AppColors.textHint)),
              ),
              const SizedBox(height: 16),
              _label('DESCRIPTION (OPTIONAL)'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Describe your court...'),
              ),
              const SizedBox(height: 16),
              _label('COURT IMAGES (OPTIONAL)'),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.mdAll,
                    border: Border.all(color: AppColors.inputBorder, style: BorderStyle.solid),
                  ),
                  child: _selectedImages.isEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_photo_alternate_outlined, size: 32, color: AppColors.textHint),
                            const SizedBox(height: 4),
                            Text('Tap to add images', style: GoogleFonts.lexend(fontSize: 12, color: AppColors.textHint)),
                          ],
                        )
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.all(8),
                          itemCount: _selectedImages.length + 1,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (_, i) {
                            if (i == _selectedImages.length) {
                              return GestureDetector(
                                onTap: _pickImages,
                                child: Container(
                                  width: 80,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.inputBorder),
                                    borderRadius: AppRadius.smAll,
                                  ),
                                  child: const Icon(Icons.add, color: AppColors.textHint),
                                ),
                              );
                            }
                            return Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: AppRadius.smAll,
                                  child: Image.file(_selectedImages[i], width: 80, height: 80, fit: BoxFit.cover),
                                ),
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: GestureDetector(
                                    onTap: () => setState(() => _selectedImages.removeAt(i)),
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                      child: const Icon(Icons.close, size: 14, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52), shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll)),
                child: _isSubmitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('Add Field', style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text, style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant, letterSpacing: 0.96));
}
