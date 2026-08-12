import '../../domain/entities/cast_member.dart';

class CastModel extends CastMember {
  const CastModel({
    required super.id,
    required super.name,
    required super.character,
    required super.profilePath,
  });

  factory CastModel.fromEntity(CastMember member) {
    return CastModel(
      id: member.id,
      name: member.name,
      character: member.character,
      profilePath: member.profilePath,
    );
  }

  factory CastModel.fromJson(Map<String, dynamic> json) {
    return CastModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      character: json['character'] as String? ?? '',
      profilePath: json['profile_path'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'character': character,
        'profile_path': profilePath,
      };
}
