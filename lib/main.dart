import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_todos/controllers/auth_controller.dart';
import 'package:firebase_todos/controllers/item_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'models/item_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final authControllerState = useProvider(authControllerProvider.state);
    final itemListState = useProvider(itemListControllerProvider.state);
    return Scaffold(
      appBar: AppBar(
        title: Text("Todo"),
        leading: authControllerState != null
            ? IconButton(
                onPressed: () => context.read(authControllerProvider).signOut(),
                icon: Icon(Icons.logout))
            : null,
      ),
      body: ListView.builder(
        itemCount: itemListState.data?.value.length,
        itemBuilder: (BuildContext context, int index) {
          final item = itemListState.data?.value[index];
          return Text(item!.name);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => CreateEditItemDialog.show(context, Item.empty()),
        child: Icon(Icons.add),
      ),
    );
  }
}

class CreateEditItemDialog extends HookWidget {
  static void show(BuildContext context, Item item) {
    showDialog(
      context: context,
      builder: (context) => CreateEditItemDialog(item: item),
    );
  }

  final Item item;

  const CreateEditItemDialog({Key? key, required this.item}) : super(key: key);

  bool get isUpdating => item.id != null;

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController(text: item.name);
    return Dialog(
      child: Column(
        children: [
          TextField(
            controller: textController,
            autofocus: true,
          ),
          ElevatedButton(
            onPressed: () {
              context
                  .read(itemListControllerProvider)
                  .addItem(name: textController.text.trim());
            },
            child: Text("Create"),
          )
        ],
      ),
    );
  }
}
