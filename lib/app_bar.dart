import 'package:apps/model.dart';
import 'package:flutter/material.dart';
import 'package:packer/core/constants/constants.dart';
import 'package:packer/navigation/navigate.dart';
import 'package:packer/widgets/snack_bar.dart';

import '../../../init.dart';
import 'api.dart';
import 'search_bar.dart';

AppBar appBar(BuildContext context,
    {List<Project>? data, bool showSearch = true}) {
  return AppBar(
    elevation: 0,
    backgroundColor: Colors.transparent,
    title: showSearch
        ? ModernSearchBar(
            projects: data ?? [], // Pass an empty list if data is null
            hintText: (BaseConstants().currentPageRoute.isNotEmpty)
                ? 'Search in ${BaseConstants().currentPageRoute.substring(1)}'
                : 'Search',
          )
        : null,
    centerTitle: true,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_outlined),
      onPressed: () {
        safePop(context);
      },
    ),
    actions: _actions(context),
  );
}

List<IconButton> _actions(BuildContext context) {
  return <IconButton>[
    IconButton(
      onPressed: () async => {
        debugPrint("Clearing cache and reloading data"),
        await cache?.clear(),
        fetchProjects(),
        await showSnackbar('Please reload the page or restart the app.')
      },
      icon: const Icon(Icons.refresh_outlined),
    ),
    IconButton(
      onPressed: () async =>
          safePushNamed(context, BaseConstants().settingsPageRoute),
      icon: const Icon(Icons.settings_outlined),
    ),
  ];
}
