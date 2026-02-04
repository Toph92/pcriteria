import 'package:criteria/criteria.dart';
import 'package:flutter/material.dart';
import 'package:showcase/views/common.dart';

class Page4 extends StatefulWidget {
  const Page4({super.key});

  @override
  State<Page4> createState() => _Page4State();
}

class _Page4State extends State<Page4> with CommonPages {
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
                const Icon(Icons.shuffle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Vue mixte', style: titleStyle),
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
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ChipsCriteria(
              chipsListControllers: chipsListControllers!,
              groupsFilterDisplay: [gr2!, gr3!],
              title: gr2!.labelText,
              backgroundColor: gr2!.backgroundColor.withValues(alpha: 0.3),
              borderColor: gr2!.backgroundColor,
              chipDisplayMode: [ChipDisplayMode.criteriaOnly],
              titleStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
