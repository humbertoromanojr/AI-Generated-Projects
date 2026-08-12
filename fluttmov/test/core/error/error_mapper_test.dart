import 'package:flutter_test/flutter_test.dart';

import 'package:fluttmov/src/core/error/error_mapper.dart';
import 'package:fluttmov/src/core/error/exceptions.dart';
import 'package:fluttmov/src/core/error/failures.dart';

void main() {
  group('mapExceptionToFailure', () {
    test('NoInternetException vira NetworkFailure', () {
      final failure = mapExceptionToFailure(const NoInternetException());
      expect(failure, isA<NetworkFailure>());
    });

    test('CacheException vira CacheFailure com a mensagem', () {
      final failure = mapExceptionToFailure(const CacheException('erro'));
      expect(failure, isA<CacheFailure>());
      expect((failure as CacheFailure).message, 'erro');
    });

    test('ServerException vira ServerFailure com a mensagem', () {
      final failure = mapExceptionToFailure(const ServerException('falha'));
      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).message, 'falha');
    });

    test('erros desconhecidos viram ServerFailure', () {
      final failure = mapExceptionToFailure(StateError('x'));
      expect(failure, isA<ServerFailure>());
    });
  });
}
