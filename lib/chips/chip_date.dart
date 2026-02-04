import 'package:criteria/chips/chip_controllers.dart';
import 'package:criteria/chips/config.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChipDate extends StatefulWidget {
  const ChipDate({required this.controller, super.key});

  final ChipDateController controller;
  @override
  State<ChipDate> createState() => _ChipDateState();
}

class _ChipDateState extends State<ChipDate> with ChipsAssets {
  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    super.dispose();
  }

  @override
  void initState() {
    widget.controller.addListener(_refresh);
    super.initState();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<DateTime?> _selectDate(
    BuildContext context,
    DateTime? initialDate,
  ) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: Colors.blue),
          ),
          child: child!,
        );
      },
    );
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
                    await _selectDate(context, widget.controller.date).then((
                      value,
                    ) {
                      setState(() {
                        if (value != null) {
                          widget.controller.date = value;
                        }
                      });
                    });
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
                        widget.controller.date != null
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    DateFormat(
                                      'dd/MM/yy',
                                    ).format(widget.controller.date!),
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

  Widget _buildLayout2() {
    return Opacity(
      opacity: widget.controller.disable ? 0.5 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          borderRadius: BorderRadius.circular(8),
          color: widget.controller.disable
              ? Colors.grey.shade300
              : widget.controller.backgroundColor,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: widget.controller.disable
                ? null
                : () async {
                    widget.controller.updating = true;
                    await _selectDate(context, widget.controller.date).then((
                      value,
                    ) {
                      setState(() {
                        if (value != null) {
                          widget.controller.date = value;
                        }
                      });
                    });
                    widget.controller.updating = false;
                  },
            child: IntrinsicWidth(
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 100, maxWidth: 200),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText:
                        (widget.controller.updating ||
                                widget.controller.hasValue()) &&
                            !widget.controller.hideLabelIfNotEmpty
                        ? widget.controller.label
                        : null,
                    labelStyle: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: widget.controller.backgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: widget.controller.date != null
                            ? Colors.blue.shade400
                            : Colors.grey.shade300,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.blue.shade400),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: widget.controller.date != null
                              ? Colors.blue.shade50
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: widget.controller.date != null
                              ? Colors.blue.shade600
                              : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            widget.controller.date != null
                                ? Text(
                                    DateFormat(
                                      'dd/MM/yy',
                                    ).format(widget.controller.date!),
                                    style: widget.controller.textStyle.copyWith(
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                : Text(
                                    widget.controller.label,
                                    style: widget.controller.emptyLabelStyle
                                        .copyWith(color: Colors.grey.shade600),
                                  ),
                          ],
                        ),
                      ),
                      if (widget.controller.displayRemoveButton &&
                          widget.controller.date != null) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: widget.controller.disable
                              ? null
                              : () => widget.controller.clean(),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.clear,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ] else if (!widget.controller.alwaysDisplayed) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: widget.controller.disable
                              ? null
                              : () => onRemove(),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.red.shade600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void onRemove() {
    widget.controller.date = null;
    widget.controller.updating = false;
    widget.controller.displayed = false;
  }
}

class ChipDateController extends ChipItemController {
  ChipDateController({
    required super.name,
    required super.group,
    super.label,
    super.avatar = const Icon(Icons.calendar_today, size: 24),
    super.chipType = ChipType.date,
    super.onEnter,
  });

  DateTime? _date;

  DateTime? get date => _date;
  set date(DateTime? value) {
    if (value != _date) {
      _date = value;
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
  bool hasValue() => _date != null;
  @override
  void clean() {
    date = null;
    updating = false;
    notifyListeners();
  }

  @override
  dynamic get value => displayed ? _date : null;

  @override
  set value(dynamic newValue) {
    // Si la valeur est une chaîne au format ISO 8601, la convertir en DateTime
    if (newValue is String) {
      try {
        newValue = DateTime.parse(newValue);
      } catch (e) {
        debugPrint('Erreur lors de la conversion de la date: $e');
      }
    }

    if (newValue != _date) {
      _date = newValue;
      notifyListeners();
    }
  }

  @override
  Map<String, dynamic> get toJson {
    return {
      "name": name,
      "type": chipType.value,
      "value": _date?.toIso8601String(),
      "displayed": displayed,
    };
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }
}
