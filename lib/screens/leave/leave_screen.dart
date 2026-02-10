import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/leave_model.dart';
import '../../models/user_model.dart';
import '../../services/leave_service.dart';

/// Leave management screen.
///
/// - Drivers can apply for leave.
/// - Owners see all leaves and can approve / reject.
class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  final _leaveService = LeaveService();
  List<LeaveModel> _leaves = [];
  bool _loading = true;
  UserModel? _user;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _user ??= ModalRoute.of(context)?.settings.arguments as UserModel?;
    _load();
  }

  Future<void> _load() async {
    List<LeaveModel> leaves;
    if (_user != null && _user!.role == AppConstants.roleDriver) {
      leaves = await _leaveService.getLeavesForDriver(_user!.id!);
    } else {
      leaves = await _leaveService.getAllLeaves();
    }
    setState(() {
      _leaves = leaves;
      _loading = false;
    });
  }

  Future<void> _applyLeave() async {
    if (_user == null) return;
    String leaveType = AppConstants.leaveFullDay;
    String? reason;

    await showDialog(
      context: context,
      builder: (ctx) {
        final reasonCtrl = TextEditingController();
        return StatefulBuilder(builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('Apply Leave'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: leaveType,
                  items: const [
                    DropdownMenuItem(value: 'full_day', child: Text('Full Day')),
                    DropdownMenuItem(value: 'half_day', child: Text('Half Day')),
                  ],
                  onChanged: (v) => setDialogState(() => leaveType = v!),
                  decoration: const InputDecoration(labelText: 'Leave Type'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: reasonCtrl,
                  decoration: const InputDecoration(labelText: 'Reason'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  reason = reasonCtrl.text.trim();
                  await _leaveService.applyLeave(LeaveModel(
                    driverId: _user!.id!,
                    date: DateTime.now().toIso8601String().split('T').first,
                    leaveType: leaveType,
                    reason: reason,
                  ));
                  if (ctx.mounted) Navigator.pop(ctx);
                  _load();
                },
                child: const Text('Apply'),
              ),
            ],
          );
        });
      },
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDriver = _user?.role == AppConstants.roleDriver;

    return Scaffold(
      appBar: AppBar(title: const Text('Leave Management')),
      floatingActionButton: isDriver
          ? FloatingActionButton(
              onPressed: _applyLeave,
              child: const Icon(Icons.add),
            )
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _leaves.isEmpty
              ? const Center(child: Text('No leave records'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _leaves.length,
                  itemBuilder: (context, i) {
                    final leave = _leaves[i];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _statusColor(leave.status),
                          child: Text(
                            leave.status[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          '${leave.leaveType == 'full_day' ? 'Full Day' : 'Half Day'} – ${leave.date}',
                        ),
                        subtitle: Text(
                          'Status: ${leave.status.toUpperCase()}'
                          '${leave.reason != null && leave.reason!.isNotEmpty ? '\nReason: ${leave.reason}' : ''}',
                        ),
                        isThreeLine: leave.reason != null && leave.reason!.isNotEmpty,
                        trailing: !isDriver && leave.status == 'pending'
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.check, color: Colors.green),
                                    onPressed: () async {
                                      await _leaveService.updateLeaveStatus(
                                          leave.id!, AppConstants.leaveApproved);
                                      _load();
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, color: Colors.red),
                                    onPressed: () async {
                                      await _leaveService.updateLeaveStatus(
                                          leave.id!, AppConstants.leaveRejected);
                                      _load();
                                    },
                                  ),
                                ],
                              )
                            : null,
                      ),
                    );
                  },
                ),
    );
  }
}
