import 'package:flutter/material.dart';
import 'package:apps/model.dart';
import 'package:apps/project_details_page.dart';

class ModernSearchBar extends StatelessWidget {
  final String hintText;
  final List<Project> projects;

  const ModernSearchBar({
    super.key,
    this.hintText = 'Search',
    required this.projects,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SearchAnchor(
        builder: (BuildContext context, SearchController controller) {
          return SearchBar(
            controller: controller,
            padding: const WidgetStatePropertyAll<EdgeInsets>(
              EdgeInsets.symmetric(horizontal: 16.0),
            ),
            onTap: () {
              controller.openView();
            },
            onChanged: (_) {
              controller.openView();
            },
            leading: const Icon(Icons.search),
            hintText: hintText,
          );
        },
        suggestionsBuilder:
            (BuildContext context, SearchController controller) {
          final String query = controller.text;

          final filteredProjects = projects.where((project) {
            final nameLower = project.name.toLowerCase();
            final descriptionLower = project.description?.toLowerCase() ?? '';
            final queryLower = query.toLowerCase();
            return nameLower.contains(queryLower) ||
                descriptionLower.contains(queryLower);
          }).toList();

          return List<ListTile>.generate(filteredProjects.length, (int index) {
            final Project project = filteredProjects[index];
            return ListTile(
              title: Text(project.name),
              onTap: () {
                controller.closeView(project.name);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProjectDetailsPage(project: project),
                  ),
                );
              },
            );
          });
        },
      ),
    );
  }
}
