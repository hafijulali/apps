import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'alert_dialog.dart';
import 'app.dart';

class HomePage extends StatefulWidget {
  const HomePage({required this.title, required this.data, Key? key})
      : super(key: key);
  final String title;
  final List<dynamic> data;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> get data => widget.data;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text(appTitle),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: GridView.builder(
              shrinkWrap: true,
              itemCount: 10,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width ~/ 350,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4),
              itemBuilder: (BuildContext context, int index) => Padding(
                    padding: const EdgeInsets.all(8),
                    child: showListTileGrid(data, index),
                  )),
        ),
      );

  Widget showListTileGrid(List<dynamic> data, int index) => GridTile(
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
              onPressed: () async => {
                if (await canLaunchUrl(Uri.parse(data[index]['source'])))
                  {await launchUrl(Uri.parse(data[index]['source']))}
              },
            ),
            trailing: TextButton.icon(
              label: const Text('Demo'),
              icon: const Icon(
                Icons.crop_landscape,
              ),
              onPressed: () async => {
                if (await canLaunchUrl(Uri.parse(data[index]['demo'])))
                  {await launchUrl(Uri.parse(data[index]['demo']))}
                else
                  {
                    showAlertDialog(context, 'Error',
                        'Cannot launch demo, maybe a native application or it is currently down!')
                  }
              },
            ),
          ),
        ),
        header: _gridText(data[index]['name']),
        child: InkWell(
          onTap: () => {},
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          child: Material(
            elevation: 10,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image(image: AssetImage('assets/${data[index]['image']}')),
          ),
        ),
      );

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
