import 'package:equatable/equatable.dart';

enum _ResultType { success, failure }

///  A class which encapsulates a successful outcome with a value of type [T]
///  or a failure with [VideoError].
abstract class Result<T> extends Equatable {
  const Result._(this._type);

  const factory Result.success(T value) = Success._;

  const factory Result.failure(Object error, [StackTrace stackTrace]) = Failure._;

  final _ResultType _type;

  /// Checks if the result is a [Success].
  bool get isSuccess => _type == _ResultType.success;

  /// Check if the result is a [Failure].
  bool get isFailure => _type == _ResultType.failure;
}

/// Represents successful result.
class Success<T> extends Result<T> {
  const Success._(this.data) : super._(_ResultType.success);

  /// The [T] data associated with the result.
  final T data;

  @override
  List<Object?> get props => [data];

  @override
  String toString() {
    return 'Result.Success{data: $data}';
  }
}

/// Represents failed result.
class Failure extends Result<Never> {
  const Failure._(this.error, [this.stackTrace]) : super._(_ResultType.failure);

  /// The [error] associated with the result.
  final Object error;

  /// The [stackTrace] associated with the result.
  final StackTrace? stackTrace;

  @override
  List<Object?> get props => [error, stackTrace];

  @override
  String toString() {
    return 'Result.Failure{error: $error, stackTrace: $stackTrace}';
  }
}

extension PatternMatching<T> on Result<T> {
  /// The [when] method is the equivalent to pattern matching.
  /// Its prototype depends on the _Result [_type]s defined.
  R when<R extends Object?>({
    required R Function(T data) success,
    required R Function(Object error) failure,
  }) {
    switch (_type) {
      case _ResultType.success:
        return success((this as Success<T>).data);
      case _ResultType.failure:
        return failure((this as Failure).error);
    }
  }

  /// The [whenOrElse] method is equivalent to [when], but doesn't require
  /// all callbacks to be specified.
  ///
  /// On the other hand, it adds an extra orElse required parameter,
  /// for fallback behavior.
  R whenOrElse<R extends Object>({
    R Function(T data)? success,
    R Function(Object error)? failure,
    required R Function(Result<T>) orElse,
  }) {
    switch (_type) {
      case _ResultType.success:
        return success?.call((this as Success<T>).data) ?? orElse(this);
      case _ResultType.failure:
        return failure?.call((this as Failure).error) ?? orElse(this);
    }
  }

  /// The [whenOrNull] method is equivalent to [whenOrElse],
  /// but non-exhaustive.
  R? whenOrNull<R extends Object?>({
    R Function(T data)? success,
    R Function(Object error)? failure,
  }) {
    switch (_type) {
      case _ResultType.success:
        return success?.call((this as Success<T>).data);
      case _ResultType.failure:
        return failure?.call((this as Failure).error);
    }
  }

  /// The [map] method is the equivalent to pattern matching.
  /// Its prototype depends on the _Result [_type]s defined.
  Result<R> map<R>(R Function(T data) convert) {
    switch (_type) {
      case _ResultType.success:
        final origin = this as Success<T>;
        return Result.success(convert(origin.data));
      case _ResultType.failure:
        return this as Failure;
    }
  }

  /// The [fold] method is the equivalent to pattern matching.
  /// Its prototype depends on the _Result [_type]s defined.
  R fold<R extends Object?>({
    required R Function(Success<T> success) success,
    required R Function(Failure failure) failure,
  }) {
    switch (_type) {
      case _ResultType.success:
        return success(this as Success<T>);
      case _ResultType.failure:
        return failure(this as Failure);
    }
  }

  /// The [foldOrElse] method is equivalent to [fold], but doesn't require
  /// all callbacks to be specified.
  ///
  /// On the other hand, it adds an extra orElse required parameter,
  /// for fallback behavior.
  R foldOrElse<R extends Object>({
    R Function(Success<T> success)? success,
    R Function(Failure failure)? failure,
    required R Function(Result<T>) orElse,
  }) {
    switch (_type) {
      case _ResultType.success:
        return success?.call(this as Success<T>) ?? orElse(this);
      case _ResultType.failure:
        return failure?.call(this as Failure) ?? orElse(this);
    }
  }

  /// The [foldOrNull] method is equivalent to [whenOrElse],
  /// but non-exhaustive.
  R? foldOrNull<R extends Object?>({
    R Function(Success<T> success)? success,
    R Function(Failure failure)? failure,
  }) {
    switch (_type) {
      case _ResultType.success:
        return success?.call(this as Success<T>);
      case _ResultType.failure:
        return failure?.call(this as Failure);
    }
  }

  /// Returns the encapsulated value if this instance represents success
  /// or null of it is failure.
  T? getDataOrNull() => whenOrNull(success: _identity);

  Object? getErrorOrNull() => whenOrNull(failure: _identity);
}

T _identity<T>(T x) => x;
