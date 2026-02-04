import 'package:criteria/chips/chip_list.dart';
import 'package:criteria/chips/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toolbox/toolbox.dart';

class ChipListTester extends StatefulWidget {
  const ChipListTester({
    required this.controller,
    this.layout,
    super.key,
    this.onChanged,
  });

  final Function? onChanged;
  final ChipListController controller;
  final ChipLayout? layout;

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
    return widget.layout == ChipLayout.layout2
        ? _buildLayout2()
        : _buildLayout1();
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

  Widget _buildLayout2() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.tune, color: Colors.blue.shade600, size: 24),
              const SizedBox(width: 8),
              Text(
                'Configuration des Listes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Configuration sections in a grid layout
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildSettingsCard(
                title: 'Paramètres généraux',
                icon: Icons.settings,
                children: [
                  _buildToggleOption(
                    'Sélection multiple',
                    chipController.multiSelect,
                    (value) {
                      chipController.multiSelect = value!;
                      chipController.quitOnSelect = false;
                      _refresh();
                    },
                  ),
                  _buildToggleOption(
                    'Toujours affiché',
                    chipController.alwaysDisplayed,
                    (value) {
                      chipController.alwaysDisplayed = value!;
                      _refresh();
                    },
                  ),
                  _buildToggleOption(
                    'Fermer après sélection',
                    chipController.quitOnSelect,
                    chipController.multiSelect
                        ? null
                        : (value) {
                            chipController.quitOnSelect = value!;
                            _refresh();
                          },
                  ),
                  _buildDropdownOption<ChipListDisplayMode>(
                    'Mode d\'affichage',
                    chipController.displayMode,
                    ChipListDisplayMode.values,
                    (value) {
                      if (value != null) {
                        chipController.displayMode = value;
                        _refresh();
                      }
                    },
                    (mode) => mode.toString().split('.').last,
                  ),
                ],
              ),

              _buildSettingsCard(
                title: 'Paramètres de grille',
                icon: Icons.grid_view,
                children: [
                  _buildSliderOption(
                    'Colonnes de grille',
                    chipController.gridCols.toDouble(),
                    1,
                    5,
                    4,
                    (value) {
                      chipController.gridCols = value.toInt();
                      _refresh();
                    },
                    chipController.gridCols.toString(),
                  ),
                  _buildSliderOption(
                    'Ratio d\'aspect',
                    chipController.gridAspectRatio,
                    1,
                    10,
                    20,
                    (value) {
                      chipController.gridAspectRatio = value;
                      _refresh();
                    },
                    chipController.gridAspectRatio.toStringAsFixed(1),
                  ),
                  _buildDropdownOption<ChipListDisplayMode>(
                    'Mode survol popup',
                    chipController.displayModeHoverPopup,
                    ChipListDisplayMode.values,
                    (value) {
                      if (value != null) {
                        chipController.displayModeHoverPopup = value;
                        _refresh();
                      }
                    },
                    (mode) => mode.toString().split('.').last,
                  ),
                  _buildDropdownOption<Alignment>(
                    'Alignement grille',
                    chipController.gridAlign,
                    [
                      Alignment.center,
                      Alignment.centerLeft,
                      Alignment.centerRight,
                    ],
                    (value) {
                      if (value != null) {
                        chipController.gridAlign = value;
                        _refresh();
                      }
                    },
                    (alignment) {
                      if (alignment == Alignment.center) return 'Centre';
                      if (alignment == Alignment.centerLeft) return 'Gauche';
                      if (alignment == Alignment.centerRight) return 'Droite';
                      return 'Centre';
                    },
                  ),
                ],
              ),

              _buildSettingsCard(
                title: 'Paramètres avancés',
                icon: Icons.settings_suggest,
                children: [
                  _buildSliderOption(
                    'Quantité par étape',
                    chipController.displayModeStepQty.toDouble(),
                    1,
                    8,
                    7,
                    (value) {
                      chipController.displayModeStepQty = value.toInt();
                      _refresh();
                    },
                    chipController.displayModeStepQty.toString(),
                  ),
                  _buildSliderOption(
                    'Décalage popup X',
                    chipController.popupXoffset,
                    -100,
                    100,
                    200,
                    (value) {
                      chipController.popupXoffset = value;
                      _refresh();
                    },
                    chipController.popupXoffset.round().toString(),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Configuration summary and copy section
          _buildConfigurationSummary(),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: Colors.blue.shade600, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Column(children: children),
        ],
      ),
    );
  }

  Widget _buildToggleOption(
    String label,
    bool value,
    ValueChanged<bool?>? onChanged,
  ) {
    return HightLight(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue.shade600,
            inactiveTrackColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownOption<T>(
    String label,
    T value,
    List<T> items,
    ValueChanged<T?> onChanged,
    String Function(T) itemToString,
  ) {
    return HightLight(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButton<T>(
              value: value,
              onChanged: onChanged,
              isExpanded: true,
              underline: Container(height: 1, color: Colors.grey.shade300),
              items: items.map((T mode) {
                return DropdownMenuItem<T>(
                  value: mode,
                  child: Text(itemToString(mode)),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderOption(
    String label,
    double value,
    double min,
    double max,
    int divisions,
    ValueChanged<double> onChanged,
    String displayValue,
  ) {
    return HightLight(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const Spacer(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Slider(
                  value: value,
                  min: min,
                  max: max,
                  divisions: divisions,
                  onChanged: onChanged,
                  activeColor: Colors.blue.shade600,
                  inactiveColor: Colors.grey.shade300,
                ),
                const SizedBox(height: 4),
                Text(
                  displayValue,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigurationSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Résumé de la configuration',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),

          const SizedBox(height: 12),

          SelectableText(
            _getConfigurationText(),
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),

          const SizedBox(height: 12),

          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _getConfigurationText()));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Configuration copiée dans le presse-papiers.'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copier la configuration'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getConfigurationText() {
    return "..gridAlign=${chipController.gridAlign}\n"
        "..gridCols=${chipController.gridCols}\n"
        "..gridAspectRatio=${chipController.gridAspectRatio}\n"
        "..displayMode=${chipController.displayMode}\n"
        "..displayModeHoverPopup=${chipController.displayModeHoverPopup}\n"
        "..multiSelect=${chipController.multiSelect}\n"
        "..quitOnSelect=${chipController.quitOnSelect}\n"
        "..displayModeStepQty=${chipController.displayModeStepQty}\n"
        "..popupXoffset=${chipController.popupXoffset}\n"
        "..alwaysDisplayed=${chipController.alwaysDisplayed}";
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
