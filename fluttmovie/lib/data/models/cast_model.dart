import '../../core/utils/image_urls.dart';
import '../../domain/entities/cast_member.dart';

class CastModel {
  final String name;
  final String character;
  final String? profilePath;

  const CastModel({
    required this.name,
    this.character = '',
    this.profilePath,
  });

  factory CastModel.fromJson(Map<String, dynamic> json) {
    return CastModel(
      name: json['name'] as String? ?? '',
      character: json['character'] as String? ?? '',
      profilePath: json['profile_path'] as String?,
    );
  }

  CastMember toEntity() => CastMember(
        name: name,
        character: character,
        profileUrl: TmdbImageUrls.profile(profilePath),
      );
}
