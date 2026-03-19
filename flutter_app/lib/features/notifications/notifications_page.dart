import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_state_provider.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(appStateProvider.notifier).fetchNotifications());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(appStateProvider.notifier).fetchNotifications(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (state.loading) const LinearProgressIndicator(),
          ...state.notifications.map(
            (n) => Card(
              child: ListTile(
                title: Text(n.title),
                subtitle: Text(n.message),
                trailing: n.isRead
                    ? const Icon(Icons.done_all)
                    : IconButton(
                        icon: const Icon(Icons.mark_email_read_outlined),
                        onPressed: () => ref.read(appStateProvider.notifier).markNotificationRead(n.id),
                      ),
              ),
            ),
          ),
          if (state.notifications.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('No notifications yet'),
              ),
            ),
        ],
      ),
    );
  }
}
