import 'package:flutter/material.dart';
import 'package:packer/core/constants/constants.dart';
import 'package:packer/widgets/alert_dialog.dart';
import 'package:packer/widgets/snack_bar.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'api.dart';
import 'app_bar.dart';
import 'constants.dart';
import 'init.dart';
import 'model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    BaseConstants().currentPageRoute = BaseConstants().homePageRoute;
    return Scaffold(
      appBar: appBar(context),
      body: FutureBuilder<List<Project>>(
          future: fetchProjects(),
          builder:
              (BuildContext context, AsyncSnapshot<List<Project>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return showDataInGridView(snapshot.data!);
            }
          }),
    );
  }

  Widget showDataInGridView(List<Project> data) {
    // INFO : Pesky hack to show single snackbar even if
    // multiple images do not load
    if (data[5].image == null) {
      showSnackbar(
          "Unable to load images, showing default app image see flutter#45955");
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: GridView.builder(
          shrinkWrap: true,
          itemCount: data.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width ~/ 350,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4),
          itemBuilder: (BuildContext context, int index) => Padding(
                padding: const EdgeInsets.all(8),
                child: showListTileGrid(data, index),
              )),
    );
  }

  Widget showListTileGrid(List<Project> data, int index) {
    return GridTile(
      footer: Material(
        color: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16)),
        ),
        clipBehavior: Clip.antiAlias,
        child: GridTileBar(
          backgroundColor: Colors.black45,
          title: const Center(child: Text(' ')),
          subtitle: const Text(' '),
          leading: TextButton.icon(
            label: const Text('Source Code'),
            icon: const Icon(
              Icons.code_outlined,
              semanticLabel: 'Source Code',
            ),
            onPressed: () async {
              final String sourceUrl = data[index].source;
              if (await canLaunchUrlString(sourceUrl) == true) {
                debugPrint(
                    "Launching sourceUrl $sourceUrl with mode $launchMode");
                await launchUrlString(sourceUrl,
                    mode: launchMode, webOnlyWindowName: webWindowName);
              } else {
                if (mounted) {
                  showAlertDialog(context, 'Error',
                      'Unable to open source code link at the moment, please visit $sourceUrl in browser');
                }
              }
            },
          ),
          trailing: TextButton.icon(
            label: const Text('Demo'),
            icon: const Icon(
              Icons.crop_landscape,
            ),
            onPressed: () async {
              final String demoUrl = data[index].demo ?? '';
              if (await canLaunchUrlString(demoUrl) == true) {
                debugPrint("Launching demoUrl $demoUrl with mode $launchMode");
                await launchUrlString(demoUrl,
                    mode: launchMode, webOnlyWindowName: webWindowName);
              } else {
                if (mounted) {
                  showAlertDialog(context, 'Error',
                      'Cannot launch demo, maybe a native application or it is currently down!');
                }
              }
            },
          ),
        ),
      ),
      header: _gridText(data[index].name),
      child: InkWell(
        onTap: () => showAlertDialog(context, "Description",
            data[index].description ?? descriptionNotAvailable),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: Material(
          elevation: 10,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          clipBehavior: Clip.antiAlias,
          child: _getImageFromSource(data, index),
        ),
      ),
    );
  }

  Widget _getImageFromSource(data, index) {
    if (data[index].image != null) {
      if (cache?.containsKey(projectsCacheDatabasekey) == true) {
        return Image.network(data[index].image);
      }
      return Image.asset('assets/${data[index].image}');
    }
    debugPrint("Unable to load images, showing default app image");
    return Image.asset('assets/alive.png');
  }

  Material _gridText(String title, [String subtitle = ' ']) => Material(
        color: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        ),
        clipBehavior: Clip.antiAlias,
        child: GridTileBar(
          backgroundColor: Colors.black45,
          title: Center(child: Text(title)),
          subtitle: Text(subtitle),
        ),
      );
}
