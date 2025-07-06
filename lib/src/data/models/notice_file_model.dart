// lib/src/data/models/notice_file_model.dart
class NoticeFile {
  final int id;
  final String fileName;
  final String filePath;
  final int fileSize;
  final String fileType;
  final String fileUrl;

  NoticeFile({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.fileType,
    required this.fileUrl,
  });

  // Get display file name (remove UUID from filename)
  String get displayFileName {
    // Extract original filename if it contains UUID
    final parts = fileName.split('.');
    if (parts.length > 1) {
      final extension = parts.last;
      final nameWithoutExt = parts.sublist(0, parts.length - 1).join('.');
      
      // If it's a UUID-style filename, return a cleaner name
      if (nameWithoutExt.contains('-') && nameWithoutExt.length > 30) {
        return 'Document.$extension';
      }
    }
    return fileName;
  }

  // Get file type for display (PDF, DOC, etc.)
  String get displayFileType {
    switch (fileType.toLowerCase()) {
      case 'application/pdf':
        return 'PDF';
      case 'application/msword':
      case 'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
        return 'DOC';
      case 'application/vnd.ms-excel':
      case 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet':
        return 'XLS';
      case 'image/jpeg':
      case 'image/jpg':
        return 'JPG';
      case 'image/png':
        return 'PNG';
      case 'image/gif':
        return 'GIF';
      default:
        return fileType.split('/').last.toUpperCase();
    }
  }

  // Get formatted file size
  String get displayFileSize {
    if (fileSize < 1024) {
      return '${fileSize} B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  factory NoticeFile.fromJson(Map<String, dynamic> json) {
    return NoticeFile(
      id: json['id'] ?? 0,
      fileName: json['fileName'] ?? '',
      filePath: json['filePath'] ?? '',
      fileSize: json['fileSize'] ?? 0,
      fileType: json['fileType'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'filePath': filePath,
      'fileSize': fileSize,
      'fileType': fileType,
      'fileUrl': fileUrl,
    };
  }
}