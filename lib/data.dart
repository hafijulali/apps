import 'dart:async';
import 'dart:convert';

import 'package:apps/constants.dart';
import 'package:apps/init.dart';
import 'package:flutter/services.dart';

Future<List<dynamic>> getLocalData() async {
  final dynamic data =
      json.decode(await rootBundle.loadString('assets/projects.json'));
  return data;
}

void setupCacheExpiry({int durationMinutes = 5}) {
  Timer.periodic(Duration(minutes: durationMinutes), (timer) async {
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    if (cache?.get(dataEntryCacheDatabaseKey) < currentTime) {
      await cache?.delete(projectsCacheDatabasekey);
    }
  });
}
