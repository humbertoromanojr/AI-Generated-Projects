import '../../domain/entities/genre.dart';

class GenreModel {
  final int id;
  final String name;

  const GenreModel({required this.id, required this.name});

  factory GenreModel.fromJson(Map<String, dynamic> json) {
    return GenreModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
    );
  }

  Genre toEntity() => Genre(id: id, name: name);
}
