import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../providers/theme_mode_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    final auth = ref.read(authProvider);
    final payload = <String, dynamic>{};

    final trimmedName = _name.text.trim();
    final trimmedEmail = _email.text.trim();
    final password = _password.text;

    if (trimmedName.isNotEmpty && trimmedName != (auth.name ?? '')) {
      payload['name'] = trimmedName;
    }

    if (trimmedEmail.isNotEmpty && trimmedEmail != (auth.email ?? '')) {
      payload['email'] = trimmedEmail;
    }

    if (password.isNotEmpty) {
      payload['password'] = password;
    }

    if (payload.isEmpty) {
      _show('No profile changes to update');
      return;
    }

    await ref.read(authProvider.notifier).updateProfile(payload);
    _password.clear();
    _show('Profile updated');
  }

  void _show(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final themeMode = ref.watch(themeModeProvider);

    if (!_initialized) {
      _name.text = auth.name ?? '';
      _email.text = auth.email ?? '';
      _initialized = true;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Profile Settings', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                TextField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'New Password (optional)'),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: auth.loading ? null : _updateProfile,
                  child: auth.loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Update Profile'),
                ),
                if (auth.error != null) ...[
                  const SizedBox(height: 8),
                  Text(auth.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Appearance', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(value: ThemeMode.system, label: Text('System'), icon: Icon(Icons.settings_suggest)),
                    ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(Icons.light_mode)),
                    ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode)),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: (selection) {
                    final selectedMode = selection.first;
                    ref.read(themeModeProvider.notifier).setThemeMode(selectedMode);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
