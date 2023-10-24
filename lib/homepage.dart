import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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
            leading: IconButton(
              tooltip: 'Source Code',
              icon: const Icon(
                Icons.code_outlined,
                semanticLabel: 'Source Code',
              ),
              onPressed: () async => {
                if (await canLaunchUrl(Uri.parse(data[index]['source'])))
                  {await launchUrl(Uri.parse(data[index]['source']))}
              },
            ),
            trailing: IconButton(
              tooltip: 'Demo',
              icon: const Icon(
                Icons.crop_landscape,
              ),
              onPressed: () async => {
                if (await canLaunchUrl(Uri.parse(data[index]['demo'])))
                  {await launchUrl(Uri.parse(data[index]['demo']))}
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
//         child: Row(
//           children: <Widget>[
//             Container(
//               width: 100,
//               height: 100,
//               child: InkWell(
//                 child: Container(
//                   decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(15),
//                       image: DecorationImage(
//                           image: AssetImage('assets/${data[index]['image']}'))),
//                 ),
//               ),
//             ),
//             Column(children: <Widget>[
//               Expanded(
//                 child: InkWell(
//                   child: Container(
//                     decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(15),
//                         image: DecorationImage(
//                             image:
//                                 AssetImage('assets/${data[index]['image']}'))),
//                     child: Text(data.elementAt(index)['name']),
//                   ),
//                 ),
//               ),
//             ]),
//             // Container(R
//             //   decoration: const BoxDecoration(
//             //     image: DecorationImage(image: NetworkImage("https://pixlok.com/wp-content/uploads/2021/05/flutter-logo.jpg")),
//             //   ),
//             // )
//           ],
//         ),
//       );
// }
