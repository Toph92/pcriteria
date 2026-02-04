import 'package:criteria/chips/chips.dart';
import 'package:flutter/material.dart';
import 'package:showcase/views/common.dart';

class Page3 extends StatefulWidget {
  const Page3({super.key});

  @override
  State<Page3> createState() => _Page3State();
}

class _Page3State extends State<Page3> with CommonPages {
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
                Text('un', style: titleStyle),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.0),
                  child: Icon(Icons.add_circle, color: Colors.green, size: 30),
                ),
                Text('par groupe', style: titleStyle),
              ],
            ),
            dropDownLoadProfiles(onUpdate: _refresh),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ChipsCriteria(
              chipsListControllers: chipsListControllers!,
              groupsFilterDisplay: [gr1!],
              groupsFilterSelector: [gr1!],
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
              groupsFilterDisplay: [gr2!],
              groupsFilterSelector: [gr2!],
              title: gr2!.labelText,
              backgroundColor: gr2!.backgroundColor.withValues(alpha: 0.3),
              borderColor: gr2!.backgroundColor,
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
              groupsFilterDisplay: [gr3!],
              groupsFilterSelector: [gr3!],
              title: gr3!.labelText,
              backgroundColor: gr3!.backgroundColor.withValues(alpha: 0.3),
              borderColor: gr3!.backgroundColor,
              chipDisplayMode: [ChipDisplayMode.withTileBorder],
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
