class Profile {
  final String id;
  final String? fullName;
  final String role;
  final String section;
  final bool active;
  final String? shift;

  Profile({
    required this.id,
    this.fullName,
    required this.role,
    required this.section,
    required this.active,
    this.shift,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      fullName: json['full_name'],
      role: json['role'],
      section: json['section'],
      active: json['active'],
      shift: json['shift'],
    );
  }
}
