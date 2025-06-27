class RefreshTokenResponseModel {
  final String accessToken;
  final int? expiresIn;

  RefreshTokenResponseModel({
    required this.accessToken,
    this.expiresIn,
  });

  factory RefreshTokenResponseModel.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponseModel(
      accessToken: json['accessToken'] ?? json['access_token'] ?? '',
      expiresIn: json['expiresIn'] ?? json['expires_in'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      if (expiresIn != null) 'expiresIn': expiresIn,
    };
  }
}