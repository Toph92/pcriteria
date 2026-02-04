import 'package:criteria/chips/chip_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toolbox/toolbox.dart';

class ChipListTester extends StatefulWidget {
  const ChipListTester({required this.controller, super.key, this.onChanged});

  final Function? onChanged;
  final ChipListController controller;

  @override
  State<ChipListTester> createState() => _ChipListTesterState();
}

class _ChipListTesterState extends State<ChipListTester> {
  late ChipListController chipController;

  @override
  void dispose() {
    chipController.removeListener(() {});
    super.dispose();
  }

  @override
  void initState() {
    chipController = widget.controller;
    super.initState();
    chipController.addListener(() {
      _refresh();
    });
  }

  void _refresh() {
    if (mounted) setState(() {});
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return _buildLayout1();
  }

  Widget _buildLayout1() {
    return Wrap(
      spacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TitleBorderBox(
            title: "Chip settings",
            titleStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey.shade800,
            ),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                HightLight(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("MultiSelect"),
                      Checkbox(
                        value: chipController.multiSelect,
                        onChanged: (changed) {
                          chipController.multiSelect = changed!;
                          chipController.quitOnSelect = false;
                          _refresh();
                        },
                      ),
                    ],
                  ),
                ),
                HightLight(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("AlwaysDisplayed"),
                      Checkbox(
                        value: chipController.alwaysDisplayed,
                        onChanged: (changed) {
                          chipController.alwaysDisplayed = changed!;
                          _refresh();
                        },
                      ),
                    ],
                  ),
                ),
                HightLight(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("QuitOnSelect"),
                      Checkbox(
                        value: chipController.quitOnSelect,
                        onChanged: chipController.multiSelect == false
                            ? (changed) {
                                chipController.quitOnSelect = changed!;
                                _refresh();
                              }
                            : null,
                      ),
                    ],
                  ),
                ),

                HightLight(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Display mode"),
                      const SizedBox(width: 8),
                      DropdownButton<ChipListDisplayMode>(
                        value: chipController.displayMode,
                        onChanged: (ChipListDisplayMode? newValue) {
                          if (newValue != null) {
                            chipController.displayMode = newValue;
                            _refresh();
                          }
                        },
                        items: ChipListDisplayMode.values.map((
                          ChipListDisplayMode mode,
                        ) {
                          return DropdownMenuItem<ChipListDisplayMode>(
                            value: mode,
                            child: Text(mode.toString().split('.').last),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                HightLight(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("displayModeStepQty"),
                      Slider(
                        min: 1,
                        max: 8,
                        value: chipController.displayModeStepQty.toDouble(),
                        label: chipController.displayModeStepQty.toString(),
                        divisions: 9,
                        onChanged: (changed) {
                          chipController.displayModeStepQty = changed.toInt();
                          _refresh();
                        },
                      ),
                    ],
                  ),
                ),
                HightLight(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("popupXoffset"),
                      Slider(
                        min: -100,
                        max: 100,
                        value: chipController.popupXoffset,
                        label: chipController.popupXoffset.round().toString(),
                        divisions: 200,
                        onChanged: (changed) {
                          chipController.popupXoffset = changed;
                          _refresh();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TitleBorderBox(
            title: "Grid settings",
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                HightLight(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Grid cols"),
                      Slider(
                        min: 1,
                        max: 5,
                        value: chipController.gridCols.toDouble(),
                        label: chipController.gridCols.toString(),
                        divisions: 4,
                        onChanged: (changed) {
                          chipController.gridCols = changed.toInt();
                          _refresh();
                        },
                      ),
                    ],
                  ),
                ),
                HightLight(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Grid aspect ratio"),
                      Slider(
                        min: 1,
                        max: 10,
                        value: chipController.gridAspectRatio.toDouble(),
                        label: chipController.gridAspectRatio.toStringAsFixed(
                          1,
                        ),
                        divisions: 20,
                        onChanged: (changed) {
                          chipController.gridAspectRatio = changed;
                          _refresh();
                        },
                      ),
                    ],
                  ),
                ),
                HightLight(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Hover display mode"),
                      const SizedBox(width: 8),
                      DropdownButton<ChipListDisplayMode>(
                        value: chipController.displayModeHoverPopup,
                        onChanged: (ChipListDisplayMode? newValue) {
                          if (newValue != null) {
                            chipController.displayModeHoverPopup = newValue;
                            _refresh();
                          }
                        },
                        items: ChipListDisplayMode.values.map((
                          ChipListDisplayMode mode,
                        ) {
                          return DropdownMenuItem<ChipListDisplayMode>(
                            value: mode,
                            child: Text(mode.toString().split('.').last),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                HightLight(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Grid Align"),
                      const SizedBox(width: 8),
                      DropdownButton<Alignment>(
                        value: chipController.gridAlign,
                        onChanged: (Alignment? newValue) {
                          if (newValue != null) {
                            chipController.gridAlign = newValue;
                            _refresh();
                          }
                        },
                        items: const [
                          DropdownMenuItem<Alignment>(
                            value: Alignment.center,
                            child: Text("Center"),
                          ),
                          DropdownMenuItem<Alignment>(
                            value: Alignment.centerLeft,
                            child: Text("Center Left"),
                          ),
                          DropdownMenuItem<Alignment>(
                            value: Alignment.centerRight,
                            child: Text("Center Right"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableRegion(
                selectionControls: materialTextSelectionControls,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("..gridAlign=${chipController.gridAlign}"),
                    Text("..gridCols=${chipController.gridCols}"),
                    Text("..gridAspectRatio=${chipController.gridAspectRatio}"),
                    Text("..displayMode=${chipController.displayMode}"),
                    Text(
                      "..displayModeHoverPopup=${chipController.displayModeHoverPopup}",
                    ),
                    Text("..multiSelect=${chipController.multiSelect}"),
                    Text("..quitOnSelect=${chipController.quitOnSelect}"),
                    Text(
                      "..displayModeStepQty=${chipController.displayModeStepQty}",
                    ),
                    Text("..popupXoffset=${chipController.popupXoffset}"),
                    Text("..alwaysDisplayed=${chipController.alwaysDisplayed}"),
                  ],
                ),
              ),
              const VerticalDivider(color: Colors.grey, width: 12),
              IconButton(
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(
                      text:
                          "..gridAlign=${chipController.gridAlign}\n"
                          "..gridCols=${chipController.gridCols}\n"
                          "..gridAspectRatio=${chipController.gridAspectRatio}\n"
                          "..displayMode=${chipController.displayMode}\n"
                          "..displayModeHoverPopup=${chipController.displayModeHoverPopup}\n"
                          "..multiSelect=${chipController.multiSelect}\n"
                          "..quitOnSelect=${chipController.quitOnSelect}\n"
                          "..displayModeStepQty=${chipController.displayModeStepQty}\n"
                          "..popupXoffset=${chipController.popupXoffset}\n"
                          "..alwaysDisplayed=${chipController.alwaysDisplayed}",
                    ),
                  );
                },
                icon: const Icon(Icons.copy),
                tooltip: "Copier",
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class HightLight extends StatefulWidget {
  const HightLight({required this.child, super.key});
  final Widget child;

  @override
  State<HightLight> createState() => _HightLightState();
}

class _HightLightState extends State<HightLight> {
  Color color = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      padding: const EdgeInsets.all(8.0),

      child: MouseRegion(
        onHover: (event) {
          setState(() {
            color = Colors.yellow.shade100;
          });
        },
        onExit: (event) {
          setState(() {
            color = Colors.white;
          });
        },
        child: Padding(padding: const EdgeInsets.all(8.0), child: widget.child),
      ),
    );
  }
}
