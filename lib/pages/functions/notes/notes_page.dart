import 'package:flutter/material.dart';

class Notes extends StatefulWidget {
  const Notes({super.key});

  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: appBar(), body: wholeBody(context));
  }

  Widget wholeBody(BuildContext context) {
    return Column(
      children: [
        searchBar(),
        Expanded(child: Center(child: Text('Ide jönnek majd a jegyzetek'))),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: FloatingActionButton(onPressed: () {}, backgroundColor: Colors.lightGreen, child: const Icon(Icons.add)),
        ),
      ],
    );
  }

  Widget searchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SearchAnchor(
        builder: (BuildContext context, SearchController controller) {
          return SearchBar(
            controller: controller,
            padding: const WidgetStatePropertyAll<EdgeInsets>(
              EdgeInsets.symmetric(horizontal: 16.0),
            ),
            leading: const Icon(Icons.search),
            hintText: 'Search...',
            onTap: () => controller.openView(),
            onChanged: (_) => controller.openView(),
          );
        },
        suggestionsBuilder:
            (BuildContext context, SearchController controller) {
              return List<ListTile>.generate(5, (int index) {
                final item = 'item $index';
                return ListTile(
                  title: Text(item),
                  onTap: () {
                    setState(() {
                      controller.closeView(item);
                    });
                  },
                );
              });
            },
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      backgroundColor: Colors.lightGreen,
      title: const Text('Notes'),
    );
  }
}
