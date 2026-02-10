import '../database/db_helper.dart';
import '../models/leave_model.dart';

/// Service for driver leave management.
class LeaveService {
  final _db = DBHelper.instance;

  Future<int> applyLeave(LeaveModel leave) =>
      _db.insert('leaves', leave.toMap());

  Future<List<LeaveModel>> getLeavesForDriver(int driverId) async {
    final rows = await _db.queryWhere('leaves', 'driverId = ?', [driverId]);
    return rows.map(LeaveModel.fromMap).toList();
  }

  Future<List<LeaveModel>> getAllLeaves() async {
    final rows = await _db.queryAll('leaves');
    return rows.map(LeaveModel.fromMap).toList();
  }

  Future<List<LeaveModel>> getPendingLeaves() async {
    final rows = await _db.queryWhere('leaves', 'status = ?', ['pending']);
    return rows.map(LeaveModel.fromMap).toList();
  }

  Future<void> updateLeaveStatus(int leaveId, String status) async {
    await _db.update('leaves', {'status': status}, 'id = ?', [leaveId]);
  }
}
