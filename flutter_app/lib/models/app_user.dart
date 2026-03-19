class AppUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final String token;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.token,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      token: json['token'] as String,
    );
  }
}
