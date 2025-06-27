
// 1. lib/src/presentation/providers/dio_provider.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/dio/dio_client.dart';

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(ref);
});

final dioProvider = Provider<Dio>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return dioClient.dio;
});