import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_ce/hive.dart';
import 'package:packer/core/constants/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'constants.dart';
import 'data.dart';

Box<dynamic>? cache;
Box<dynamic>? settings;
String databaseFilePath = appTitle;
String gitlabToken = '';
String username = '';
String appVersion = '';
String appThemeMode = 'System';

bool openLinksInNewTab =
    settings?.get(openLinksInNewTabSettingsKey, defaultValue: false) ?? false;
LaunchMode launchMode = LaunchMode.platformDefault;

String webWindowName = '_self';

Future<void> initApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    databaseFilePath = (await getApplicationDocumentsDirectory()).path;
    debugPrint('Hive database file path: $databaseFilePath');
    launchMode = LaunchMode.inAppBrowserView;
    webWindowName = '';
  }
  webWindowName = openLinksInNewTab ? '_blank' : webWindowName;
  await dotenv.load(fileName: ".env");
  Hive.init(databaseFilePath);
  setupCacheExpiry(durationMinutes: 5);
  BaseConstants().currentPageRoute = BaseConstants().homePageRoute;

  cache = await Hive.openBox<dynamic>(cacheDatabaseFileName);
  settings =
      await Hive.openBox<dynamic>(BaseConstants().settingsDatabaseFileName);
  gitlabToken = dotenv.get('gitlabToken', fallback: '');
}
