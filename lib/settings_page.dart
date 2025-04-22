import 'package:flutter/material.dart';
import 'package:packer/core/constants/constants.dart';
import 'package:packer/utils/package_utils.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'app_bar.dart';
import 'constants.dart';
import 'init.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<Widget> _widgetsTiles(BuildContext context) {
    return <Widget>[
      _buildInfo(context),
      const SizedBox(height: 16),
      _openLinksInNewTab(context),
      const SizedBox(height: 16),
    ];
  }

  Widget settingsPage(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(children: _widgetsTiles(context)),
      ),
    );
  }

  ListTile _buildInfo(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.mobile_friendly_outlined),
      title: Text('App Version : $appVersion'),
      onTap: () async => await launchUrlString(appCodebase),
    );
  }

  SwitchListTile _openLinksInNewTab(BuildContext context) {
    return SwitchListTile(
      title: Text('Open links in new tab'),
      value: openLinksInNewTab,
      onChanged: (value) {
        setState(() {
          openLinksInNewTab = value;
          settings?.put(openLinksInNewTabSettingsKey, value);
          webWindowName = value ? '_blank' : '_self';
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getAppVersion()
        .then((String version) => setState(() => appVersion = version));
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      BaseConstants().currentPageRoute = BaseConstants().settingsPageRoute;
    });
    return settingsPage(context);
  }
}
