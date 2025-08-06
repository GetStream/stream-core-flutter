import 'package:equatable/equatable.dart';

class PaginationResult<T> {
  const PaginationResult({
    required this.items,
    required this.pagination,
  });

  final List<T> items;
  final PaginationData pagination;
}

class PaginationData extends Equatable {
  const PaginationData({
    this.next,
    this.previous,
  });

  /// Item id of where to start searching from for next results
  final String? next;

  /// Item id of where to start searching from for previous results
  final String? previous;

  @override
  List<Object?> get props => [next, previous];
}
