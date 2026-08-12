class Formatters {
  static String rating(double value) => value.toStringAsFixed(1);

  static String year(String? releaseDate) {
    if (releaseDate == null || releaseDate.isEmpty) return '—';
    return releaseDate.length >= 4
        ? releaseDate.substring(0, 4)
        : releaseDate;
  }

  static String runtime(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m}m';
    return '${h}h ${m}m';
  }

  static String votes(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}
