class ApiError {
  final String message;
  final String error;
  final int statusCode;

  ApiError({
    required this.message,
    required this.error,
    required this.statusCode,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      message: json['message'],
      error: json['error'],
      statusCode: json['statusCode'],
    );
  }
}
