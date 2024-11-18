import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/update_service.dart';

class UpdateDialog extends StatelessWidget {
  final UpdateInfo updateInfo;

  const UpdateDialog({super.key, required this.updateInfo});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('发现新版本 ${updateInfo.version}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(updateInfo.description),
            const SizedBox(height: 16),
            if (updateInfo.assets.isNotEmpty) ...[
              const Text('下载选项：', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...updateInfo.assets.map((asset) => ListTile(
                title: Text(asset.name),
                subtitle: Text('大小: ${_formatSize(asset.size)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () => _launchUrl(asset.downloadUrl),
                ),
              )),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('稍后再说'),
        ),
        FilledButton(
          onPressed: () => _launchUrl(updateInfo.downloadUrl),
          child: const Text('前往下载'),
        ),
      ],
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}
