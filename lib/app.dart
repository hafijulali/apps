import 'package:flutter/material.dart';
import 'homepage.dart';

const String appTitle = 'Apps';

class App extends StatelessWidget {
  const App({required this.data, Key? key}) : super(key: key);
  final List<dynamic> data;
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: appTitle,
        theme: ThemeData(useMaterial3: true),
        home: HomePage(title: appTitle, data: data),
      );
}
