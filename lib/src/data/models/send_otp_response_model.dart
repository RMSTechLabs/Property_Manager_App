class SendOtpResponseModel {
  final String status;
  final String otpIdentifier;
  final String? message;
  final bool? success;
  final bool? validate;

  SendOtpResponseModel({
    required this.status,
    required this.otpIdentifier,
    this.message,
    this.success,
    this.validate,
  });

  factory SendOtpResponseModel.fromJson(Map<String, dynamic> json) {
    return SendOtpResponseModel(
      status: json["data"]['status'] ?? json["data"]['status'] ?? '',
      otpIdentifier:
          json["data"]["otpValidateDto"]["otpIdentifier"] ??
          json["data"]["otpValidateDto"]["otpIdentifier"],
      message: json["message"],
      success: json["success"],
      validate: json["data"]["validate"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'otpIdetifier': otpIdentifier,
      'message': message,
      'success': success,
      'validate':validate,
    };
  }
}
