import 'dart:math';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:apps/constants.dart';

class Project {
  final String id;
  final String name;
  final String? description;
  final String? demo;
  final String? image;
  final String source;
  final String? generatedImageUrl;

  Project(
      {required this.id,
      required this.name,
      required this.description,
      this.demo,
      required this.source,
      this.image,
      this.generatedImageUrl});

  factory Project.fromGitHub(Map<String, dynamic> json) {
    final String? imageUrl = null; // Always null to force Gravatar
    final String generatedImageUrl = _generateRandomGravatarUrl(json['name']);

    return Project(
      id: json["id"].toString(),
      name: json['name'],
      description: json['description'],
      source: json['html_url'],
      image: imageUrl,
      generatedImageUrl: generatedImageUrl,
      demo: 'https://$username.github.io/${json['name']}',
    );
  }
  factory Project.fromGitLab(Map<String, dynamic> json) {
    final String? imageUrl = json['avatar_url'];
    final String? generatedImageUrl =
        imageUrl == null ? _generateRandomGravatarUrl(json['name']) : null;

    return Project(
      id: json['id'].toString(),
      name: json['name'],
      description: json['description'],
      source: json['web_url'],
      image: imageUrl,
      generatedImageUrl: generatedImageUrl,
      demo: 'https://$username.gitlab.io/${json['name']}',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'description': description,
        'source': source,
        'image': image,
        'generatedImageUrl': generatedImageUrl,
        'demo': demo,
      };

  static Project fromJson(Map<String, dynamic> json) => Project(
        id: json['id'].toString(),
        name: json['name'],
        description: json['description'],
        source: json['source'],
        image: json['image'],
        generatedImageUrl: json['generatedImageUrl'],
        demo: json['demo'],
      );
}

String _generateRandomGravatarUrl(String seed) {
  final random = Random();
  final String uniqueSeed = seed + random.nextInt(1000000000).toString();
  final List<int> bytes = utf8.encode(uniqueSeed);
  final Digest digest = md5.convert(bytes);
  return 'https://www.gravatar.com/avatar/${digest.toString()}?d=identicon';
}
