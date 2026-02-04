import 'package:criteria/chips/chip_controllers.dart';
import 'package:criteria/chips/config.dart';
import 'package:flutter/material.dart';

class ChipBoolean extends StatefulWidget {
  const ChipBoolean({required this.controller, this.layout, super.key});

  final ChipBooleanController controller;
  final ChipLayout? layout;

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
    if (widget.layout == ChipLayout.layout2) {
      return _buildLayout2();
    } else {
      return _buildLayout1();
    }
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

  Widget _buildLayout2() {
    return Opacity(
      opacity: widget.controller.disable ? 0.5 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                : () {
                    widget.controller.value =
                        !(widget.controller.value ?? false);
                    _refresh();
                  },
            child: IntrinsicWidth(
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 100, maxWidth: 200),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: !widget.controller.hideLabelIfNotEmpty
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
                        color: widget.controller.value ?? false
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
                          color: widget.controller.value ?? false
                              ? Colors.blue.shade50
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          widget.controller.value ?? false
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          size: 18,
                          color: widget.controller.value ?? false
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
                            Text(
                              (widget.controller.value ?? false)
                                  ? 'Oui'
                                  : 'Non',
                              style: widget.controller.textStyle.copyWith(
                                color: widget.controller.value ?? false
                                    ? Colors.blue.shade700
                                    : Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!widget.controller.alwaysDisplayed) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => onRemove(),
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
