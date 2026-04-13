/// Base exception class for app errors
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Exception for network-related errors
class NetworkException extends AppException {
  NetworkException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Exception for API errors
class ApiException extends AppException {
  final int? statusCode;

  ApiException({
    required super.message,
    super.code,
    super.originalError,
    this.statusCode,
  });

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}

/// Exception for authentication errors
class AuthException extends AppException {
  AuthException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Exception for validation errors
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  ValidationException({
    required super.message,
    super.code,
    super.originalError,
    this.fieldErrors,
  });
}

/// Exception for cache errors
class CacheException extends AppException {
  CacheException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Result type for handling success/failure
class Result<T> {
  final T? data;
  final AppException? error;

  Result.success(this.data) : error = null;
  Result.failure(this.error) : data = null;

  bool get isSuccess => error == null;
  bool get isFailure => error != null;

  R when<R>({
    required R Function(T data) success,
    required R Function(AppException error) failure,
  }) {
    if (isSuccess) {
      return success(data as T);
    } else {
      return failure(error!);
    }
  }
}