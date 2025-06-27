class TokenResponseModel {
  final String accessToken;
  final String? refreshToken;
  final int? expiresIn;

  TokenResponseModel({
    required this.accessToken,
    this.refreshToken,
    this.expiresIn,
  });

  factory TokenResponseModel.fromJson(Map<String, dynamic> json) {
    return TokenResponseModel(
      accessToken: json['accessToken'] ?? json['access_token'] ?? '',
      refreshToken: json['refreshToken'] ?? json['refresh_token'],
      expiresIn: json['expiresIn'] ?? json['expires_in'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      if (refreshToken != null) 'refreshToken': refreshToken,
      if (expiresIn != null) 'expiresIn': expiresIn,
    };
  }
}