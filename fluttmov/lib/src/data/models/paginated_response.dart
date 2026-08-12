class PaginatedResponse<T> {
  final int page;
  final int totalPages;
  final List<T> results;

  const PaginatedResponse({
    required this.page,
    required this.totalPages,
    required this.results,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return PaginatedResponse(
      page: json['page'] as int? ?? 1,
      totalPages: json['total_pages'] as int? ?? 1,
      results: (json['results'] as List<dynamic>? ?? const [])
          .map((item) => fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
