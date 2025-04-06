import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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

  try {
    final Response<dynamic> githubResponse = await dio.get(
      'https://api.github.com/users/$username/repos',
      queryParameters: <String, dynamic>{'per_page': 10, 'sort': 'updated'},
    );
    github =
        (githubResponse.data).map((proj) => Project.fromGitHub(proj)).toList();
  } on Exception catch (e) {
    debugPrint("Unable to load github projects $e");
  }

  try {
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

    gitlab =
        (gitlabResponse.data).map((proj) => Project.fromGitLab(proj)).toList();
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
