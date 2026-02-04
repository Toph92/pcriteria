import 'dart:convert';

import 'package:criteria/chips/chips.dart';
import 'package:flutter/material.dart';
import 'package:showcase/views/code_view.dart';
import 'package:showcase/views/codes.dart';
import 'package:showcase/views/common.dart';
import 'package:toolbox/toolbox.dart';

class Page1 extends StatefulWidget {
  const Page1({super.key});

  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1> with CommonPages {
  bool _hoverSearch = false;
  @override
  void dispose() {
    chipsListControllers?.removeListener(_onUpdate);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fillChipsMenu();
    chipsListControllers?.addListener(_onUpdate);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _onUpdate() {
    chipsListControllers?.saveCriteria();
    _refresh();
  }

  void _disableFields() {
    setState(() {
      for (final controller in chipsListControllers!.chips) {
        controller.disable = true;
      }
    });
  }

  // Construction réutilisable du bouton "Rechercher" avec animation au hover
  Widget _buildSearchButton({VoidCallback? onPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hoverSearch = true),
        onExit: (_) => setState(() => _hoverSearch = false),
        cursor: SystemMouseCursors.click,
        child: FilledButton.icon(
          onPressed: onPressed ?? () {},
          label: const Text("Rechercher"),
          icon: AnimatedScale(
            scale: _hoverSearch ? 1.35 : 1.0,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            child: const Icon(Icons.search),
          ),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            children: [
              headerPage(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.density_small, color: Colors.white),
                    const SizedBox(width: 8),
                    Text('Vue compacte', style: titleStyle),
                  ],
                ),
                dropDownLoadProfiles(onUpdate: _refresh),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ChipsCriteria(
                  chipsListControllers: chipsListControllers!,
                  title: "Critères de recherche",
                  chipDisplayMode: [ChipDisplayMode.withTileBorder],
                  titleStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade800,
                  ),
                  helperWidget: const Text(
                    "Ajouter des critères",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

                _buildSearchButton(
                  onPressed: () {
                    debugPrint(prettyPrintJson(chipsListControllers!.value));
                    _disableFields();
                  },
                ),
              ],
            ),
          ),
          const Spacer(),
          TitleBorderBox(
            title: "Exemples de code",
            icon: const Icon(Icons.code, color: Colors.red, size: 26),
            borderColor: Colors.red,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            const PageCodeView(code: Codes.createView1),
                      ),
                    );
                  },
                  child: const Text("Création de cette vue"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            const PageCodeView(code: Codes.createList),
                      ),
                    );
                  },
                  child: const Text("Création de la liste des critères"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            const PageCodeView(code: Codes.createListCountry),
                      ),
                    );
                  },
                  child: const Text("Création de la liste des pays"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            const PageCodeView(code: Codes.createListDPE),
                      ),
                    );
                  },
                  child: const Text("Création de la liste des étiquettes DPE"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String prettyPrintJson(dynamic input, {String indent = '  '}) {
  dynamic obj = input;
  if (input is String) {
    try {
      obj = jsonDecode(input);
    } catch (e) {
      // si ce n'est pas du JSON valide, retourne la chaîne d'origine
      return input;
    }
  }
  final encoder = JsonEncoder.withIndent(indent);
  return encoder.convert(obj);
}
