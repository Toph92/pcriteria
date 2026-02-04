// import 'dart:convert';
import 'dart:math' as math;

import 'package:criteria/chips/chips.dart';
import 'package:flutter/material.dart';
import 'package:showcase/views/common.dart';
import 'package:url_launcher/url_launcher.dart';

class Page6 extends StatefulWidget {
  const Page6({super.key});

  @override
  State<Page6> createState() => _Page6State();
}

class _Page6State extends State<Page6> with CommonPages {
  ChipGroup gr4 = ChipGroup(name: "G4", labelText: "Exemples")
    ..backgroundColor = Colors.orange.shade500;

  late ChipsController chipsListControllers;

  @override
  void dispose() {
    chipsListControllers.removeListener(_onUpdate);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    chipsListControllers = ChipsController(name: "test1")
      ..chips = [
        ChipTextCompletionController<User>(
            name: "ex1",
            group: gr4,
            label: "Un critère",

            onRequestUpdateDataSource:
                (
                  List<String>? arCriteria,
                  List<PopupHeaderControllerItem>? popupHeaderItems,
                  Map<SearchOptionKey, dynamic> searchOptions,
                ) async {
                  await Future.delayed(const Duration(milliseconds: 500));
                  return (fakeUsers, null);
                },
          )
          ..alwaysDisplayed = true
          ..comments = "Un critère de recherche avec un filtre"
          ..avatar = Icon(Icons.list, color: Colors.blue.shade800, size: 24)
          ..popupHeaderItems = [
            PopupHeaderControllerItem(key: 'code', label: "Code", value: true),
            PopupHeaderControllerItem(key: 'name', label: "Nom", value: true),
          ]
          ..keepPopupOpen = false
          ..maxEntries = 1,
        ChipTextCompletionController<User>(
            name: "ex2",
            group: gr4,
            label: "Un critère sans filtre",

            onRequestUpdateDataSource:
                (
                  List<String>? arCriteria,
                  List<PopupHeaderControllerItem>? popupHeaderItems,
                  Map<SearchOptionKey, dynamic> searchOptions,
                ) async {
                  await Future.delayed(const Duration(milliseconds: 500));
                  return (fakeUsers, null);
                },
          )
          ..alwaysDisplayed = false
          ..comments = "Un seul critère de recherche"
          ..avatar = Icon(Icons.list, color: Colors.blue.shade600, size: 24)
          ..keepPopupOpen = false
          ..maxEntries = 1
          ..backgroundColor = Colors.green.shade50,
        ChipTextCompletionController<User>(
            name: "ex3",
            group: gr4,
            label: "3 critères",

            onRequestUpdateDataSource:
                (
                  List<String>? arCriteria,
                  List<PopupHeaderControllerItem>? popupHeaderItems,
                  Map<SearchOptionKey, dynamic> searchOptions,
                ) async {
                  await Future.delayed(const Duration(milliseconds: 500));
                  return (fakeUsers, null);
                },
          )
          ..alwaysDisplayed = false
          ..comments = "Trois critères de recherche plusieurs filtres"
          ..avatar = Icon(Icons.list, color: Colors.blue.shade400, size: 24)
          ..popupHeaderItems = [
            PopupHeaderControllerItem(
              key: 'siren',
              label: "SIREN",
              value: true,
            ),
            PopupHeaderControllerItem(
              key: 'raison_sociale',
              label: "Raison sociale",
              value: true,
            ),
            PopupHeaderControllerItem(key: 'code_postal', label: "Code postal"),
            PopupHeaderControllerItem(
              key: 'code_ape',
              label: "Code APE",
              value: true,
            ),
          ]
          ..keepPopupOpen = false
          ..maxEntries = 3,
        ChipTextCompletionController<User>(
            name: "ex4",
            group: gr4,
            label: "3 critères sans fermeture popup",

            onRequestUpdateDataSource:
                (
                  List<String>? arCriteria,
                  List<PopupHeaderControllerItem>? popupHeaderItems,
                  Map<SearchOptionKey, dynamic> searchOptions,
                ) async {
                  await Future.delayed(const Duration(milliseconds: 500));
                  return (fakeUsers, null);
                },
          )
          ..alwaysDisplayed = false
          ..comments = "Trois critères et le popup reste ouvert sauf le dernier"
          ..avatar = Icon(Icons.list, color: Colors.blue.shade200, size: 24)
          ..keepPopupOpen = true
          ..maxEntries = 3,
        ChipTextCompletionController<User>(
            name: "ex5",
            group: gr4,
            label: "Beaucoup de critères sans fermeture popup",

            onRequestUpdateDataSource:
                (
                  List<String>? arCriteria,
                  List<PopupHeaderControllerItem>? popupHeaderItems,
                  Map<SearchOptionKey, dynamic> searchOptions,
                ) async {
                  await Future.delayed(const Duration(milliseconds: 500));
                  return (fakeUsers, null);
                },
          )
          ..alwaysDisplayed = false
          ..comments = "Trop de critères, le popup reste ouvert"
          ..avatar = Icon(Icons.list, color: Colors.blue.shade100, size: 24)
          ..keepPopupOpen = true
          ..maxEntries = 99
          ..backgroundColor = Colors.pink.shade50,
      ];

    chipsListControllers.addListener(_onUpdate);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _onUpdate() {
    //chipsListControllers.saveCriteria();
    _refresh();
  }

  // Chargement des critères depuis SharedPreferences

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              headerPage(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const RotatedBox(
                      quarterTurns: 2,
                      child: Icon(
                        Icons.format_list_bulleted,
                        color: Colors.orange,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('Exemples auto complétion', style: titleStyle),
                  ],
                ),

                //dropDownLoadProfiles(onUpdate: _refresh),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ChipsCriteria(
                  chipsListControllers: chipsListControllers,
                  groupsFilterDisplay: [gr4],
                  title: "Exemples de listes",

                  chipDisplayMode: [ChipDisplayMode.withTileBorder],
                  titleStyle: TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade800,
                  ),
                ),
              ),
            ],
          ),
          Container(
            color: Colors.grey.withValues(alpha: 0.5),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Calculer l'angle réel de la diagonale basé sur les dimensions
                final double angle = math.atan2(
                  -constraints.maxHeight,
                  constraints.maxWidth,
                );

                return Stack(
                  children: [
                    CustomPaint(
                      painter: DiagonalLinePainter(),
                      child: const SizedBox.expand(),
                    ),
                    Center(
                      child: Transform.rotate(
                        angle: angle,
                        child: Material(
                          elevation: 10,

                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.build_circle_sharp,
                                      color: Colors.orange,
                                      size: 50,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Cassé',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 40,
                                      ),
                                    ),
                                  ],
                                ),
                                Builder(
                                  builder: (context) => InkWell(
                                    onTap: () async {
                                      const url =
                                          "http://desbois.mooo.com/criteria_old/";
                                      try {
                                        await launchUrl(Uri.parse(url));
                                        if (!context.mounted) return;
                                      } catch (e) {
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Impossible d'ouvrir le lien",
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: const Text(
                                      "Actif sur la version précédente",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DiagonalLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade700
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    // Tracer une ligne du coin gauche bas au coin droit haut
    canvas.drawLine(
      Offset(0, size.height), // Coin gauche bas
      Offset(size.width, 0), // Coin droit haut
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
