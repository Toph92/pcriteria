import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:criteria/chips/chip_controllers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChipDatesRange extends StatefulWidget {
  const ChipDatesRange({required this.controller, super.key});

  final ChipDatesRangeController controller;
  @override
  State<ChipDatesRange> createState() => _ChipDatesRangeState();
}

class _ChipDatesRangeState extends State<ChipDatesRange> with ChipsAssets {
  @override
  void dispose() {
    widget.controller.focusNode.removeListener(_onFocusChange);
    widget.controller.removeListener(_refresh);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    widget.controller.focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_refresh);
  }

  void _onFocusChange() async {
    if (!widget.controller.focusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 100), () {
        widget.controller.updating = false;
        _refresh();
      });
    }
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _buildLayout1();
  }

  Widget _buildLayout1() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Opacity(
        opacity: widget.controller.disable ? 0.5 : 1.0,
        child: Container(
          constraints: BoxConstraints(minHeight: chipHeightSize + 2),
          decoration: BoxDecoration(
            color: widget.controller.disable
                ? Colors.grey.shade300
                : widget.controller.backgroundColor,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(8.0),
            onTap: widget.controller.disable
                ? null
                : () async {
                    widget.controller.updating = true;
                    var results = await showCalendarDatePicker2Dialog(
                      context: context,
                      config: CalendarDatePicker2WithActionButtonsConfig(
                        calendarType: CalendarDatePicker2Type.range,
                      ),
                      dialogSize: const Size(325, 400),
                      value: [
                        widget.controller.dateRange?.start,
                        widget.controller.dateRange?.end,
                      ],
                      borderRadius: BorderRadius.circular(15),
                    );
                    widget.controller.dateRange = results?.first != null
                        ? DateTimeRange(
                            start: results?.first ?? DateTime.now(),
                            end: results?.last ?? DateTime.now(),
                          )
                        : null;
                    widget.controller.updating = false;
                  },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Avatar/icône
                if (!widget.controller.hideAvatar &&
                    widget.controller.avatar != null)
                  Tooltip(
                    message: widget.controller.comments ?? '',
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12, left: 6),
                      child: widget.controller.avatar,
                    ),
                  ),

                // Contenu principal
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4, left: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        widget.controller.dateRange != null
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.controller.dateRange?.start != null
                                        ? DateFormat('dd/MM/yy').format(
                                            widget.controller.dateRange!.start,
                                          )
                                        : '',
                                    style: widget.controller.textStyle,
                                  ),
                                  Icon(
                                    Icons.double_arrow,
                                    color: Colors.grey.shade500,
                                    size: 18,
                                  ),
                                  Text(
                                    widget.controller.dateRange?.end != null
                                        ? DateFormat('dd/MM/yy').format(
                                            widget.controller.dateRange!.end,
                                          )
                                        : '',
                                    style: widget.controller.textStyle,
                                  ),
                                ],
                              )
                            : Text(
                                '${widget.controller.label} ?',
                                style: widget.controller.emptyLabelStyle,
                              ),
                        if (!widget.controller.updating &&
                            widget.controller.hasValue() &&
                            !widget.controller.hideLabelIfNotEmpty)
                          IgnorePointer(
                            child: Text(
                              widget.controller.label,
                              style: widget.controller.labelStyle.copyWith(
                                height: 0.01,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return tailIcons(
      widget.controller,
      onErase: widget.controller.disable
          ? null
          : () {
              widget.controller.clean();
              _refresh();
            },
      onDelete: widget.controller.disable
          ? null
          : () {
              onRemove();
            },
    );
  }

  void onRemove() {
    widget.controller.dateRange = null;
    widget.controller.updating = false;
    widget.controller.displayed = false;
  }
}

class ChipDatesRangeController extends ChipItemController {
  ChipDatesRangeController({
    required super.name,
    required super.group,
    super.label,
    super.avatar = const Icon(Icons.date_range, size: 24),
    super.chipType = ChipType.datesRange,
    super.onEnter,
  });

  DateTimeRange? _dateRange;

  DateTimeRange? get dateRange => _dateRange;
  set dateRange(DateTimeRange? value) {
    if (value != _dateRange) {
      _dateRange = value;
      notifyListeners();
    }
  }

  FocusNode focusNode = FocusNode();
  bool eraseButton = true;
  bool removeButton = true;
  double editingWidth = 200;
  TextStyle textStyle = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  // inherits default tooltip messages from base class

  @override
  bool hasValue() => _dateRange != null;
  @override
  void clean() {
    dateRange = null;
    updating = false;
    notifyListeners();
  }

  @override
  dynamic get value => displayed ? _dateRange : null;
  @override
  set value(dynamic newValue) {
    assert(
      newValue is DateTimeRange ||
          newValue is Map<String, dynamic> ||
          newValue == null,
      'La valeur doit être de type DateTimeRange ou Map<String, dynamic> ou null',
    );
    // Si la valeur est une chaîne au format ISO 8601, la convertir en DateTime
    if (newValue == null) {
      _dateRange = null;
    } else if (newValue is Map<String, dynamic>) {
      try {
        newValue = DateTimeRange(
          start: DateTime.parse(newValue['start']),
          end: DateTime.parse(newValue['end']),
        );
      } catch (e) {
        debugPrint('Erreur lors de la conversion de la date: $e');
      }
    }
    if (newValue?.start != _dateRange?.start ||
        newValue?.end != _dateRange?.end) {
      _dateRange = DateTimeRange(start: newValue.start, end: newValue.end);
      notifyListeners();
    }
  }

  @override
  Map<String, dynamic> get toJson {
    return {
      "name": name,
      "type": chipType.value,
      "value": _dateRange != null
          ? {
              "start": _dateRange?.start.toIso8601String(),
              "end": _dateRange?.end.toIso8601String(),
            }
          : null,
      "displayed": displayed,
    };
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }
}
