import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:packer/widgets/scaffold_key.dart';

import 'homepage.dart';
import 'init.dart';

Future<dynamic> main() async {
  await initApp();
  runApp(
    StreamBuilder<BoxEvent>(
      stream: cache!.watch(),
      builder: (BuildContext context, AsyncSnapshot<BoxEvent> snapshot) =>
          MaterialApp(
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        home: const HomePage(),
      ),
    ),
  );
}
