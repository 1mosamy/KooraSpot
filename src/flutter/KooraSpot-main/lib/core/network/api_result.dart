/// Sealed result type for API calls.
sealed class ApiResult<T> {
  const ApiResult();
}

class ApiSuccess<T> extends ApiResult<T> {
  final T data;
  const ApiSuccess(this.data);
}

class ApiFailure<T> extends ApiResult<T> {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  const ApiFailure({
    required this.message,
    this.statusCode,
    this.errors,
  });
}
