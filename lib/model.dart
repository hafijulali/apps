import 'package:apps/constants.dart';

class Project {
  final String id;
  final String name;
  final String? description;
  final String? demo;
  final String? image;
  final String source;

  Project(
      {required this.id,
      required this.name,
      required this.description,
      this.demo,
      required this.source,
      this.image});

  factory Project.fromGitHub(Map<String, dynamic> json) => Project(
        id: json["id"].toString(),
        name: json['name'],
        description: json['description'],
        source: json['html_url'],
        image: json['avatar_url'],
        demo: 'https://$username.github.io/${json['name']}',
      );
  factory Project.fromGitLab(Map<String, dynamic> json) => Project(
        id: json['id'].toString(),
        name: json['name'],
        description: json['description'],
        source: json['web_url'],
        image: json['avatar_url'],
        demo: 'https://$username.gitlab.io/${json['name']}',
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'description': description,
        'source': source,
        'image': image,
        'demo': demo,
      };

  static Project fromJson(Map<String, dynamic> json) => Project(
        id: json['id'].toString(),
        name: json['name'],
        description: json['description'],
        source: json['source'],
        image: json['image'],
        demo: json['demo'],
      );
}
