/// Represents a user of the Travel Fleet app.
///
/// Roles: `owner`, `employee`, `driver`.
class UserModel {
  final int? id;
  final String name;
  final String phone;
  final String role; // owner | employee | driver
  final String username;
  final String password;

  UserModel({
    this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'phone': phone,
    'role': role,
    'username': username,
    'password': password,
  };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    id: map['id'] as int?,
    name: map['name'] as String,
    phone: map['phone'] as String,
    role: map['role'] as String,
    username: map['username'] as String,
    password: map['password'] as String,
  );

  UserModel copyWith({
    int? id,
    String? name,
    String? phone,
    String? role,
    String? username,
    String? password,
  }) =>
      UserModel(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        role: role ?? this.role,
        username: username ?? this.username,
        password: password ?? this.password,
      );
}
