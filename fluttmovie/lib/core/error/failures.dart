abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Erro ao carregar os dados.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sem conexão com a internet.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Sem conexão e sem cache disponível.']);
}
