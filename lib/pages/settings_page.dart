import 'package:flutter/material.dart';
import '../version.dart';
import '../services/update_service.dart';
import '../widgets/update_dialog.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '设置',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('当前版本'),
              subtitle: Text('v${Version.version} (${Version.buildDate})'),
              trailing: TextButton.icon(
                icon: const Icon(Icons.system_update),
                label: const Text('检查更新'),
                onPressed: () => _checkUpdate(context),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 这里可以添加更多设置项
        ],
      ),
    );
  }

  Future<void> _checkUpdate(BuildContext context) async {
    try {
      final updateInfo = await UpdateService.checkUpdate();
      if (updateInfo != null && context.mounted) {
        showDialog(
          context: context,
          builder: (context) => UpdateDialog(updateInfo: updateInfo),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已是最新版本'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('检查更新失败: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
