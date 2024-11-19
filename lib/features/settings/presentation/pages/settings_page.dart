import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/settings_state.dart';
import '../../../update/services/update_service.dart';
import '../../../update/presentation/widgets/update_dialog.dart';
import '../../../../version.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('设置', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 20),
          
          // 版本信息
          Card(
            child: ListTile(
              title: const Text('当前版本'),
              subtitle: Text(Version.version),
              trailing: TextButton(
                onPressed: () => _checkUpdate(context),
                child: const Text('检查更新'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // 自动更新设置
          Card(
            child: Consumer<SettingsState>(
              builder: (context, settings, child) {
                return SwitchListTile(
                  title: const Text('自动检查更新'),
                  subtitle: const Text('启动时自动检查新版本'),
                  value: settings.autoUpdate,
                  onChanged: (bool value) {
                    settings.setAutoUpdate(value);
                  },
                );
              },
            ),
          ),
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
