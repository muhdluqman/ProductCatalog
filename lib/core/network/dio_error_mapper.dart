import 'package:dio/dio.dart';

import '../errors/failures.dart';

Failure mapDioError(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const Failure('Connection timed out. Please try again.');
    case DioExceptionType.connectionError:
      return const Failure('No internet connection. Please try again.');
    case DioExceptionType.badResponse:
      final code = error.response?.statusCode;
      return Failure('Server error${code != null ? ' ($code)' : ''}. Please try again.');
    case DioExceptionType.cancel:
      return const Failure('Request was cancelled.');
    case DioExceptionType.badCertificate:
      return const Failure('Secure connection failed. Please try again.');
    case DioExceptionType.unknown:
    case DioExceptionType.transformTimeout:
      return const Failure('Something went wrong. Please try again.');
  }
}
