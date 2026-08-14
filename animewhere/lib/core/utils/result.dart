import '../network/network_error.dart';

sealed class Result<T> {
  const Result();
}

class Loading<T> extends Result<T> {
  const Loading();
}

class Data<T> extends Result<T> {
  const Data(this.value);

  final T value;
}

class Failure<T> extends Result<T> {
  const Failure(this.error);

  final AppException error;
}

class Empty<T> extends Result<T> {
  const Empty();
}
