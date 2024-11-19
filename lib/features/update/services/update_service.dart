import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:path_provider/path_provider.dart';
import '../../../version.dart';

class UpdateInfo {
  final String version;
  final String downloadUrl;
  final String? appStoreUrl;
  final String? playStoreUrl;
  final String releaseNotes;
  final bool forceUpdate;
  final int? assetSize;  
  final String? assetName; 
  final String htmlUrl;  // GitHub release page URL

  UpdateInfo({
    required this.version,
    required this.downloadUrl,
    this.appStoreUrl,
    this.playStoreUrl,
    required this.releaseNotes,
    this.forceUpdate = false,
    this.assetSize,
    this.assetName,
    required this.htmlUrl,
  });

  @override
  String toString() {
    return 'UpdateInfo(version: $version, downloadUrl: $downloadUrl, assetName: $assetName, assetSize: $assetSize, htmlUrl: $htmlUrl)';
  }
}

typedef DownloadProgressCallback = void Function(int received, int total);

class UpdateService {
  static const String _baseUrl = 'https://api.github.com/repos/ohxiaoguang/hello_flutter';

  static Future<UpdateInfo?> checkUpdate() async {
    try {
      debugPrint('正在检查更新...');
      final response = await http.get(
        Uri.parse('$_baseUrl/releases/latest'),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
        },
      );
      
      debugPrint('API响应状态码: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('Release数据: ${json.encode(data)}');
        
        final latestVersion = data['tag_name'].toString().replaceAll('v', '');
        debugPrint('最新版本: $latestVersion, 当前版本: ${Version.version}');

        if (_shouldUpdate(Version.version, latestVersion)) {
          final releaseNotes = data['body'] ?? '';
          final htmlUrl = data['html_url'] ?? '';  // GitHub release page URL
          
          if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
            // PC平台
            final assets = data['assets'] as List;
            debugPrint('可用资源: ${assets.map((e) => e['name']).toList()}');
            
            for (var asset in assets) {
              final name = asset['name'].toString().toLowerCase();
              debugPrint('检查资源: $name');
              
              if (_isCurrentPlatformAsset(name)) {
                final downloadUrl = asset['browser_download_url'].toString();
                final size = asset['size'] as int;
                debugPrint('找到匹配的资源: $name, 大小: $size bytes, URL: $downloadUrl');
                
                return UpdateInfo(
                  version: latestVersion,
                  downloadUrl: downloadUrl,
                  releaseNotes: releaseNotes,
                  assetSize: size,
                  assetName: asset['name'].toString(),
                  htmlUrl: htmlUrl,
                );
              }
            }
            debugPrint('未找到当前平台的安装包');
          } else {
            return UpdateInfo(
              version: latestVersion,
              downloadUrl: '',  // 不再需要下载 URL
              releaseNotes: releaseNotes,
              htmlUrl: htmlUrl,
            );
          }
        } else {
          debugPrint('当前已是最新版本');
        }
      }
      return null;
    } catch (e, stackTrace) {
      debugPrint('检查更新失败: $e');
      debugPrint('堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  static Future<String> downloadUpdate(String url, DownloadProgressCallback onProgress, String targetPath) async {
    debugPrint('开始下载更新: $url');
    debugPrint('目标路径: $targetPath');
    
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(url));
      request.headers.add('Accept', 'application/octet-stream');
      debugPrint('发送下载请求...');
      
      final response = await request.close();
      debugPrint('下载响应状态码: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        throw HttpException('下载失败: HTTP ${response.statusCode}');
      }

      final contentLength = response.contentLength;
      debugPrint('文件大小: $contentLength bytes');
      
      int received = 0;
      final file = File(targetPath);
      final sink = file.openWrite();

      debugPrint('开始写入文件...');
      await for (var chunk in response) {
        sink.add(chunk);
        received += chunk.length;
        onProgress(received, contentLength);
      }

      await sink.close();
      debugPrint('文件下载完成');
      
      // 验证文件大小
      final downloadedFile = File(targetPath);
      final fileSize = await downloadedFile.length();
      debugPrint('下载文件大小: $fileSize bytes');
      
      if (fileSize != contentLength) {
        throw Exception('文件大小不匹配: 预期 $contentLength bytes, 实际 $fileSize bytes');
      }

      return targetPath;
    } catch (e, stackTrace) {
      debugPrint('下载失败: $e');
      debugPrint('堆栈跟踪: $stackTrace');
      
      // 如果下载失败，删除可能不完整的文件
      final file = File(targetPath);
      if (await file.exists()) {
        await file.delete();
      }
      
      rethrow;
    } finally {
      client.close();
    }
  }

  static bool _shouldUpdate(String currentVersion, String latestVersion) {
    final current = currentVersion.split('.').map(int.parse).toList();
    final latest = latestVersion.split('.').map(int.parse).toList();

    for (var i = 0; i < current.length && i < latest.length; i++) {
      if (latest[i] > current[i]) return true;
      if (latest[i] < current[i]) return false;
    }

    return latest.length > current.length;
  }

  static bool _isCurrentPlatformAsset(String assetName) {
    if (Platform.isWindows) {
      return assetName.endsWith('.exe') || assetName.endsWith('.zip');
    } else if (Platform.isMacOS) {
      return assetName.endsWith('.dmg') || assetName.endsWith('.zip');
    } else if (Platform.isLinux) {
      return assetName.endsWith('.deb') || assetName.endsWith('.AppImage') || assetName.endsWith('.zip');
    }
    return false;
  }
}
