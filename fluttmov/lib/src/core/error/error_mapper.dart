import 'failures.dart';
import 'exceptions.dart';

Failure mapExceptionToFailure(Object error) {
  if (error is NoInternetException) {
    return const NetworkFailure();
  }
  if (error is CacheException) {
    return CacheFailure(error.message);
  }
  if (error is ServerException) {
    return ServerFailure(error.message);
  }
  return const ServerFailure();
}
