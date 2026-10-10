class BlockedAppModel {
  final String packageName;
  final String appName;
  bool isBlocked;

  BlockedAppModel({
    required this.packageName,
    required this.appName,
    this.isBlocked = true,
  });

  Map<String, dynamic> toJson() => {
    'packageName': packageName,
    'appName': appName,
    'isBlocked': isBlocked,
  };

  factory BlockedAppModel.fromJson(Map<String, dynamic> json) => BlockedAppModel(
    packageName: json['packageName'] as String,
    appName: json['appName'] as String,
    isBlocked: json['isBlocked'] as bool? ?? true,
  );
}
