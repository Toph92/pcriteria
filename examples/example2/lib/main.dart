import 'dart:convert';
import 'package:criteria/criteria.dart';
import 'package:criteria/credentials.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'user.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Combined Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CombinedExample(),
    );
  }
}

class CombinedExample extends StatefulWidget {
  const CombinedExample({super.key});

  @override
  State<CombinedExample> createState() => _CombinedExampleState();
}

class _CombinedExampleState extends State<CombinedExample> {
  late final ChipTextController _textController;
  late final ChipTextCompletionController<User> _clientController;
  late final ChipBooleanController _booleanController;

  @override
  void initState() {
    super.initState();

    // Text Controller Init
    _textController =
        ChipTextController(
            name: 'example_text',
            label: 'Saisie de texte',
            avatar: null,
          )
          ..expandable = true
          ..displayRemoveButton = false
          ..removeBorder = true
          ..backgroundColor = Colors.transparent;

    // Client Controller Init
    _clientController =
        ChipTextCompletionController<User>(
            name: "client",
            label: "Client",
            avatar: null,
            onRequestUpdateDataSource:
                (
                  List<String>? arCriteria,
                  List<PopupHeaderControllerItem>? popupHeaderItems,
                  Map<SearchOptionKey, dynamic> searchOptions,
                ) async {
                  try {
                    Map<String, dynamic> searchParams = {};
                    searchParams['criteria'] = arCriteria;

                    if (popupHeaderItems != null &&
                        popupHeaderItems.isNotEmpty) {
                      List<String> activeFilters = popupHeaderItems
                          .where((item) => item.checked)
                          .map((item) => item.key)
                          .toList();
                      if (activeFilters.isNotEmpty) {
                        searchParams['filters'] = activeFilters;
                      }
                    } else {
                      searchParams['filters'] = [];
                    }
                    searchParams['searchOptions'] = jsonEncode(
                      searchOptions.map(
                        (key, value) => MapEntry(key.toString(), value),
                      ),
                    );

                    final uri = Uri.parse(
                      'http://109.24.210.55/apicriteria/api/users/search',
                    );
                    String username = Credentials.username;
                    String password = Credentials.password;
                    String basicAuth =
                        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

                    final response = await http
                        .post(
                          uri,
                          headers: {
                            'Content-Type': 'application/json',
                            'Accept': 'application/json',
                            'Authorization': basicAuth,
                          },
                          body: json.encode(searchParams),
                        )
                        .timeout(const Duration(seconds: 5));

                    if (response.statusCode == 200) {
                      Map<String, dynamic> jsonTmp = json.decode(response.body);
                      final List<dynamic> jsonData =
                          jsonTmp['data'] as List<dynamic>;
                      return (
                        jsonData
                            .map(
                              (userData) => User(
                                sID: userData['i'] ?? '',
                                firstName: userData['p'],
                                lastName: userData['n'] ?? '',
                              ),
                            )
                            .toList(),
                        jsonTmp['meta'] as Map<String, dynamic>?,
                      );
                    } else {
                      debugPrint(
                        'HTTP Error: ${response.statusCode} - ${response.body}',
                      );
                      return (null, null);
                    }
                  } catch (e) {
                    debugPrint('Error fetching users: $e');
                    return (null, null);
                  }
                },
          )
          ..fuzzySearchStep = 1
          ..maxResults = 100
          ..alwaysDisplayed = true
          ..comments = "Autocompletion de clients"
          ..avatar = null
          /*..popupHeaderItems = [
            PopupHeaderControllerItem(key: 'id', label: "Code"),
            PopupHeaderControllerItem(
              key: 'firstname',
              label: "Prénoms",
              checked: true,
            ),
            PopupHeaderControllerItem(
              key: 'lastname',
              label: "Nom",
              checked: true,
            ),
          ]*/
          ..keepPopupOpen = true
          ..maxEntries = 3
          ..removeBorder = true
          ..backgroundColor = Colors.transparent
          ..popupBackgroundColor = Colors.yellow.shade100
          ..chipHeightSize = 28;
    // Boolean Controller Init
    _booleanController =
        ChipBooleanController(
            name: 'boolean_example',
            group: ChipGroup(name: 'Boolean Group', labelText: 'Boolean Group'),
            avatar: null,

            label: 'Actif',
          )
          ..expandable = true
          ..displayRemoveButton = false;
  }

  @override
  void dispose() {
    _textController.dispose();
    _clientController.dispose();
    _booleanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Combined Example'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Text Example
            const Text(
              'Exemple ChipText :',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
              color: Colors.yellow,
              width: 300,
              child: ChipText(controller: _textController),
            ),
            const SizedBox(height: 20),
            Text(
              'Valeur texte : ${_textController.value ?? "Aucune"}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                debugPrint('Texte : ${_textController.value}');
                setState(() {});
              },
              child: const Text('Valider Texte'),
            ),
            const Divider(height: 40, thickness: 2),

            // Client Example
            const Text(
              'Exemple Autocompletion :',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisSize: .min,
              children: [
                Container(
                  color: Colors.yellow,
                  width: 300,
                  child: ChipTextCompletion(controller: _clientController),
                ),
                ElevatedButton(
                  onPressed: () {
                    debugPrint(
                      'Clients : ${_clientController.value!.first.sID}',
                    );
                    setState(() {});
                  },
                  child: const Text('Valider Clients'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Clients selectionnés :',
              style: const TextStyle(fontSize: 16),
            ),
            ListenableBuilder(
              listenable: _clientController,
              builder: (context, _) {
                if (_clientController.value == null ||
                    _clientController.value!.isEmpty) {
                  return const Text("Aucun");
                }
                return Column(
                  children: _clientController.value!
                      .map((u) => Text(u.toString()))
                      .toList(),
                );
              },
            ),
            const Divider(height: 40, thickness: 2),

            // Boolean Example
            const Text(
              'Exemple ChipBoolean :',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 300,
              child: ChipBoolean(controller: _booleanController),
            ),
            const SizedBox(height: 10),
            ListenableBuilder(
              listenable: _booleanController,
              builder: (context, _) {
                return Text(
                  'Valeur : ${_booleanController.value}',
                  style: const TextStyle(fontSize: 16),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
