import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:packer/core/constants/constants.dart';
import 'package:packer/widgets/scaffold_key.dart';

import 'homepage.dart';
import 'init.dart';
import 'settings_page.dart';

Future<dynamic> main() async {
  await initApp();
  runApp(
    StreamBuilder<BoxEvent>(
      stream: cache!.watch(),
      builder: (BuildContext context, AsyncSnapshot<BoxEvent> snapshot) =>
          MaterialApp(
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        home: const HomePage(),
        routes: <String, WidgetBuilder>{
          BaseConstants().homePageRoute: (_) => HomePage(),
          BaseConstants().settingsPageRoute: (_) => SettingsPage()
        },
      ),
    ),
  );
}
