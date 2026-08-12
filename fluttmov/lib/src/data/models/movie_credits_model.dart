import '../../domain/entities/movie_credits.dart';
import 'cast_model.dart';
import 'crew_model.dart';

class MovieCreditsModel extends MovieCredits {
  const MovieCreditsModel({required super.cast, required super.crew});

  factory MovieCreditsModel.fromJson(Map<String, dynamic> json) {
    return MovieCreditsModel(
      cast: (json['cast'] as List<dynamic>? ?? const [])
          .map((e) => CastModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      crew: (json['crew'] as List<dynamic>? ?? const [])
          .map((e) => CrewModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
