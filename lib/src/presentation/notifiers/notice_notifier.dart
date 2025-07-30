// Enhanced Notice Provider with API Integration Points
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_manager_app/src/core/constants/api_constants.dart';
import 'package:property_manager_app/src/data/models/notice_model.dart';
import 'package:property_manager_app/src/presentation/providers/dio_provider.dart';
import 'package:property_manager_app/src/presentation/providers/society_provider.dart';

class NoticeNotifier extends AsyncNotifier<List<NoticeModel>> {
  @override
  Future<List<NoticeModel>> build() async {
    return _fetchNotices();
  }

  Future<List<NoticeModel>> _fetchNotices() async {
    final dio = ref.read(dioProvider);
    final selectedCommunity = ref.read(selectedCommunityProvider);

    if (selectedCommunity == null) return [];

    try {
      final response = await dio.get(
        ApiConstants.getNoticesEndpoint,
        queryParameters: {
          'societyId': selectedCommunity.societyId,
          'areaId': selectedCommunity.areaId,
          'apartmentId': selectedCommunity.apartmentId,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data["data"];
        if (data.isEmpty) {
          return [];
        }
        //print(data);
        return data.map((json) => NoticeModel.fromJson(json)).toList();
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to load Notices');
    }
  }

  Future<void> refreshNotices() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchNotices());
  }

  // 🔥 API METHODS FOR FUTURE INTEGRATION
  
  /// Mark a notice as read
  /// Call this when user taps on a notice
  Future<bool> markNoticeAsRead(String noticeId) async {
    final dio = ref.read(dioProvider);
    try {
      final response = await dio.patch(
        '${ApiConstants.baseUrl}/notices/$noticeId/mark-read', // Replace with actual endpoint
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
      
      if (response.statusCode == 200) {
        // Optionally update local state
        await refreshNotices();
        return true;
      }
      return false;
    } on DioException catch (e) {
      //print('Error marking notice as read: ${e.message}');
      return false;
    }
  }

  /// Toggle saved status of a notice
  /// Call this when user taps bookmark icon
  Future<bool> toggleNoticeSaved(String noticeId) async {
    final dio = ref.read(dioProvider);
    try {
      final response = await dio.post(
        '${ApiConstants.baseUrl}/notices/$noticeId/toggle-saved', // Replace with actual endpoint
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
      
      if (response.statusCode == 200) {
        // Optionally update local state
        await refreshNotices();
        return true;
      }
      return false;
    } on DioException catch (e) {
      //print('Error toggling notice saved status: ${e.message}');
      return false;
    }
  }

  /// Get count of unread notices
  /// Call this to show unread count in UI
  Future<int> getUnreadNoticesCount() async {
    final dio = ref.read(dioProvider);
    final selectedCommunity = ref.read(selectedCommunityProvider);
    
    if (selectedCommunity == null) return 0;
    
    try {
      final response = await dio.get(
        '${ApiConstants.baseUrl}/notices/unread-count', // Replace with actual endpoint
        queryParameters: {
          'societyId': selectedCommunity.societyId,
          'areaId': selectedCommunity.areaId,
          'apartmentId': selectedCommunity.apartmentId,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
      
      if (response.statusCode == 200) {
        return response.data['count'] ?? 0;
      }
      return 0;
    } on DioException catch (e) {
      //print('Error getting unread count: ${e.message}');
      return 0;
    }
  }

  /// Get list of saved notice IDs
  /// Call this to identify which notices are bookmarked
  Future<List<String>> getSavedNoticeIds() async {
    final dio = ref.read(dioProvider);
    final selectedCommunity = ref.watch(selectedCommunityProvider);
    
    if (selectedCommunity == null) return [];
    
    try {
      final response = await dio.get(
        '${ApiConstants.baseUrl}/notices/saved', // Replace with actual endpoint
        queryParameters: {
          'societyId': selectedCommunity.societyId,
          'areaId': selectedCommunity.areaId,  
          'apartmentId': selectedCommunity.apartmentId,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((item) => item['id'].toString()).toList();
      }
      return [];
    } on DioException catch (e) {
      //print('Error getting saved notices: ${e.message}');
      return [];
    }
  }

  /// Get list of unread notice IDs
  /// Call this to identify which notices are unread
  Future<List<String>> getUnreadNoticeIds() async {
    final dio = ref.read(dioProvider);
    final selectedCommunity = ref.read(selectedCommunityProvider);
    
    if (selectedCommunity == null) return [];
    
    try {
      final response = await dio.get(
        '${ApiConstants.baseUrl}/notices/unread', // Replace with actual endpoint
        queryParameters: {
          'societyId': selectedCommunity.societyId,
          'areaId': selectedCommunity.areaId,
          'apartmentId': selectedCommunity.apartmentId,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((item) => item['id'].toString()).toList();
      }
      return [];
    } on DioException catch (e) {
      //print('Error getting unread notices: ${e.message}');
      return [];
    }
  }
}

final noticeProvider = AsyncNotifierProvider<NoticeNotifier, List<NoticeModel>>(
  NoticeNotifier.new,
);

// 🔥 ADDITIONAL PROVIDERS FOR API DATA
// These will be used when APIs are available

/// Provider for unread notice IDs
final unreadNoticeIdsProvider = FutureProvider<List<String>>((ref) async {
  final notifier = ref.read(noticeProvider.notifier);
  return await notifier.getUnreadNoticeIds();
});

/// Provider for saved notice IDs  
final savedNoticeIdsProvider = FutureProvider<List<String>>((ref) async {
  final notifier = ref.read(noticeProvider.notifier);
  return await notifier.getSavedNoticeIds();
});

/// Provider for unread count
final unreadNoticesCountProvider = FutureProvider<int>((ref) async {
  final notifier = ref.read(noticeProvider.notifier);
  return await notifier.getUnreadNoticesCount();
});


// When APIs become available, replace these methods:

/*
// Mark notice as read API call
Future<void> _markNoticeAsRead(String noticeId) async {
  final dio = ref.read(dioProvider);
  try {
    await dio.patch(
      '${ApiConstants.markNoticeReadEndpoint}/$noticeId',
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
  } catch (e) {
    // Handle error
  }
}

// Toggle saved notice API call  
Future<void> _toggleNoticeSaved(String noticeId) async {
  final dio = ref.read(dioProvider);
  try {
    await dio.post(
      '${ApiConstants.toggleNoticeSavedEndpoint}/$noticeId',
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
  } catch (e) {
    // Handle error
  }
}

// Get unread notices count API call
Future<int> _getUnreadNoticesCount() async {
  final dio = ref.read(dioProvider);
  try {
    final response = await dio.get(
      ApiConstants.getUnreadNoticesCountEndpoint,
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    return response.data['count'] ?? 0;
  } catch (e) {
    return 0;
  }
}

// Get saved notices API call
Future<List<String>> _getSavedNoticeIds() async {
  final dio = ref.read(dioProvider);
  try {
    final response = await dio.get(
      ApiConstants.getSavedNoticesEndpoint,
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    final List<dynamic> data = response.data['data'] ?? [];
    return data.map((item) => item['id'].toString()).toList();
  } catch (e) {
    return [];
  }
}
*/