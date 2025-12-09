import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import 'constants.dart';
import 'init.dart';

Future<List<dynamic>> getLocalData() async {
  final dynamic data =
      json.decode(await rootBundle.loadString('assets/projects.json'));
  return data;
}

void setupCacheExpiry({int durationMinutes = 5}) {
  Timer.periodic(Duration(minutes: durationMinutes), (timer) async {
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    if (!disableCache && cache?.get(dataEntryCacheDatabaseKey) < currentTime) {
      await cache?.delete(projectsCacheDatabasekey);
    }
  });
}
