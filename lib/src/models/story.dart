library story.models.story;
import 'package:angel_framework/common.dart';

class Story extends Model {
  @override
  String id;
  String userId, path;
  @override
  DateTime createdAt, updatedAt;

  Story({this.id, this.userId, this.path, this.createdAt, this.updatedAt});

  static Story parse(Map map) => new Story(
      id: map['id'],
      userId: map['userId'],
      path: map['path'],
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
      'path': path,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String()
    };
  }
}