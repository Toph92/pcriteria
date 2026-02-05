import 'package:criteria/criteria.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChipText Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ChipTextExample(),
    );
  }
}

class ChipTextExample extends StatefulWidget {
  const ChipTextExample({super.key});

  @override
  State<ChipTextExample> createState() => _ChipTextExampleState();
}

class _ChipTextExampleState extends State<ChipTextExample> {
  late final ChipTextController _textController;

  @override
  void initState() {
    super.initState();
    _textController = ChipTextController(
      name: 'example_text',
      group: ChipGroup(name: 'Example Group', labelText: 'Example Group'),
      label: 'Saisie de texte',
    );
    _textController.editingWidth
    //_textController.addListener(_refresh);
  }

  @override
  void dispose() {
    //_textController.removeListener(_refresh);
    _textController.dispose();
    super.dispose();
  }

  //void _refresh() {
  //  if (mounted) setState(() {});
  //}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('ChipText Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Exemple d\'utilisation de ChipText :',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ChipText(controller: _textController),
            const SizedBox(height: 40),
            Text(
              'Valeur saisie : ${_textController.value ?? "Aucune"}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                debugPrint('Contenu du texte saisi : ${_textController.value}');
              },
              child: const Text('Valider'),
            ),
          ],
        ),
      ),
    );
  }
}
