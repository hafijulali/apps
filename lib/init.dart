import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_ce/hive.dart';
import 'package:packer/core/constants/constants.dart';
import 'package:path_provider/path_provider.dart';

import 'constants.dart';
import 'data.dart';

Box<dynamic>? cache;
String databaseFilePath = '';
String gitlabToken = '';
String appVersion = '';
String appThemeMode = 'System';

Future<void> initApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  databaseFilePath = (await getApplicationDocumentsDirectory()).path;
  await dotenv.load(fileName: ".env");
  Hive.init(databaseFilePath);
  setupCacheExpiry(durationMinutes: 5);
  BaseConstants().currentPageRoute = BaseConstants().homePageRoute;

  cache = await Hive.openBox<dynamic>(cacheDatabaseName);
  gitlabToken = dotenv.get('GITLAB_TOKEN');
}
