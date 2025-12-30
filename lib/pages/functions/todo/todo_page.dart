import 'package:flutter/material.dart';

class Todo extends StatefulWidget {
  const Todo({super.key});

  @override
  State<Todo> createState() => _Todo();
}

class _Todo extends State<Todo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: appBar(), body: wholeBody(context));
  }

  Widget wholeBody(BuildContext context) {
    return Column(
      children: [
        searchBar(),
        Expanded(child: Center(child: Text('Ide jönnek majd a todo-k'))),
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
      title: const Text('To-Do'),
    );
  }
}


/*Floating button
https://api.flutter.dev/flutter/material/FloatingActionButton-class.html*/

/*SearchBar
https://api.flutter.dev/flutter/material/SearchBar-class.html
*/
