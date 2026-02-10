/// Represents a driver's leave request.
class LeaveModel {
  final int? id;
  final int driverId;
  final String date; // ISO-8601
  final String leaveType; // full_day | half_day
  final String status; // pending | approved | rejected
  final String? reason;

  LeaveModel({
    this.id,
    required this.driverId,
    required this.date,
    required this.leaveType,
    this.status = 'pending',
    this.reason,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'driverId': driverId,
    'date': date,
    'leaveType': leaveType,
    'status': status,
    'reason': reason,
  };

  factory LeaveModel.fromMap(Map<String, dynamic> map) => LeaveModel(
    id: map['id'] as int?,
    driverId: map['driverId'] as int,
    date: map['date'] as String,
    leaveType: map['leaveType'] as String,
    status: map['status'] as String? ?? 'pending',
    reason: map['reason'] as String?,
  );
}
