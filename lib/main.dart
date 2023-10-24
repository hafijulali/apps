import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'app.dart';

Future<List<dynamic>> getData() async {
  //final dynamic data = json.decode(await rootBundle.loadString('assets/projects.json'));
  final List<dynamic> data =
      await jsonDecode(await File('assets/projects.json').readAsString());
  return data;
}

void main() async {
  final List<dynamic> data = await getData();
  runApp(App(data: data));
}
