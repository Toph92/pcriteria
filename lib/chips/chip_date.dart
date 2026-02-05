import 'package:criteria/chips/chip_controllers.dart';
import 'package:criteria/chips/chip_decorator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChipDate extends StatefulWidget {
  const ChipDate({required this.controller, super.key});

  final ChipDateController controller;
  @override
  State<ChipDate> createState() => _ChipDateState();
}

class _ChipDateState extends State<ChipDate> {
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
    return ChipDecorator(
      controller: widget.controller,
      onTap: () async {
        widget.controller.updating = true;
        await _selectDate(context, widget.controller.date).then((value) {
          setState(() {
            if (value != null) {
              widget.controller.date = value;
            }
          });
        });
        widget.controller.updating = false;
      },
      child: widget.controller.date != null
          ? Text(
              DateFormat('dd/MM/yy').format(widget.controller.date!),
              style: widget.controller.textStyle,
            )
          : Text(
              '${widget.controller.label} ?',
              style: widget.controller.emptyLabelStyle,
            ),
    );
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
