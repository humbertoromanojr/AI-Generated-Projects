class RatingFormatter {
  const RatingFormatter._();

  static String label(double rating) {
    return rating.toStringAsFixed(1);
  }

  static double toFiveStars(double rating) {
    return rating / 2;
  }

  static String votes(int voteCount) {
    if (voteCount >= 1000000) {
      final value = voteCount / 1000000;
      return '${value.toStringAsFixed(1).replaceAll('.', ',')} mi';
    }
    if (voteCount >= 1000) {
      final value = voteCount / 1000;
      return '${value.toStringAsFixed(1).replaceAll('.', ',')} mil';
    }
    return '$voteCount';
  }
}
