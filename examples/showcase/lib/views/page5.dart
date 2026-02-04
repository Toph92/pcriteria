import 'package:criteria/chips/chips.dart';
import 'package:flutter/material.dart';
import 'package:showcase/views/code_view.dart';
import 'package:showcase/views/codes.dart';
import 'package:showcase/views/common.dart';
import 'package:toolbox/toolbox.dart';

class Page5 extends StatefulWidget {
  const Page5({super.key});

  @override
  State<Page5> createState() => _Page5State();
}

class _Page5State extends State<Page5> with CommonPages {
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

  // Chargement des critères depuis SharedPreferences

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headerPage(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const RotatedBox(
                  quarterTurns: 2,
                  child: Icon(Icons.shuffle, color: Colors.pink, size: 28),
                ),
                const SizedBox(width: 8),
                Text('Autre vue mixte', style: titleStyle),
              ],
            ),

            dropDownLoadProfiles(onUpdate: _refresh),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ChipsCriteria(
              chipsListControllers: chipsListControllers!,
              groupsFilterDisplay: [gr1!],
              title: gr1!.labelText,
              backgroundColor: gr1!.backgroundColor.withValues(alpha: 0.2),
              borderColor: gr1!.backgroundColor,
              chipDisplayMode: [ChipDisplayMode.withTileBorder],
              titleStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey.shade800,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ChipsCriteria(
              chipsListControllers: chipsListControllers!,
              groupsFilterDisplay: [gr2!, gr3!],
              title: "Autre critères",
              backgroundColor: Colors.yellow.shade100,
              borderColor: Colors.pink,
              chipDisplayMode: [
                ChipDisplayMode.criteriaOnly,
                ChipDisplayMode.withTileBorder,
              ],
              titleStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: Colors.green,
              ),
            ),
          ),
          const Spacer(),
          TitleBorderBox(
            title: "Exemple de code",
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
                            const PageCodeView(code: Codes.createView5),
                      ),
                    );
                  },
                  child: const Text("Création de cette vue"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
