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
import 'widgets/project_image.dart';
import 'project_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    BaseConstants().currentPageRoute = BaseConstants().homePageRoute;
    return Scaffold(
      appBar: appBar(context, data: null), // Pass null initially
      body: FutureBuilder<List<Project>>(
          future: fetchProjects(),
          builder:
              (BuildContext context, AsyncSnapshot<List<Project>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final List<Project> projects = snapshot.data!;
              return showDataInGridView(projects);
            }
          }),
    );
  }

  Widget showDataInGridView(List<Project> data) {
    if (data.any((p) => p.image == null)) {
      showSnackbar(
          "Unable to load some images, showing default app image. See flutter#45955");
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: GridView.builder(
          shrinkWrap: true,
          itemCount: data.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width ~/ 350,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8),
          itemBuilder: (BuildContext context, int index) =>
              ProjectCard(project: data[index])),
    );
  }
}

class ProjectCard extends StatefulWidget {
  final Project project;

  const ProjectCard({super.key, required this.project});

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Material(
          elevation: _isHovered ? 12 : 4,
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProjectDetailsPage(project: widget.project),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Hero(
                    tag: 'project-image-${widget.project.name}',
                    child: ProjectImage(project: widget.project),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0), // Increased padding
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.project.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.project.description ?? descriptionNotAvailable,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildSourceButton(widget.project.source),
                            const SizedBox(width: 8),
                            if (widget.project.demo != null &&
                                widget.project.demo!.isNotEmpty)
                              FilledButton.icon(
                                icon: const Icon(Icons.play_arrow),
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
                                label: const Text('Demo'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSourceButton(String sourceUrl) {
    if (sourceUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    IconData iconData = Icons.link;
    String buttonText = 'Source';
    if (sourceUrl.contains('github.com')) {
      iconData = Icons.code;
      buttonText = 'GitHub';
    } else if (sourceUrl.contains('gitlab.com')) {
      iconData = Icons.code;
      buttonText = 'GitLab';
    }

    return TextButton.icon(
      icon: Icon(iconData),
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
      label: Text(buttonText),
    );
  }
}
