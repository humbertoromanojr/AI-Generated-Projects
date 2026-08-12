import 'package:dartz/dartz.dart';

abstract class Failure {
  final String message;

  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Erro inesperado ao carregar os dados.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sem conexão com a internet.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Erro ao acessar os dados locais.']);
}

typedef EitherFailure<T> = Either<Failure, T>;
