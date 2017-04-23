library compiler_service.models.user;

import 'package:angel_framework/common.dart';

class User extends Model {
  @override
  String id;
  String googleId, avatar, name;
  @override
  DateTime createdAt, updatedAt;

  User(
      {this.id,
      this.googleId,
      this.avatar,
      this.name,
      this.createdAt,
      this.updatedAt});

  static User parse(Map map) => new User(
      id: map['id'],
      googleId: map['googleId'],
      avatar: map['avatar'],
      name: map['name'],
      createdAt: map.containsKey('createdAt')
          ? DateTime.parse(map['createdAt'])
          : null,
      updatedAt: map.containsKey('updatedAt')
          ? DateTime.parse(map['updatedAt'])
          : null);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'googleId': googleId,
      'avatar': avatar,
      'name': name,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String()
    };
  }
}
