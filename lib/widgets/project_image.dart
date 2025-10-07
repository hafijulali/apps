import 'dart:math';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import '../model.dart';

class ProjectImage extends StatelessWidget {
  final Project project;

  const ProjectImage({super.key, required this.project});

  String _generateRandomImageUrl() {
    final random = Random();
    final String seed = random.nextInt(1000000000).toString(); // Use a larger range for more randomness
    final List<int> bytes = utf8.encode(seed);
    final Digest digest = md5.convert(bytes);
    // Using Gravatar with 'identicon' default for generic, non-human images
    return 'https://www.gravatar.com/avatar/${digest.toString()}?d=identicon';
  }

  @override
  Widget build(BuildContext context) {
    if (project.image != null && project.image!.startsWith('http')) {
      return Image.network(
        project.image!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          debugPrint("Error loading network image for ${project.name}: $error");
          return Image.network(
            _generateRandomImageUrl(),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          );
        },
      );
    } else if (project.image != null) {
      // Fallback for local assets if project.image is not a URL
      return Image.asset(
        'assets/${project.image}',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          debugPrint("Error loading asset image for ${project.name}: $error");
          return Image.network(
            _generateRandomImageUrl(),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          );
        },
      );
    } else {
      debugPrint(
          "No image specified for ${project.name}, showing a random image");
      return Image.network(
        _generateRandomImageUrl(),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
  }
}
