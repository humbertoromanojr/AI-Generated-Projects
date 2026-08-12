import '../../domain/entities/crew_member.dart';

class CrewModel extends CrewMember {
  const CrewModel({
    required super.id,
    required super.name,
    required super.job,
    required super.profilePath,
  });

  factory CrewModel.fromEntity(CrewMember member) {
    return CrewModel(
      id: member.id,
      name: member.name,
      job: member.job,
      profilePath: member.profilePath,
    );
  }

  factory CrewModel.fromJson(Map<String, dynamic> json) {
    return CrewModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      job: json['job'] as String? ?? '',
      profilePath: json['profile_path'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'job': job,
        'profile_path': profilePath,
      };
}
