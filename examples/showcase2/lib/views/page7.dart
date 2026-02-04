import 'package:criteria/chips/chips.dart';
import 'package:criteria/chips/config.dart';
import 'package:flutter/material.dart';
import 'package:showcase/views/common.dart';

class Page7 extends StatefulWidget {
  const Page7({super.key});

  @override
  State<Page7> createState() => _Page7State();
}

class _Page7State extends State<Page7> with CommonPages {
  late ChipsController chipsCtrl;
  late ChipListController flags;
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    flags = ChipListController(name: "country", group: gr2!, label: "Pays")
      //..alwaysDisplayed = true
      ..comments = "Un exemple de liste"
      ..dataset = items
      ..toolTipMessage = "Sélectionnez un pays"
      ..avatar = const Icon(Icons.flag, size: 22)
      ..gridAlign = Alignment.center
      ..gridCols = 2
      ..gridAspectRatio = 2
      ..displayMode = ChipListDisplayMode.iconAndShortDescription
      ..displayModeHoverPopup = ChipListDisplayMode.iconAndShortDescription
      ..multiSelect = true
      ..quitOnSelect = false
      ..displayModeStepQty = 4
      ..popupXoffset = 0.0
      ..alwaysDisplayed = true;
    //fillChipsMenu();
    chipsCtrl = ChipsController(name: "test2")..chips = [flags];
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  // Chargement des critères depuis SharedPreferences

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          headerPage(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.settings, color: Colors.white, size: 28),
                const SizedBox(width: 8),
                Text('Configurateur de liste', style: titleStyle),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ChipsCriteria(
              chipsListControllers: chipsCtrl,
              chipLayout: ChipLayout.layout2,
              chipDisplayMode: [ChipDisplayMode.criteriaOnly],
            ),
          ),
          Divider(color: gr1!.backgroundColor, height: 2),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: SingleChildScrollView(
                child: ChipListTester(controller: flags, onChanged: _refresh),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
