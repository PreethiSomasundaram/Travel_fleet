import '../models/user_model.dart';
import 'api_client.dart';

/// Service for user authentication and CRUD via REST API.
class UserService {
  final _api = ApiClient.instance;

  /// Authenticate a user by username and password.
  /// Returns the [UserModel] on success, `null` on failure.
  /// Also stores the JWT token for future requests.
  Future<UserModel?> login(String username, String password) async {
    try {
      final res = await _api.post('/auth/login', {
        'username': username,
        'password': password,
      });
      await _api.saveToken(res['token'] as String);
      return UserModel.fromMap(res['user'] as Map<String, dynamic>);
    } on ApiException {
      return null;
    }
  }

  /// Register a new user (owner/employee only).
  Future<UserModel> addUser(UserModel user) async {
    final res = await _api.post('/auth/register', user.toMap());
    return UserModel.fromMap(res as Map<String, dynamic>);
  }

  Future<void> deleteUser(String id) async {
    await _api.delete('/auth/users/$id');
  }

  Future<List<UserModel>> getAllUsers() async {
    final res = await _api.get('/auth/users') as List;
    return res
        .map((e) => UserModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<UserModel>> getUsersByRole(String role) async {
    final res = await _api.get('/auth/users?role=$role') as List;
    return res
        .map((e) => UserModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<UserModel?> getUserById(String id) async {
    try {
      final res = await _api.get('/auth/users/$id');
      return UserModel.fromMap(res as Map<String, dynamic>);
    } on ApiException {
      return null;
    }
  }

  /// Logout – clears stored token.
  Future<void> logout() async {
    await _api.clearToken();
  }
}
