class CacheException implements Exception {
  const CacheException([this.message = 'Cache exception']);

  final String message;
}

class ServerException implements Exception {
  const ServerException([this.message = 'Server exception']);

  final String message;
}
