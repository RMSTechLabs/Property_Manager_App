class ErrorResponseModel {
  final String message;
  final int? statusCode;
  final String? error;
  final Map<String, dynamic>? details;

  ErrorResponseModel({
    required this.message,
    this.statusCode,
    this.error,
    this.details,
  });

  factory ErrorResponseModel.fromJson(Map<String, dynamic> json) {
    return ErrorResponseModel(
      message: json['message'] ?? 'An error occurred',
      statusCode: json['statusCode'] ?? json['status_code'],
      error: json['error'],
      details: json['details'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      if (statusCode != null) 'statusCode': statusCode,
      if (error != null) 'error': error,
      if (details != null) 'details': details,
    };
  }
}