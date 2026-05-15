part of 'owner_fields_cubit.dart';

sealed class OwnerFieldsState extends Equatable {
  const OwnerFieldsState();
  @override
  List<Object?> get props => [];
}

class OwnerFieldsInitial extends OwnerFieldsState {
  const OwnerFieldsInitial();
}

class OwnerFieldsLoading extends OwnerFieldsState {
  const OwnerFieldsLoading();
}

/// Main loaded state. [togglingFieldId] is set while a toggle API call is
/// in-flight so the UI can show a per-card spinner while keeping all cards
/// visible.
class OwnerFieldsLoaded extends OwnerFieldsState {
  final List<Court> fields;
  final OwnerStats stats;

  /// Non-null while a toggle is in-flight for that specific field.
  final int? togglingFieldId;

  const OwnerFieldsLoaded({
    required this.fields,
    required this.stats,
    this.togglingFieldId,
  });

  OwnerFieldsLoaded copyWith({
    List<Court>? fields,
    OwnerStats? stats,
    int? togglingFieldId,
    bool clearToggling = false,
  }) {
    return OwnerFieldsLoaded(
      fields: fields ?? this.fields,
      stats: stats ?? this.stats,
      togglingFieldId: clearToggling ? null : (togglingFieldId ?? this.togglingFieldId),
    );
  }

  @override
  List<Object?> get props => [fields, stats, togglingFieldId];
}

class OwnerFieldAdded extends OwnerFieldsState {
  const OwnerFieldAdded();
}

class OwnerFieldUpdating extends OwnerFieldsState {
  const OwnerFieldUpdating();
}

class OwnerFieldUpdated extends OwnerFieldsState {
  const OwnerFieldUpdated();
}

class OwnerFieldDeleting extends OwnerFieldsState {
  const OwnerFieldDeleting();
}

class OwnerFieldDeleted extends OwnerFieldsState {
  const OwnerFieldDeleted();
}

class OwnerFieldsFailure extends OwnerFieldsState {
  final String message;
  const OwnerFieldsFailure({required this.message});
  @override
  List<Object?> get props => [message];
}
