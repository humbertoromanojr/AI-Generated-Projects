sealed class AppException {
  const AppException();
}

class NetworkError extends AppException {
  const NetworkError(this.message);

  final String message;

  @override
  String toString() => 'NetworkError: $message';
}

class HttpError extends AppException {
  const HttpError({required this.statusCode, this.message});

  final int statusCode;
  final String? message;

  @override
  String toString() =>
      'HttpError: $statusCode${message == null ? '' : ' $message'}';
}

class RateLimitError extends AppException {
  const RateLimitError({this.retryAfterSeconds});

  final int? retryAfterSeconds;

  @override
  String toString() =>
      'RateLimitError: ${retryAfterSeconds ?? 'unknown'}s retry';
}

class ParseError extends AppException {
  const ParseError(this.message);

  final String message;

  @override
  String toString() => 'ParseError: $message';
}
