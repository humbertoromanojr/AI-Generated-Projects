class ServerException implements Exception {
  final String message;

  const ServerException([this.message = 'Erro no servidor.']);
}

class CacheException implements Exception {
  final String message;

  const CacheException([this.message = 'Erro no armazenamento local.']);
}

class NoInternetException implements Exception {
  const NoInternetException();
}
