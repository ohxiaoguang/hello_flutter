/// 应用版本信息
class Version {
  /// 当前版本号
  static const String version = '0.1.10';
  
  /// 构建时间
  static const String buildDate = '2024-11-18';
  
  /// 版本历史
  static const List<Map<String, String>> history = [
    {
      'version': 'v0.1.10',
      'date': '2024-11-18',
      'description': '完善发布工作流',
      'platforms': 'macOS, Windows, Linux, iOS',
    },
    {
      'version': 'v0.1.9',
      'date': '2024-11-18',
      'description': '修复 iOS 构建问题',
      'platforms': 'iOS',
    },
    {
      'version': 'v0.1.8',
      'date': '2024-11-18',
      'description': '初始版本',
      'platforms': 'Android',
    },
  ];
  
  /// 获取版本更新说明
  static String getVersionDescription(String version) {
    final versionInfo = history.firstWhere(
      (v) => v['version'] == version,
      orElse: () => {'description': '无更新说明'},
    );
    return versionInfo['description'] ?? '无更新说明';
  }
}
