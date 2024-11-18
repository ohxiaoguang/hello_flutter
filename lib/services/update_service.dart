import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import '../version.dart';

class UpdateService {
  static const String owner = 'ohxiaoguang';
  static const String repo = 'hello_flutter';
  
  /// 是否使用模拟数据（用于测试）
  static const bool useMockData = true;
  
  /// 检查更新
  static Future<UpdateInfo?> checkUpdate() async {
    if (useMockData) {
      // 使用模拟数据进行测试
      await Future.delayed(const Duration(seconds: 1)); // 模拟网络延迟
      
      // 模拟一个新版本
      if (Version.version != '0.2.0') {
        return UpdateInfo(
          version: 'v0.2.0',
          description: '''
## 新版本 v0.2.0 更新内容：

1. 新功能
   - 添加深色模式支持
   - 新增设置页面
   - 支持自动检查更新

2. 改进
   - 优化界面布局
   - 提升性能表现
   - 改进错误提示

3. 修复
   - 修复已知问题
   - 提高稳定性
''',
          downloadUrl: 'https://github.com/$owner/$repo/releases/tag/v0.2.0',
          assets: [
            AssetInfo(
              name: 'hello_flutter-v0.2.0-macos.dmg',
              downloadUrl: 'https://github.com/$owner/$repo/releases/download/v0.2.0/hello_flutter-v0.2.0-macos.dmg',
              size: 24 * 1024 * 1024, // 24MB
            ),
            AssetInfo(
              name: 'hello_flutter-v0.2.0-windows.exe',
              downloadUrl: 'https://github.com/$owner/$repo/releases/download/v0.2.0/hello_flutter-v0.2.0-windows.exe',
              size: 32 * 1024 * 1024, // 32MB
            ),
          ],
        );
      }
      return null; // 没有新版本
    }

    try {
      // 创建自定义的 HttpClient 以处理证书问题
      final client = HttpClient()
        ..badCertificateCallback = (cert, host, port) => true;
      
      final request = await client.getUrl(
        Uri.parse('https://api.github.com/repos/$owner/$repo/releases/latest')
      );
      
      // 添加必要的请求头
      request.headers.add('Accept', 'application/vnd.github.v3+json');
      request.headers.add('User-Agent', 'Flutter App');
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        final latestVersion = data['tag_name'] as String;
        final currentVersion = 'v${Version.version}';

        // 比较版本号
        if (_isNewerVersion(latestVersion, currentVersion)) {
          return UpdateInfo(
            version: latestVersion,
            description: data['body'] ?? '无更新说明',
            downloadUrl: data['html_url'] ?? '',
            assets: _parseAssets(data['assets'] ?? []),
          );
        }
      } else {
        throw HttpException('GitHub API 返回错误: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      throw Exception('网络连接失败，请检查网络设置: $e');
    } on TimeoutException catch (e) {
      throw Exception('请求超时，请稍后重试: $e');
    } on FormatException catch (e) {
      throw Exception('响应格式错误: $e');
    } catch (e) {
      throw Exception('检查更新失败: $e');
    }
    return null;
  }

  /// 比较版本号
  static bool _isNewerVersion(String latest, String current) {
    // 移除 'v' 前缀
    latest = latest.startsWith('v') ? latest.substring(1) : latest;
    current = current.startsWith('v') ? current.substring(1) : current;

    final latestParts = latest.split('.').map(int.parse).toList();
    final currentParts = current.split('.').map(int.parse).toList();

    for (var i = 0; i < 3; i++) {
      final latestPart = latestParts[i];
      final currentPart = currentParts[i];
      if (latestPart > currentPart) return true;
      if (latestPart < currentPart) return false;
    }
    return false;
  }

  /// 解析下载资源
  static List<AssetInfo> _parseAssets(List<dynamic> assets) {
    return assets.map((asset) => AssetInfo(
      name: asset['name'] as String,
      downloadUrl: asset['browser_download_url'] as String,
      size: asset['size'] as int,
    )).toList();
  }
}

/// 更新信息
class UpdateInfo {
  final String version;
  final String description;
  final String downloadUrl;
  final List<AssetInfo> assets;

  UpdateInfo({
    required this.version,
    required this.description,
    required this.downloadUrl,
    required this.assets,
  });
}

/// 下载资源信息
class AssetInfo {
  final String name;
  final String downloadUrl;
  final int size;

  AssetInfo({
    required this.name,
    required this.downloadUrl,
    required this.size,
  });
}
