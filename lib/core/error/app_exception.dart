class AppException implements Exception {
  const AppException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ProductNotFoundException extends AppException {
  const ProductNotFoundException()
    : super('This product could not be found.', statusCode: 404);
}
