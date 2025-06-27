// Usage Examples:

// 1. Basic usage in a repository
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_manager_app/src/core/dio/dio_client.dart';
import 'package:property_manager_app/src/presentation/providers/dio_provider.dart';

class ExampleRepository {
  final DioClient _dioClient;

  ExampleRepository(this._dioClient);

  Future<Map<String, dynamic>> fetchData() async {
    try {
      final response = await _dioClient.get('/example-endpoint');
      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }

  Future<void> postData(Map<String, dynamic> data) async {
    try {
      await _dioClient.post(
        '/example-endpoint',
        data: data,
      );
    } catch (e) {
      throw Exception('Failed to post data: $e');
    }
  }
}

// 2. Using with Riverpod
final exampleRepositoryProvider = Provider<ExampleRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ExampleRepository(dioClient);
});

// 3. Advanced usage with custom options
class AdvancedRepository {
  final Dio _dio;

  AdvancedRepository(this._dio);

  Future<void> uploadFile(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: 'upload.jpg',
      ),
    });

    await _dio.post(
      '/upload',
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      ),
      onSendProgress: (int sent, int total) {
        print('Upload progress: ${(sent / total * 100).toStringAsFixed(0)}%');
      },
    );
  }

  Future<void> downloadFile(String url, String savePath) async {
    await _dio.download(
      url,
      savePath,
      onReceiveProgress: (int received, int total) {
        if (total != -1) {
          print('Download progress: ${(received / total * 100).toStringAsFixed(0)}%');
        }
      },
    );
  }
}