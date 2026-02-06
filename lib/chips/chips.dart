import 'package:criteria/chips/chip_add.dart';
import 'package:criteria/chips/chip_boolean.dart';
import 'package:criteria/chips/chip_controllers.dart';
import 'package:criteria/chips/chip_date.dart';
import 'package:criteria/chips/chip_dates_range.dart';
import 'package:criteria/chips/chip_list.dart';
import 'package:criteria/chips/chip_range.dart';
import 'package:criteria/chips/chip_text.dart';
import 'package:criteria/chips/chip_text_completion.dart';
import 'package:criteria/chips/config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:toolbox/toolbox.dart';

export 'chip_add.dart';
export 'chip_boolean.dart';
export 'chip_controllers.dart';
export 'chip_date.dart';
export 'chip_dates_range.dart';
export 'chip_list.dart';
export 'chip_list_maker.dart';
export 'chip_range.dart';
export 'chip_text.dart';
export 'chip_text_completion.dart';

class ChipsCriteria extends StatefulWidget {
  const ChipsCriteria({
    required this.chipsListControllers,
    super.key,
    this.title,
    this.titleStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
    this.backgroundColor = Colors.transparent,
    this.borderColor = Colors.grey,
    this.helperWidget,
    this.chipDisplayMode = const [],
    this.groupsFilterDisplay,
    this.groupsFilterSelector,
    this.showEraseAllButton = true,
  });

  final String? title;
  final Widget? helperWidget;
  final List<ChipDisplayMode> chipDisplayMode;
  final List<ChipGroup>? groupsFilterDisplay;
  final List<ChipGroup>? groupsFilterSelector;

  final bool showEraseAllButton;

  final ChipsController chipsListControllers;
  final TextStyle titleStyle;
  final Color backgroundColor;
  final Color borderColor;

  @override
  State<ChipsCriteria> createState() => _ChipsCriteriaState();
}

class _ChipsCriteriaState extends State<ChipsCriteria>
    with WidgetsBindingObserver {
  final GlobalKey _wrapKey = GlobalKey();
  final GlobalKey _btnEraseKey = GlobalKey();
  double _wrapHeight = 0;
  List<String> _groupsNameFilterDisplay = [];
  List<ChipItemController> _chips = [];

  @override
  void initState() {
    if (!kDebugMode) {
      desktopMode = null;
    }
    assert(
      !(widget.chipDisplayMode.contains(ChipDisplayMode.buttonOnly) &&
          widget.chipDisplayMode.contains(ChipDisplayMode.criteriaOnly)),
      "Cannot use buttonOnly and criteriaOnly at the same time",
    );
    super.initState();
    _groupsNameFilterDisplay =
        widget.groupsFilterDisplay?.map((e) => e.name).toList() ?? [];

    WidgetsBinding.instance.addObserver(this);
    updateDataset();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    // Appelé lorsque les métriques d'affichage changent (redimensionnement de fenêtre)
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateWrapHeight());
  }

  void _updateWrapHeight() {
    if (_wrapKey.currentContext != null) {
      final RenderBox renderBox =
          _wrapKey.currentContext!.findRenderObject() as RenderBox;
      setState(() {
        _wrapHeight = renderBox.size.height;
      });
      //print('Hauteur actuelle du Wrap: $_wrapHeight pixels');
    }
  }

  @override
  void didUpdateWidget(ChipsCriteria oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateDataset();
  }

  void updateDataset() {
    _chips = widget.chipsListControllers.chips
        .where(
          (element) =>
              element.displayed &&
              (_groupsNameFilterDisplay.contains(element.group!.name) ||
                  _groupsNameFilterDisplay.isEmpty),
        )
        .toList();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateWrapHeight());
  }

  @override
  Widget build(BuildContext context) {
    Widget? body;
    if (widget.chipDisplayMode.contains(ChipDisplayMode.buttonOnly)) {
      body = ChipAdd(
        controller: widget.chipsListControllers,
        groupsFilterSelector: widget.groupsFilterSelector,
      );
    } else if (widget.chipDisplayMode.contains(ChipDisplayMode.criteriaOnly)) {
      body = _wdWrapListCriteria();
    } else {
      body ??= OS.isDesktop(desktopMode) || OS.isWeb()
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    body = ChipAdd(
                      controller: widget.chipsListControllers,
                      groupsFilterSelector: widget.groupsFilterSelector,
                    ),
                    if (widget.showEraseAllButton &&
                        _wrapHeight > 80 &&
                        _chips.where((e) => e.hasValue()).isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2.0),
                        child: IconButton.filled(
                          tooltip: widget
                              .chipsListControllers
                              .eraseAllCriteriaTooltipMessage,
                          key: _btnEraseKey,
                          onPressed: () {
                            setState(() {
                              for (final element
                                  in widget.chipsListControllers.chips) {
                                element.clean();
                              }
                            });
                          },
                          icon: const Icon(Icons.recycling),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    /* Container(
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.orange.shade50,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              setState(() {
                                for (final element
                                    in widget.chipsListControllers.chips) {
                                  element.clean();
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.orange.shade300,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.refresh,
                                color: Colors.orange.shade600,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),*/
                  ],
                ),
                _separatorAndHelper(),
                Expanded(child: _wdWrapListCriteria()),
              ],
            )
          : Wrap(
              key: _wrapKey,
              runSpacing: 2,
              spacing: 4,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    body = ChipAdd(
                      //key: const Key("chip_add"),
                      controller: widget.chipsListControllers,
                      groupsFilterSelector: widget.groupsFilterSelector,
                    ),
                    _separatorAndHelper(),
                  ],
                ),
                ..._listChips(),
              ],
            );
    }

    if (widget.chipDisplayMode.contains(ChipDisplayMode.withTileBorder)) {
      if (_chips.isEmpty &&
          widget.chipDisplayMode.contains(ChipDisplayMode.criteriaOnly)) {
      } else {
        body = TitleBorderBox(
          backgroundColor: widget.backgroundColor,
          borderColor: widget.borderColor,
          title: widget.title,
          titleStyle: widget.titleStyle,
          child: body,
        );
      }
    }
    return body;
  }

  Widget _wdWrapListCriteria() => Wrap(
    key: _wrapKey,
    runSpacing: 6,
    spacing: 4,
    children: _listChips(), // Conversion explicite en liste
  );

  List<Widget> _listChips() {
    return _chips.map<Widget>((e) {
      switch (e) {
        case ChipTextController():
          return ChipText(controller: e);
        case ChipListController():
          return ChipList(controller: e);
        case ChipDatesRangeController():
          return ChipDatesRange(controller: e);
        case ChipDateController():
          return ChipDate(controller: e);
        case ChipBooleanController():
          return ChipBoolean(controller: e);
        case ChipTextCompletionController<SearchEntry>():
          return ChipTextCompletion(controller: e);
        case ChipRangeController():
          return ChipRange(controller: e);

        default:
          if (kDebugMode) {
            throw Exception("Unknown chip type");
          }
          return const SizedBox.shrink();
      }
    }).toList();
  }

  Widget _separatorAndHelper() {
    return widget.chipsListControllers.chips
            .where((element) => element.displayed)
            .isNotEmpty
        ? const VerticalDivider(width: 8)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 8),
              widget.helperWidget ?? const SizedBox.shrink(),
            ],
          );
  }
}

enum ChipDisplayMode { buttonOnly, criteriaOnly, withTileBorder }
