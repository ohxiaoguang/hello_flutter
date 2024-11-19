import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import '../../services/update_service.dart';

class UpdateDialog extends StatefulWidget {
  final UpdateInfo updateInfo;

  const UpdateDialog({Key? key, required this.updateInfo}) : super(key: key);

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  String? _error;

  Future<void> _handleUpdate() async {
    try {
      final url = Uri.parse(widget.updateInfo.htmlUrl);
      if (await url_launcher.canLaunchUrl(url)) {
        await url_launcher.launchUrl(url);
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        setState(() {
          _error = '无法打开浏览器';
        });
      }
    } catch (e) {
      debugPrint('打开链接失败: $e');
      setState(() {
        _error = '打开链接失败: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('发现新版本'),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('新版本: ${widget.updateInfo.version}'),
            const SizedBox(height: 8),
            Text(widget.updateInfo.releaseNotes),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _handleUpdate,
          child: const Text('前往下载页面'),
        ),
      ],
    );
  }
}
