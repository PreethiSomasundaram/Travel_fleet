import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/app_state_provider.dart';
import '../../providers/auth_provider.dart';

class DriversPage extends ConsumerStatefulWidget {
  const DriversPage({super.key});

  @override
  ConsumerState<DriversPage> createState() => _DriversPageState();
}

class _DriversPageState extends ConsumerState<DriversPage> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _license = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _leaveReason = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(appStateProvider.notifier).fetchDrivers());
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _license.dispose();
    _email.dispose();
    _password.dispose();
    _leaveReason.dispose();
    super.dispose();
  }

  Future<void> _createDriver() async {
    if (_name.text.trim().isEmpty || _phone.text.trim().isEmpty || _license.text.trim().isEmpty) {
      _show('Name, phone and license are required');
      return;
    }

    final hasLogin = _email.text.trim().isNotEmpty || _password.text.isNotEmpty;
    if (hasLogin && (_email.text.trim().isEmpty || _password.text.isEmpty)) {
      _show('Enter both email and password to create unique driver login');
      return;
    }

    await ref.read(appStateProvider.notifier).createDriver({
      'name': _name.text.trim(),
      'phone': _phone.text.trim(),
      'licenseNumber': _license.text.trim(),
      'salaryPerDay': 1000,
      'bataRate': 300,
      if (hasLogin) 'email': _email.text.trim(),
      if (hasLogin) 'password': _password.text,
    });

    _name.clear();
    _phone.clear();
    _license.clear();
    _email.clear();
    _password.clear();
  }

  void _show(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _applyLeave(String driverId) async {
    final now = DateTime.now();
    final from = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
    );

    if (from == null || !mounted) return;

    final to = await showDatePicker(
      context: context,
      initialDate: from,
      firstDate: from,
      lastDate: from.add(const Duration(days: 90)),
    );

    if (to == null || !mounted) return;

    _leaveReason.clear();

    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Reason'),
        content: TextField(
          controller: _leaveReason,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Reason'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, _leaveReason.text.trim()),
            child: const Text('Apply'),
          ),
        ],
      ),
    );

    if (reason == null || reason.isEmpty) {
      _show('Leave reason is required');
      return;
    }

    await ref.read(appStateProvider.notifier).applyDriverLeave(driverId, from: from, to: to, reason: reason);
    _show('Leave request submitted');
  }

  Future<void> _approveLeave(String driverId, String leaveId, String status) async {
    await ref.read(appStateProvider.notifier).approveDriverLeave(driverId, leaveId: leaveId, status: status);
    _show('Leave marked as $status');
  }

  Future<void> _showPayroll(String driverId) async {
    final payroll = await ref.read(appStateProvider.notifier).fetchDriverPayroll(driverId);
    if (!mounted) return;

    String asMoney(dynamic value) {
      final numVal = (value as num?)?.toDouble() ?? 0;
      return numVal.toStringAsFixed(2);
    }

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Payroll • ${payroll['driverName'] ?? ''}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Working Days: ${payroll['totalWorkingDays'] ?? 0}'),
            Text('Working Hours: ${asMoney(payroll['totalWorkingHours'])}'),
            Text('Completed Trips: ${payroll['totalTripsCompleted'] ?? 0}'),
            const SizedBox(height: 8),
            Text('Salary by Days: ${asMoney(payroll['salaryFromDays'])}'),
            Text('Salary by Hours: ${asMoney(payroll['salaryFromHours'])}'),
            Text('Trip Salary: ${asMoney(payroll['tripSalary'])}'),
            Text('Credited Bata: ${asMoney(payroll['totalBata'])}'),
            const Divider(),
            Text('Estimated Base: ${asMoney(payroll['estimatedSalary'])}'),
            Text('Gross Payable: ${asMoney(payroll['grossPayable'])}'),
            const SizedBox(height: 8),
            Text('Approved Leaves: ${payroll['approvedLeaveCount'] ?? 0}'),
            Text('Pending Leaves: ${payroll['pendingLeaveCount'] ?? 0}'),
          ],
        ),
        actions: [
          FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final auth = ref.watch(authProvider);
    final role = auth.role;
    final dateFmt = DateFormat('dd MMM yyyy');
    final visibleDrivers = role == 'driver'
        ? state.drivers.where((d) => d.loginEmail != null && d.loginEmail == auth.email).toList()
        : state.drivers;

    return RefreshIndicator(
      onRefresh: () => ref.read(appStateProvider.notifier).fetchDrivers(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (role == 'owner' || role == 'employee')
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Add Driver', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    TextField(controller: _name, decoration: const InputDecoration(labelText: 'Driver Name')),
                    TextField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone')),
                    TextField(controller: _license, decoration: const InputDecoration(labelText: 'License Number')),
                    if (role == 'owner') ...[
                      const SizedBox(height: 8),
                      Text('Optional login for this driver', style: Theme.of(context).textTheme.titleSmall),
                      TextField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Driver Login Email'),
                      ),
                      TextField(
                        controller: _password,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Driver Login Password'),
                      ),
                    ],
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _createDriver,
                      child: const Text('Save Driver'),
                    ),
                  ],
                ),
              ),
            ),
          if (state.loading) const LinearProgressIndicator(),
          ...visibleDrivers.map(
            (d) => Card(
              child: ListTile(
                title: Text(d.name),
                subtitle: Text(
                  'Phone: ${d.phone}\n'
                  'Hours: ${d.totalWorkingHours.toStringAsFixed(1)} • Days: ${d.totalWorkingDays} • Trips: ${d.totalTripsCompleted}\n'
                  'Bata Earned: ${d.totalBataEarned.toStringAsFixed(0)}\n'
                  'Login: ${d.loginEmail ?? 'Not created'}',
                ),
                isThreeLine: true,
                trailing: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if ((role == 'owner' || role == 'employee'))
                      OutlinedButton(
                        onPressed: () => _showPayroll(d.id),
                        child: const Text('Payroll'),
                      ),
                    if ((role == 'driver' && auth.email != null && auth.email == d.loginEmail) || role == 'employee')
                      OutlinedButton(
                        onPressed: () => _applyLeave(d.id),
                        child: const Text('Apply Leave'),
                      ),
                    if (role == 'driver' && auth.email != null && auth.email == d.loginEmail)
                      OutlinedButton(
                        onPressed: () => _showPayroll(d.id),
                        child: const Text('My Earnings'),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (role == 'owner') ...[
            const SizedBox(height: 8),
            Text('Pending Leave Requests', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...state.drivers.expand((d) {
              final pending = d.leaves.where((l) => l.status == 'pending').toList();
              return pending.map(
                (leave) => Card(
                  child: ListTile(
                    title: Text('${d.name} • ${dateFmt.format(leave.from)} to ${dateFmt.format(leave.to)}'),
                    subtitle: Text(leave.reason),
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        TextButton(
                          onPressed: () => _approveLeave(d.id, leave.id, 'rejected'),
                          child: const Text('Reject'),
                        ),
                        FilledButton(
                          onPressed: () => _approveLeave(d.id, leave.id, 'approved'),
                          child: const Text('Approve'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
