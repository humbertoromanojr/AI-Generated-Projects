import 'cast_member.dart';
import 'crew_member.dart';

class MovieCredits {
  final List<CastMember> cast;
  final List<CrewMember> crew;

  const MovieCredits({
    required this.cast,
    required this.crew,
  });

  CrewMember? get director {
    for (final member in crew) {
      if (member.job == 'Director') return member;
    }
    return null;
  }
}
