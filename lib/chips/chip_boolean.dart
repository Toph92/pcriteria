import 'package:criteria/chips/chip_controllers.dart';
import 'package:criteria/chips/chip_decorator.dart';
import 'package:flutter/material.dart';

class ChipBoolean extends StatefulWidget {
  const ChipBoolean({required this.controller, super.key});

  final ChipBooleanController controller;

  @override
  State<ChipBoolean> createState() => _ChipBooleanState();
}

class _ChipBooleanState extends State<ChipBoolean> {
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

  @override
  Widget build(BuildContext context) {
    return ChipDecorator(
      controller: widget.controller,
      onTap: () {
        widget.controller.value = !(widget.controller.value ?? false);
        _refresh();
      },
      child: widget.controller.value ?? false
          ? Icon(Icons.check_box, color: widget.controller.checkColor)
          : Icon(
              Icons.check_box_outline_blank,
              color: widget.controller.checkColor.withValues(alpha: 0.5),
            ),
    );
  }
}

class ChipBooleanController extends ChipItemController {
  ChipBooleanController({
    required super.name,
    required super.group,
    super.label,
    super.avatar = const Icon(Icons.check, size: 24),
    super.chipType = ChipType.boolean,
    super.onEnter,
  }) {
    _focusNode = FocusNode()..addListener(_onFocusChange);
    displayEraseButton = false;
  }

  bool _value = false;

  late final FocusNode _focusNode;
  FocusNode get focusNode => _focusNode;

  bool removeButton = true;
  TextStyle textStyle = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  Color checkColor = Colors.grey.shade800;

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      updating = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  bool hasValue() {
    return _value;
  }

  @override
  void clean() {
    _value = false;
    updating = false;
    notifyListeners();
  }

  @override
  bool? get value => displayed ? _value : null;

  @override
  set value(dynamic newValue) {
    if (newValue != _value) {
      _value = newValue;
      displayed = true;
      notifyListeners();
    }
  }

  @override
  Map<String, dynamic> get toJson {
    return {
      "name": name,
      "type": chipType.value,
      "value": _value,
      'displayed': displayed,
    };
  }
}
