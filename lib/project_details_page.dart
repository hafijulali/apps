import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:packer/widgets/alert_dialog.dart';
import 'package:markdown_widget/markdown_widget.dart';

import 'api.dart';
import 'widgets/project_image.dart';
import 'constants.dart';
import 'init.dart';
import 'model.dart';

class ProjectDetailsPage extends StatefulWidget {
  final Project project;

  const ProjectDetailsPage({super.key, required this.project});

  @override
  State<ProjectDetailsPage> createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
  late Future<String> _readmeContentFuture;

  @override
  void initState() {
    super.initState();
    _readmeContentFuture = fetchReadmeContent(widget.project);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.project.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  )),
              background: Hero(
                tag: 'project-image-${widget.project.name}',
                child: ProjectImage(project: widget.project),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About this project',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.project.description ?? descriptionNotAvailable,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSourceButton(widget.project.source),
                      const SizedBox(width: 16),
                      if (widget.project.demo != null &&
                          widget.project.demo!.isNotEmpty)
                        ElevatedButton(
                          onPressed: () async {
                            final String demoUrl = widget.project.demo!;
                            if (await canLaunchUrlString(demoUrl)) {
                              await launchUrlString(demoUrl,
                                  mode: launchMode,
                                  webOnlyWindowName: webWindowName);
                            } else {
                              if (mounted) {
                                showAlertDialog(context, 'Error',
                                    'Cannot launch demo, maybe a native application or it is currently down!');
                              }
                            }
                          },
                          child: const Text('View Demo'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'README.md',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<String>(
                    future: _readmeContentFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (snapshot.hasData) {
                        debugPrint(
                            'README.md content for rendering:\n${snapshot.data!.substring(0, snapshot.data!.length > 500 ? 500 : snapshot.data!.length)}...');
                        return MarkdownWidget(
                          data: snapshot.data!,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                        );
                      } else {
                        return const Center(child: Text('No README found.'));
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceButton(String sourceUrl) {
    if (sourceUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    String buttonText = 'Source';
    if (sourceUrl.contains('github.com')) {
      buttonText = 'GitHub';
    } else if (sourceUrl.contains('gitlab.com')) {
      buttonText = 'GitLab';
    }

    return OutlinedButton(
      onPressed: () async {
        if (await canLaunchUrlString(sourceUrl)) {
          await launchUrlString(sourceUrl,
              mode: launchMode, webOnlyWindowName: webWindowName);
        } else {
          if (mounted) {
            showAlertDialog(context, 'Error',
                'Unable to open source code link at the moment, please visit $sourceUrl in browser');
          }
        }
      },
      child: Text(buttonText),
    );
  }
}
