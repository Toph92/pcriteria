import 'package:criteria/chips/chip_controllers.dart';
import 'package:criteria/chips/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

export 'package:flutter/services.dart';

class ChipText extends StatefulWidget {
  const ChipText({required this.controller, this.layout, super.key});

  final ChipTextController controller;
  final ChipLayout? layout;

  @override
  State<ChipText> createState() => _ChipTextState();
}

class _ChipTextState extends State<ChipText> with ChipsAssets {
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
                labelStyle: widget.controller.labelStyle,
                //floatingLabelStyle: widget.controller.labelStyle,
                enabled: !widget.controller.disable,
                filled: true,
                fillColor: widget.controller.disable
                    ? Colors.grey.shade300
                    : widget.controller.backgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                isDense: true,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(8.0),
                onTap: widget.controller.disable
                    ? null
                    : () {
                        widget.controller.updating = true;
                        widget.controller.focusNode.requestFocus();
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
                        child: widget.controller.updating
                            ? SizedBox(
                                width: widget.controller.editingWidth,
                                child: TextField(
                                  autofocus: true,
                                  focusNode: widget.controller.focusNode,
                                  controller: widget.controller.textControleur,
                                  decoration: const InputDecoration(
                                    isDense: true,
                                  ),
                                  style: widget.controller.altTextStyle,
                                  inputFormatters:
                                      widget.controller.inputFormatters,
                                  onChanged: (value) {
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
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // For ChipText - _buildLayout2()
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
                    widget.controller.updating = true;
                    widget.controller.focusNode.requestFocus();
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
                        color: widget.controller.textControleur.text.isNotEmpty
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
                          color:
                              widget.controller.textControleur.text.isNotEmpty
                              ? Colors.blue.shade50
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.text_fields,
                          size: 18,
                          color:
                              widget.controller.textControleur.text.isNotEmpty
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
                            widget.controller.updating
                                ? SizedBox(
                                    width: widget.controller.editingWidth,
                                    child: TextField(
                                      autofocus: true,
                                      focusNode: widget.controller.focusNode,
                                      controller:
                                          widget.controller.textControleur,
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      style: widget.controller.textStyle
                                          .copyWith(
                                            color: Colors.blue.shade700,
                                            fontWeight: FontWeight.w600,
                                          ),
                                      inputFormatters:
                                          widget.controller.inputFormatters,
                                      onChanged: (value) {
                                        if (mounted) setState(() {});
                                      },
                                      onSubmitted: (value) {
                                        widget.controller.onEnter?.call();
                                      },
                                    ),
                                  )
                                : widget
                                      .controller
                                      .textControleur
                                      .text
                                      .isNotEmpty
                                ? Text(
                                    widget.controller.textControleur.text,
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
                      if (widget.controller.onPopupPressed != null) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: widget.controller.disable
                              ? null
                              : () => widget.controller.onPopupPressed?.call(
                                  context,
                                ),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              widget.controller.popupIcon.icon,
                              size: 16,
                              color: Colors.blue.shade600,
                            ),
                          ),
                        ),
                      ],
                      if (widget.controller.displayRemoveButton &&
                          widget.controller.textControleur.text.isNotEmpty &&
                          !widget.controller.updating) ...[
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

  Widget _buildActionButtons() {
    List<Widget> buttons = [];

    if (widget.controller.onPopupPressed != null) {
      buttons.add(
        IconButton(
          tooltip: widget.controller.tooltipMessagePopup,
          icon: widget.controller.popupIcon,
          onPressed: widget.controller.disable
              ? null
              : () {
                  widget.controller.onPopupPressed?.call(context);
                },
        ),
      );
    }
    buttons.add(
      tailIcons(
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
      ),
    );
    return Row(mainAxisSize: MainAxisSize.min, children: buttons);
  }

  void onRemove() {
    widget.controller.textControleur.clear();
    widget.controller.updating = false;
    widget.controller.displayed = false;
  }
}

class ChipTextController extends ChipItemController {
  ChipTextController({
    required super.name,
    required super.group,
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

  Icon popupIcon = const Icon(Icons.search);
  dynamic Function(BuildContext context, {dynamic other})? onPopupPressed;
  String tooltipMessagePopup = "Open search popup";

  bool eraseButton = true;
  bool removeButton = true;
  double editingWidth = 200;
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
