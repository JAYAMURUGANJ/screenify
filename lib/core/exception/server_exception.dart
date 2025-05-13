/// Exception thrown when a server-related error occurs.
class ServerException implements Exception {
  /// A descriptive error message.
  final String message;

  /// An optional error code for more specific error identification.
  final int? code;

  /// Optional stack trace for debugging purposes.
  final StackTrace? stackTrace;

  /// Creates a [ServerException].
  ///
  /// [message] is a human-readable error message.
  /// [code] is an optional error code.
  /// [stackTrace] is an optional stack trace for debugging.
  ServerException({
    this.message = 'Server Exception',
    this.code,
    this.stackTrace,
  });

  @override
  String toString() {
    final buffer = StringBuffer('ServerException');
    if (code != null) buffer.write(' (code: $code)');
    buffer.write(': $message');
    if (stackTrace != null) buffer.write('\nStackTrace: $stackTrace');
    return buffer.toString();
  }
}
