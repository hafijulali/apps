import 'package:apps/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_ce/hive.dart';

import 'constants.dart';

Box<dynamic>? cache;
String gitlabToken = '';

Future<void> initApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  Hive.init(appTitle);
  setupCacheExpiry(durationMinutes: 5);

  cache = await Hive.openBox<dynamic>(cacheDatabaseName);
  gitlabToken = dotenv.get('GITLAB_TOKEN');
}
