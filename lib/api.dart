import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:packer/widgets/snack_bar.dart';

import 'constants.dart';
import 'data.dart';
import 'init.dart';
import 'model.dart';

Future<List<Project>> fetchProjects() async {
  List<Project> projects = <Project>[];

  if (cache?.containsKey(projectsCacheDatabasekey) == true) {
    debugPrint("Loading data from cache");
    final List<dynamic> cachedData =
        jsonDecode(cache?.get(projectsCacheDatabasekey));
    for (Map<String, dynamic> i in cachedData) {
      projects.add(Project.fromJson(i));
    }
    return projects;
  }

  final Dio dio = Dio();
  List<dynamic> github = [];
  List<dynamic> gitlab = [];

  debugPrint('GitLab Token: $gitlabToken');

  try {
    final Response<dynamic> githubResponse = await dio.get(
      'https://api.github.com/users/hafijulali/repos',
      queryParameters: <String, dynamic>{'per_page': 10, 'sort': 'updated'},
    );
    github =
        (githubResponse.data).map((proj) => Project.fromGitHub(proj)).toList();
  } on Exception catch (e) {
    debugPrint("Unable to load github projects $e");
  }

  try {
    debugPrint('Attempting to fetch GitLab projects...');
    final Response<dynamic> gitlabResponse = await dio.get(
      'https://gitlab.com/api/v4/projects',
      queryParameters: <String, dynamic>{
        'membership': 'true',
        'visibility': 'public',
        'per_page': 10,
        'order_by': 'updated_at',
        'owned': true
      },
      options: Options(
          headers: <String, String>{'Authorization': 'Bearer $gitlabToken'}),
    );
    debugPrint('GitLab API response status: ${gitlabResponse.statusCode}');
    gitlab =
        (gitlabResponse.data).map((proj) => Project.fromGitLab(proj)).toList();
    debugPrint('Successfully fetched ${gitlab.length} GitLab projects.');
  } on Exception catch (e) {
    debugPrint("Unable to load gitlab projects $e");
  }

  try {
    projects = [...gitlab, ...github];
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    await cache?.put(dataEntryCacheDatabaseKey, currentTime);
    await cache?.put(projectsCacheDatabasekey, jsonEncode(projects));
  } on Exception catch (e) {
    debugPrint('Error saving projects: $e');
  }
  if (projects.isEmpty) {
    showSnackbar(
        "Unable to fetch data from online sources, showing local data.");
    for (Map<String, dynamic> i in (await getLocalData())) {
      projects.add(Project.fromJson(i));
    }
  }

  return projects;
}

Future<String> fetchReadmeContent(Project project) async {
  final String cacheKey = 'readme_${project.source.hashCode}';
  if (cache?.containsKey(cacheKey) == true) {
    debugPrint("Loading README from cache for ${project.source}");
    return cache?.get(cacheKey);
  }

  final Dio dio = Dio();
  String? owner;
  String? repo;

  debugPrint('Fetching README for: ${project.source}');

  if (project.source.contains('github.com')) {
    final githubRegex = RegExp(r'github\.com/([^/]+)/([^/]+)');
    final match = githubRegex.firstMatch(project.source);
    if (match != null && match.groupCount >= 2) {
      owner = match.group(1);
      repo = match.group(2);
      debugPrint('GitHub Owner: $owner, Repo: $repo');
      for (var branch in ['main', 'master']) {
        final readmeUrl =
            'https://raw.githubusercontent.com/$owner/$repo/$branch/README.md';
        try {
          debugPrint('Trying GitHub README URL ($branch): $readmeUrl');
          final response = await dio.get(readmeUrl);
          if (response.statusCode == 200) {
            debugPrint('GitHub README ($branch) fetched successfully.');
            await cache?.put(cacheKey, response.data);
            return response.data;
          }
        } catch (e) {
          debugPrint('Error fetching GitHub README from $branch branch: $e');
        }
      }
    }
  } else if (project.source.contains('gitlab.com')) {
    debugPrint('GitLab Project ID: ${project.id}');
    for (var branch in ['main', 'master']) {
      final readmeUrl =
          'https://gitlab.com/api/v4/projects/${project.id}/repository/files/README.md?ref=$branch';
      try {
        debugPrint('Trying GitLab README API URL ($branch): $readmeUrl');
        final response = await dio.get(
          readmeUrl,
          options: Options(headers: <String, String>{
            'Authorization': 'Bearer $gitlabToken'
          }),
        );
        if (response.statusCode == 200) {
          debugPrint('GitLab README ($branch) fetched successfully via API.');
          final content = response.data['content'];
          final decodedContent = utf8.decode(base64.decode(content));
          await cache?.put(cacheKey, decodedContent);
          return decodedContent;
        }
      } catch (e) {
        debugPrint(
            'Error fetching GitLab README from $branch branch via API: $e');
      }
    }
  }

  debugPrint('README not found for ${project.source}');
  return '# README not found\n\nCould not find a README.md for this project.';
}
