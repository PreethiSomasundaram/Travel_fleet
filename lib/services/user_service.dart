import '../database/db_helper.dart';
import '../models/user_model.dart';

/// Service for user authentication and CRUD.
class UserService {
  final _db = DBHelper.instance;

  /// Authenticate a user by username and password.
  /// Returns the [UserModel] on success, `null` on failure.
  Future<UserModel?> login(String username, String password) async {
    final rows = await _db.queryWhere(
      'users',
      'username = ? AND password = ?',
      [username, password],
    );
    if (rows.isEmpty) return null;
    return UserModel.fromMap(rows.first);
  }

  Future<int> addUser(UserModel user) => _db.insert('users', user.toMap());

  Future<int> updateUser(UserModel user) =>
      _db.update('users', user.toMap(), 'id = ?', [user.id]);

  Future<int> deleteUser(int id) => _db.delete('users', 'id = ?', [id]);

  Future<List<UserModel>> getAllUsers() async {
    final rows = await _db.queryAll('users');
    return rows.map(UserModel.fromMap).toList();
  }

  Future<List<UserModel>> getUsersByRole(String role) async {
    final rows = await _db.queryWhere('users', 'role = ?', [role]);
    return rows.map(UserModel.fromMap).toList();
  }

  Future<UserModel?> getUserById(int id) async {
    final rows = await _db.queryWhere('users', 'id = ?', [id]);
    if (rows.isEmpty) return null;
    return UserModel.fromMap(rows.first);
  }
}
