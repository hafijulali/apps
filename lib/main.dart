import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';

Future<List<dynamic>> getData() async {
  final dynamic data =
      json.decode(await rootBundle.loadString('assets/projects.json'));
  return data;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final List<dynamic> data = await getData();
  runApp(App(data: data));
}
