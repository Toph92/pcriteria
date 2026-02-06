import 'package:criteria/chips/chip_controllers.dart';
import 'package:criteria/chips/chip_decorator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

export 'package:flutter/services.dart';

class ChipText extends StatefulWidget {
  const ChipText({required this.controller, super.key});

  final ChipTextController controller;
  @override
  State<ChipText> createState() => _ChipTextState();
}

class _ChipTextState extends State<ChipText> {
  @override
  void dispose() {
    widget.controller.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  void initState() {
    widget.controller.focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_refresh);
    super.initState();
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
    return ChipDecorator(
      controller: widget.controller,
      onTap: () {
        widget.controller.updating = true;
        widget.controller.focusNode.requestFocus();
      },
      // actually if I remove the line "actionButtons: ...", it defaults to null.
      child: widget.controller.updating
          ? SizedBox(
              width: widget.controller.editingWidth,
              child: TextField(
                autofocus: true,
                focusNode: widget.controller.focusNode,
                controller: widget.controller.textControleur,
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: widget.controller.altTextStyle,
                inputFormatters: widget.controller.inputFormatters,
                onChanged: (value) {
                  widget.controller.displayed = value.isNotEmpty;
                  if (mounted) setState(() {});
                },
                onSubmitted: (value) {
                  widget.controller.onEnter?.call();
                },
              ),
            )
          : widget.controller.textControleur.text.isNotEmpty
          ? Text(
              widget.controller.textControleur.text,
              style: widget.controller.textStyle,
            )
          : Text(
              '${widget.controller.label} ?',
              style: widget.controller.emptyLabelStyle,
            ),
    );
  }

  void onRemove() {
    widget.controller.remove();
    _refresh();
  }
}

class ChipTextController extends ChipItemController {
  ChipTextController({
    required super.name,
    super.group,
    super.label,
    super.avatar = const Icon(Icons.abc, size: 24),
    super.chipType = ChipType.text,
    super.onEnter,
  }) {
    _focusNode = FocusNode()..addListener(_onFocusChange);
    _textController = TextEditingController();
  }

  List<TextInputFormatter> inputFormatters = [];

  late final TextEditingController _textController;
  TextEditingController get textControleur => _textController;

  late final FocusNode _focusNode;
  FocusNode get focusNode => _focusNode;

  //bool eraseButton = true;
  //bool removeButton = true;

  TextStyle textStyle = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  // inherits default tooltip messages from base class

  @override
  void dispose() {
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      updating = false;
      notifyListeners();
    }
  }

  @override
  bool hasValue() {
    return _textController.text.isNotEmpty;
  }

  @override
  void clean() {
    _textController.clear();
    updating = false;
    notifyListeners();
  }

  @override
  String? get value => displayed ? _textController.text : null;

  @override
  set value(dynamic newValue) {
    if (newValue != _textController.text) {
      _textController.text = newValue;
      notifyListeners();
    }
  }

  @override
  Map<String, dynamic> get toJson {
    return {
      "name": name,
      "type": chipType.value,
      "value": _textController.text,
      'displayed': displayed,
    };
  }
}
