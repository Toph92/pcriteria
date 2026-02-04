import 'package:criteria/chips/chips.dart';
import 'package:flutter/material.dart';
import 'package:showcase/views/code_view.dart';
import 'package:showcase/views/codes.dart';
import 'package:showcase/views/common.dart';
import 'package:toolbox/toolbox.dart';

class Page2 extends StatefulWidget {
  const Page2({super.key});

  @override
  State<Page2> createState() => _Page2State();
}

class _Page2State extends State<Page2> with CommonPages {
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
                const Icon(Icons.density_medium, color: Colors.white),
                const SizedBox(width: 8),
                Text('Vue par groupe', style: titleStyle),
              ],
            ),
            dropDownLoadProfiles(onUpdate: _refresh),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ChipsCriteria(
              chipsListControllers: chipsListControllers!,
              title: "Critères de recherche",
              chipDisplayMode: [ChipDisplayMode.buttonOnly],
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
              groupsFilterDisplay: [gr1!],
              title: gr1!.labelText,
              backgroundColor: gr1!.backgroundColor.withValues(alpha: 0.2),
              borderColor: gr1!.backgroundColor,
              chipDisplayMode: [
                ChipDisplayMode.criteriaOnly,
                ChipDisplayMode.withTileBorder,
              ],
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
              groupsFilterDisplay: [gr2!],
              title: gr2!.labelText,
              backgroundColor: gr2!.backgroundColor.withValues(alpha: 0.3),
              borderColor: gr2!.backgroundColor,
              chipDisplayMode: [
                ChipDisplayMode.criteriaOnly,
                ChipDisplayMode.withTileBorder,
              ],
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
              groupsFilterDisplay: [gr3!],
              title: gr3!.labelText,
              backgroundColor: gr3!.backgroundColor.withValues(alpha: 0.3),
              borderColor: gr3!.backgroundColor,
              chipDisplayMode: [
                ChipDisplayMode.criteriaOnly,
                ChipDisplayMode.withTileBorder,
              ],
              titleStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey.shade800,
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
                            const PageCodeView(code: Codes.createView2),
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
