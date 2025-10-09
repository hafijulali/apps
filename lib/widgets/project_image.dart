import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../model.dart';
import '../init.dart'; // Import init.dart to access the cache box

class ProjectImage extends StatelessWidget {
  final Project project;

  const ProjectImage({super.key, required this.project});

  Future<Uint8List?> _fetchAndCacheImage(String imageUrl) async {
    final String cacheKey = 'image_${imageUrl.hashCode}';
    debugPrint("Cache key generated: $cacheKey for URL: $imageUrl");

    if (cache?.containsKey(cacheKey) == true) {
      debugPrint("Cache hit! Loading image from cache for key: $cacheKey");
      return cache?.get(cacheKey) as Uint8List?;
    }

    try {
      debugPrint("Cache miss. Fetching image from network: $imageUrl");
      final response = await Dio().get<List<int>>(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.statusCode == 200 && response.data != null) {
        final Uint8List bytes = Uint8List.fromList(response.data!);
        debugPrint("Storing image in cache for key: $cacheKey");
        await cache?.put(cacheKey, bytes);
        return bytes;
      }
    } catch (e) {
      debugPrint("Error fetching image $imageUrl: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    String? imageUrlToLoad;

    if (project.image != null && project.image!.startsWith('http')) {
      imageUrlToLoad = project.image!;
    } else if (project.image != null) {
      // Local asset
      return Image.asset(
        'assets/${project.image}',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          debugPrint("Error loading asset image for ${project.name}: $error");
          imageUrlToLoad =
              project.generatedImageUrl; // Fallback to generated Gravatar
          if (imageUrlToLoad != null) {
            return _buildNetworkImage(imageUrlToLoad!);
          } else {
            return const SizedBox.shrink();
          }
        },
      );
    } else {
      imageUrlToLoad = project.generatedImageUrl;
    }

    if (imageUrlToLoad != null) {
      return _buildNetworkImage(imageUrlToLoad);
    }

    return const SizedBox.shrink(); // Should not happen
  }

  Widget _buildNetworkImage(String imageUrl) {
    return FutureBuilder<Uint8List?>(
      future: _fetchAndCacheImage(imageUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data == null) {
          debugPrint("Error displaying image $imageUrl: ${snapshot.error}");
          // Fallback to another random Gravatar on error - this should be rare now
          // as generatedImageUrl is stable and cached.
          return Image.network(
            project.generatedImageUrl!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          );
        } else {
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          );
        }
      },
    );
  }
}
