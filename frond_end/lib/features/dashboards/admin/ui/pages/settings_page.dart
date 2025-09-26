// lib/features/dashboards/admin/ui/pages/settings_page.dart
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _dark = false;
  bool _notif = true;

  @override
  Widget build(BuildContext context) {
    final h = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Text('Settings', style: h.headlineSmall),
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Use dark theme for admin UI'),
              value: _dark,
              onChanged: (v) => setState(() => _dark = v),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: SwitchListTile(
              title: const Text('Notifications'),
              subtitle: const Text('Enable admin notifications'),
              value: _notif,
              onChanged: (v) => setState(() => _notif = v),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Security'),
              subtitle: const Text('Password & 2FA'),
              trailing: FilledButton(
                onPressed: () {},
                child: const Text('Manage'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
