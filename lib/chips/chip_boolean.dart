import 'package:criteria/chips/chip_controllers.dart';
import 'package:flutter/material.dart';

class ChipBoolean extends StatefulWidget {
  const ChipBoolean({required this.controller, super.key});

  final ChipBooleanController controller;

  @override
  State<ChipBoolean> createState() => _ChipBooleanState();
}

class _ChipBooleanState extends State<ChipBoolean> with ChipsAssets {
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
                : () {
                    widget.controller.value =
                        !(widget.controller.value ?? false);
                    _refresh();
                  },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Avatar/icône
                if (!widget.controller.hideAvatar &&
                    widget.controller.avatar.toString() !=
                        const Icon(Icons.check).toString())
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        widget.controller.value ?? false
                            ? Icon(
                                Icons.check_box,
                                color: widget.controller.checkColor,
                              )
                            : Icon(
                                Icons.check_box_outline_blank,
                                color: widget.controller.checkColor.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                        const SizedBox(width: 4),
                        Text(
                          widget.controller.label,
                          style: widget.controller.textStyle,
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
    // Respect both the generic displayRemoveButton (from ChipItemController)
    // and the older removeButton for backward compatibility.
    final bool displayRemove =
        (widget.controller.displayRemoveButton) &&
        (widget.controller.removeButton);

    if (!widget.controller.alwaysDisplayed && displayRemove) {
      return IconButton(
        icon: deleteIcon,
        tooltip: widget.controller.tooltipMessageRemove,
        onPressed: widget.controller.disable
            ? null
            : () {
                onRemove();
              },
        constraints: const BoxConstraints(),
      );
    }

    return const SizedBox.shrink();
  }

  void onRemove() {
    widget.controller.value = false;
    widget.controller.updating = false;
    widget.controller.displayed = false;
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
  }

  bool _value = false;

  late final FocusNode _focusNode;
  FocusNode get focusNode => _focusNode;

  bool eraseButton = true;
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
