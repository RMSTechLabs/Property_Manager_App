// lib/src/core/errors/exceptions.dart
class ServerException implements Exception {
  final String message;
  ServerException(this.message);
  
  @override
  String toString() => 'ServerException: $message';
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  
  @override
  String toString() => 'NetworkException: $message';
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  
  @override
  String toString() => 'AuthException: $message';
}

class CacheException implements Exception {
  final String message;
  CacheException(this.message);
  
  @override
  String toString() => 'CacheException: $message';
}

class ValidationException implements Exception {
  final String message;
  final Map<String, List<String>>? errors;
  
  ValidationException(this.message, {this.errors});
  
  @override
  String toString() => 'ValidationException: $message${errors != null ? ', errors: $errors' : ''}';
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);
  
  @override
  String toString() => 'NotFoundException: $message';
}

class PermissionException implements Exception {
  final String message;
  PermissionException(this.message);
  
  @override
  String toString() => 'PermissionException: $message';
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  
  @override
  String toString() => 'TimeoutException: $message';
}

// lib/src/core/errors/exceptions.dart
class NotificationException implements Exception {
  final String message;
  
  const NotificationException(this.message);
  
  @override
  String toString() => 'NotificationException: $message';
}