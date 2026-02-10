import '../models/leave_model.dart';
import 'api_client.dart';

/// Service for driver leave management via REST API.
class LeaveService {
  final _api = ApiClient.instance;

  Future<LeaveModel> applyLeave(LeaveModel leave) async {
    final res = await _api.post('/leaves', leave.toMap());
    return LeaveModel.fromMap(res as Map<String, dynamic>);
  }

  Future<List<LeaveModel>> getLeavesForDriver(String driverId) async {
    final res = await _api.get('/leaves?driverId=$driverId') as List;
    return res
        .map((e) => LeaveModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<LeaveModel>> getAllLeaves() async {
    final res = await _api.get('/leaves') as List;
    return res
        .map((e) => LeaveModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<LeaveModel>> getPendingLeaves() async {
    final res = await _api.get('/leaves?status=pending') as List;
    return res
        .map((e) => LeaveModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateLeaveStatus(String leaveId, String status) async {
    await _api.put('/leaves/$leaveId', {'status': status});
  }
}
