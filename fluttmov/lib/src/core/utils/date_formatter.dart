class DateFormatter {
  const DateFormatter._();

  static const List<String> _months = [
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];

  static String year(DateTime? date) {
    if (date == null) return '';
    return '${date.year}';
  }

  static String full(DateTime? date) {
    if (date == null) return '';
    return '${date.day} de ${_months[date.month - 1]} de ${date.year}';
  }

  static String duration(int? minutes) {
    if (minutes == null || minutes <= 0) return '';
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    if (hours == 0) return '${rest}m';
    return '${hours}h ${rest}m';
  }
}
