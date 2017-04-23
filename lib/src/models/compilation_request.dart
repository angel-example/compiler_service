library compiler_service.models.compilation_request;

import 'package:angel_framework/common.dart';

class CompilationRequest extends Model {
  @override
  String id;
  String userId, userFileId;
  bool complete;
  @override
  DateTime createdAt, updatedAt;

  CompilationRequest(
      {this.id,
      this.userId,
      this.userFileId,
      this.complete: false,
      this.createdAt,
      this.updatedAt});

  static CompilationRequest parse(Map map) => new CompilationRequest(
      id: map['id'],
      userId: map['userId'],
      userFileId: map['userFileId'],
      complete: map['complete'],
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
      'userFileId': userFileId,
      'complete': complete == true,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String()
    };
  }
}
