library compiler_service.models.user_file;

import 'package:angel_framework/common.dart';

class UserFile extends Model {
  @override
  String id;
  String userId, directoryPath;
  @override
  DateTime createdAt, updatedAt;

  UserFile(
      {this.id,
      this.userId,
      this.directoryPath,
      this.createdAt,
      this.updatedAt});

  static UserFile parse(Map map) => new UserFile(
      id: map['id'],
      userId: map['userId'],
      directoryPath: map['directoryPath'],
      createdAt: map.containsKey('createdAt')
          ? DateTime.parse(map['createdAt'])
          : null,
      updatedAt: map.containsKey('updatedAt')
          ? DateTime.parse(map['updatedAt'])
          : null);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'directoryPath': directoryPath,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String()
    };
  }
}
