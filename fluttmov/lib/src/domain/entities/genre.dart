class Genre {
  final int id;
  final String name;

  const Genre({
    required this.id,
    required this.name,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Genre && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);
}
