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
      'https://api.github.com/users/${dotenv.get('username', fallback: '')}/repos',
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


Future<String> fetchReadmeContent(String projectSourceUrl) async {
  final String cacheKey = 'readme_' + projectSourceUrl.hashCode.toString();
  if (cache?.containsKey(cacheKey) == true) {
    debugPrint("Loading README from cache for $projectSourceUrl");
    return cache?.get(cacheKey);
  }

  final Dio dio = Dio();
  String? owner;
  String? repo;
  String readmeUrl = '';

  debugPrint('Fetching README for: $projectSourceUrl');

  if (projectSourceUrl.contains('github.com')) {
    final githubRegex = RegExp(r'github\.com/([^/]+)/([^/]+)');
    final match = githubRegex.firstMatch(projectSourceUrl);
    if (match != null && match.groupCount >= 2) {
      owner = match.group(1);
      repo = match.group(2);
      debugPrint('GitHub Owner: $owner, Repo: $repo');
      // Try main branch first, then master
      readmeUrl = 'https://raw.githubusercontent.com/$owner/$repo/main/README.md';
      try {
        debugPrint('Trying GitHub README URL (main): $readmeUrl');
        final response = await dio.get(readmeUrl);
        if (response.statusCode == 200) {
          debugPrint('GitHub README (main) fetched successfully.');
          debugPrint('README Content (main branch):\n${response.data.substring(0, response.data.length > 500 ? 500 : response.data.length)}...'); // Print first 500 chars
          await cache?.put(cacheKey, response.data);
          return response.data;
        }
      } catch (e) {
        debugPrint('Error fetching GitHub README from main branch: $e');
      }
      readmeUrl = 'https://raw.githubusercontent.com/$owner/$repo/master/README.md';
      try {
        debugPrint('Trying GitHub README URL (master): $readmeUrl');
        final response = await dio.get(readmeUrl);
        if (response.statusCode == 200) {
          debugPrint('GitHub README (master) fetched successfully.');
          debugPrint('README Content (master branch):\n${response.data.substring(0, response.data.length > 500 ? 500 : response.data.length)}...'); // Print first 500 chars
          await cache?.put(cacheKey, response.data);
          return response.data;
        }
      } catch (e) {
        debugPrint('Error fetching GitHub README from master branch: $e');
      }
    }
  } else if (projectSourceUrl.contains('gitlab.com')) {
    final gitlabRegex = RegExp(r'gitlab\.com/([^/]+)/([^/]+)');
    final match = gitlabRegex.firstMatch(projectSourceUrl);
    if (match != null && match.groupCount >= 2) {
      owner = match.group(1);
      repo = match.group(2);
      debugPrint('GitLab Owner: $owner, Repo: $repo');
      // Try main branch first, then master
      readmeUrl = 'https://gitlab.com/$owner/$repo/-/raw/main/README.md';
      try {
        debugPrint('Trying GitLab README URL (main): $readmeUrl');
        final response = await dio.get(readmeUrl);
        if (response.statusCode == 200) {
          debugPrint('GitLab README (main) fetched successfully.');
          debugPrint('README Content (main branch):\n${response.data.substring(0, response.data.length > 500 ? 500 : response.data.length)}...'); // Print first 500 chars
          await cache?.put(cacheKey, response.data);
          return response.data;
        }
      } catch (e) {
        debugPrint('Error fetching GitLab README from main branch: $e');
      }
      readmeUrl = 'https://gitlab.com/$owner/$repo/-/raw/master/README.md';
      try {
        debugPrint('Trying GitLab README URL (master): $readmeUrl');
        final response = await dio.get(readmeUrl);
        if (response.statusCode == 200) {
          debugPrint('GitLab README (master) fetched successfully.');
          debugPrint('README Content (master branch):\n${response.data.substring(0, response.data.length > 500 ? 500 : response.data.length)}...'); // Print first 500 chars
          await cache?.put(cacheKey, response.data);
          return response.data;
        }
      } catch (e) {
        debugPrint('Error fetching GitLab README from master branch: $e');
      }
    }
  }

  if (readmeUrl.isNotEmpty) {
    try {
      debugPrint('Trying README URL (fallback): $readmeUrl');
      final response = await dio.get(readmeUrl);
      if (response.statusCode == 200) {
        debugPrint('README (fallback) fetched successfully.');
        debugPrint('README Content (fallback):\n${response.data.substring(0, response.data.length > 500 ? 500 : response.data.length)}...'); // Print first 500 chars
        await cache?.put(cacheKey, response.data);
        return response.data;
      }
    } catch (e) {
      debugPrint('Error fetching README (fallback): $e');
    }
  }
  debugPrint('README not found for $projectSourceUrl');
  return '# README not found\n\nCould not find a README.md for this project.';
}