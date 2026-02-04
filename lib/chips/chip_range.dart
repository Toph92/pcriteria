import 'package:criteria/chips/chip_controllers.dart';
import 'package:criteria/chips/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

export 'package:flutter/services.dart';
export 'chip_list_maker.dart';

class ChipRange extends StatefulWidget {
  const ChipRange({required this.controller, this.layout, super.key});

  final ChipRangeController controller;
  final ChipLayout? layout;

  @override
  State<ChipRange> createState() => _ChipRangeState();
}

class _ChipRangeState extends State<ChipRange> with ChipsAssets {
  final GlobalKey _inputChipKey = GlobalKey();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntryPopup;

  double initX = 0;
  double initY = 0;
  double chipWidth = 0;
  double chipHeight = 0;

  late double width;
  late double height;

  @override
  void dispose() {
    _overlayEntryPopup?.remove();
    _overlayEntryPopup = null;
    widget.controller.removeListener(_refresh);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    width = widget.controller.popupInitWidth;
    height = 100;

    assert(
      !(widget.controller.quitOnSelect == true &&
          widget.controller.multiSelect == true),
      'Le mode multi-sélection et le mode quitter à la sélection ne peuvent pas être activés en même temps.',
    );
    widget.controller.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget.layout == ChipLayout.layout2
        ? _buildLayout2()
        : _buildLayout1();
  }

  Widget _buildLayout1() {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 2.0),
        child: Opacity(
          opacity: widget.controller.disable ? 0.5 : 1.0,
          child: Container(
            key: _inputChipKey,
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
                      _getInputChipPosition();
                      widget.controller.updating = true;
                      _showOverlayPopup(context);
                    },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Avatar
                  if (!widget.controller.hideAvatar)
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
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          widget.controller.numRange != null
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      widget.controller.numRange?.start != null
                                          ? widget.controller.numRange!.start
                                                .toStringAsFixed(
                                                  widget.controller.precision,
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
                                      widget.controller.numRange?.end != null
                                          ? widget.controller.numRange!.end
                                                .toStringAsFixed(
                                                  widget.controller.precision,
                                                )
                                          : '',
                                      style: widget.controller.textStyle,
                                    ),
                                    if (widget.controller.unitWidget != null)
                                      widget.controller.unitWidget!,
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
      ),
    );
  }

  Widget _buildActionButtons() {
    // Respect controller-wide displayRemoveButton and local removeButton
    final bool displayRemove =
        widget.controller.displayRemoveButton && widget.controller.removeButton;

    if (displayRemove &&
        widget.controller.numRange != null &&
        !widget.controller.updating) {
      return IconButton(
        icon: tailIcons(widget.controller),
        tooltip: widget.controller.tooltipMessageRemove,
        onPressed: widget.controller.disable
            ? null
            : () {
                widget.controller.clean();
              },
        constraints: const BoxConstraints(),
      );
    } else if (!widget.controller.alwaysDisplayed && displayRemove) {
      return IconButton(
        icon: tailIcons(widget.controller),
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
      child: CompositedTransformTarget(
        link: _layerLink,
        child: Container(
          key: _inputChipKey,
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
                      _getInputChipPosition();
                      widget.controller.updating = true;
                      _showOverlayPopup2(context);
                    },
              child: IntrinsicWidth(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 120,
                    maxWidth: 250,
                  ),
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
                          color: widget.controller.numRange != null
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
                            color: widget.controller.numRange != null
                                ? Colors.blue.shade50
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.tune,
                            size: 18,
                            color: widget.controller.numRange != null
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
                              widget.controller.numRange != null
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          widget.controller.numRange!.start
                                              .toStringAsFixed(
                                                widget.controller.precision,
                                              ),
                                          style: widget.controller.textStyle
                                              .copyWith(
                                                color: Colors.blue.shade700,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          child: Icon(
                                            Icons.arrow_forward,
                                            color: Colors.grey.shade500,
                                            size: 16,
                                          ),
                                        ),
                                        Text(
                                          widget.controller.numRange!.end
                                              .toStringAsFixed(
                                                widget.controller.precision,
                                              ),
                                          style: widget.controller.textStyle
                                              .copyWith(
                                                color: Colors.blue.shade700,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        if (widget.controller.unitWidget !=
                                            null) ...[
                                          const SizedBox(width: 4),
                                          widget.controller.unitWidget!,
                                        ],
                                      ],
                                    )
                                  : Text(
                                      widget.controller.label,
                                      style: widget.controller.emptyLabelStyle
                                          .copyWith(
                                            color: Colors.grey.shade600,
                                          ),
                                    ),
                            ],
                          ),
                        ),
                        // Respect controller-wide displayRemoveButton and local removeButton
                        if (widget.controller.displayRemoveButton &&
                            widget.controller.removeButton &&
                            widget.controller.numRange != null) ...[
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
      ),
    );
  }

  void _showOverlayPopup(BuildContext context) {
    _overlayEntryPopup?.remove();
    _overlayEntryPopup = null;

    _getInputChipPosition();

    _overlayEntryPopup = OverlayEntry(
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Stack(
          children: [
            GestureDetector(
              onTap: _closeOverlayPopup,
              child: Container(color: Colors.black.withValues(alpha: 0.3)),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              offset: Offset(
                widget.controller.popupXoffset,
                widget.controller.chipHeight ?? 0,
              ),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: width,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: widget.controller.backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: body(setState),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (widget.controller.numRange != null) {
      widget.controller.textStartControleur.text = widget
          .controller
          .numRange!
          .start
          .toStringAsFixed(widget.controller.precision);

      widget.controller.textEndControleur.text = widget.controller.numRange!.end
          .toStringAsFixed(widget.controller.precision);
    }

    Overlay.of(context).insert(_overlayEntryPopup!);
  }

  void _showOverlayPopup2(BuildContext context) {
    _overlayEntryPopup?.remove();
    _overlayEntryPopup = null;

    _getInputChipPosition();

    _overlayEntryPopup = OverlayEntry(
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Stack(
          children: [
            GestureDetector(
              onTap: _closeOverlayPopup,
              child: Container(color: Colors.black.withValues(alpha: 0.3)),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              offset: Offset(
                widget.controller.popupXoffset,
                widget.controller.chipHeight ?? 0,
              ),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: width.clamp(280, 400),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header moderne
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.tune,
                                color: Colors.blue.shade600,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.controller.label,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Contenu du popup
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: body2(setState),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (widget.controller.numRange != null) {
      widget.controller.textStartControleur.text = widget
          .controller
          .numRange!
          .start
          .toStringAsFixed(widget.controller.precision);

      widget.controller.textEndControleur.text = widget.controller.numRange!.end
          .toStringAsFixed(widget.controller.precision);
    }

    Overlay.of(context).insert(_overlayEntryPopup!);
  }

  Widget body(StateSetter setState) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.controller.minMaxRange != null)
          RangeSlider(
            values:
                widget.controller.numRange ?? widget.controller.minMaxRange!,
            min: widget.controller.minMaxRange!.start,
            max: widget.controller.minMaxRange!.end,
            divisions:
                (widget.controller.minMaxRange!.end.toInt() -
                    widget.controller.minMaxRange!.start.toInt()) *
                (widget.controller.precision == 0
                    ? 1
                    : (10 * widget.controller.precision)),
            onChanged: (values) {
              setState(() {
                widget.controller.numRange = values;
              });
            },
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: TextField(
                onSubmitted: (value) {
                  widget.controller.onEnter?.call();
                },
                focusNode: widget.controller.focusStartNode,
                controller: widget.controller.textStartControleur,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                ),
                inputFormatters: [NumberInputFormatter()],
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  hintText: widget.controller.labelMin,
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                  ),
                ),
                style: widget.controller.altTextStyle,
                onChanged: (value) {
                  if (context.mounted) {
                    setState(() {
                      widget.controller.setValuesFromInput(
                        start: double.tryParse(value),
                      );
                    });
                  }
                },
              ),
            ),
            Icon(Icons.double_arrow, color: Colors.grey.shade500, size: 18),
            Flexible(
              child: TextField(
                onSubmitted: (value) {
                  widget.controller.onEnter?.call();
                },
                focusNode: widget.controller.focusEndNode,
                controller: widget.controller.textEndControleur,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                ),
                inputFormatters: [NumberInputFormatter()],
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  hintText: widget.controller.labelMax,
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                  ),
                ),
                style: widget.controller.altTextStyle,
                onChanged: (value) {
                  if (context.mounted) {
                    setState(() {
                      widget.controller.setValuesFromInput(
                        end: double.tryParse(value),
                      );
                    });
                  }
                },
              ),
            ),
          ],
        ),
        if (widget.controller.popupHelper != null)
          widget.controller.popupHelper!,
      ],
    );
  }

  Widget body2(StateSetter setState) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Slider moderne (si minMaxRange est défini)
        if (widget.controller.minMaxRange != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Plage de valeurs',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    if (widget.controller.numRange != null)
                      Text(
                        '${widget.controller.numRange!.start.toStringAsFixed(widget.controller.precision)} - ${widget.controller.numRange!.end.toStringAsFixed(widget.controller.precision)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue.shade600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.blue.shade400,
                    inactiveTrackColor: Colors.grey.shade300,
                    thumbColor: Colors.blue.shade600,
                    overlayColor: Colors.blue.shade100,
                    trackHeight: 4,
                    rangeThumbShape: const RoundRangeSliderThumbShape(
                      enabledThumbRadius: 8,
                    ),
                  ),
                  child: RangeSlider(
                    values:
                        widget.controller.numRange ??
                        widget.controller.minMaxRange!,
                    min: widget.controller.minMaxRange!.start,
                    max: widget.controller.minMaxRange!.end,
                    divisions:
                        (widget.controller.minMaxRange!.end.toInt() -
                            widget.controller.minMaxRange!.start.toInt()) *
                        (widget.controller.precision == 0
                            ? 1
                            : (10 * widget.controller.precision)),
                    onChanged: (values) {
                      setState(() {
                        widget.controller.numRange = values;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Champs de saisie modernes
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  onSubmitted: (value) {
                    widget.controller.onEnter?.call();
                  },
                  focusNode: widget.controller.focusStartNode,
                  controller: widget.controller.textStartControleur,
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: true,
                  ),
                  inputFormatters: [NumberInputFormatter()],
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    hintText: widget.controller.labelMin,
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.start,
                      color: Colors.grey.shade500,
                      size: 18,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  onChanged: (value) {
                    if (context.mounted) {
                      setState(() {
                        widget.controller.setValuesFromInput(
                          start: double.tryParse(value),
                        );
                      });
                    }
                  },
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Icon(
                Icons.arrow_forward,
                color: Colors.grey.shade500,
                size: 20,
              ),
            ),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  onSubmitted: (value) {
                    widget.controller.onEnter?.call();
                  },
                  focusNode: widget.controller.focusEndNode,
                  controller: widget.controller.textEndControleur,
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: true,
                  ),
                  inputFormatters: [NumberInputFormatter()],
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    hintText: widget.controller.labelMax,
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.last_page,
                      color: Colors.grey.shade500,
                      size: 18,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  onChanged: (value) {
                    if (context.mounted) {
                      setState(() {
                        widget.controller.setValuesFromInput(
                          end: double.tryParse(value),
                        );
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        ),

        // Helper widget si défini
        if (widget.controller.popupHelper != null) ...[
          const SizedBox(height: 16),
          widget.controller.popupHelper!,
        ],
      ],
    );
  }

  void _closeOverlayPopup() {
    if (widget.controller.numRange != null) {
      if (widget.controller.numRange!.end == 0 &&
          widget.controller.numRange!.start != 0) {
        widget.controller.numRange = RangeValues(
          widget.controller.numRange!.start,
          widget.controller.numRange!.start,
        );
      } else if (widget.controller.numRange!.start == 0 &&
          widget.controller.numRange!.end == 0) {
        widget.controller.numRange = null;
      } else if (widget.controller.numRange!.start >
          widget.controller.numRange!.end) {
        widget.controller.numRange = RangeValues(
          widget.controller.numRange!.end,
          widget.controller.numRange!.start,
        );
      }
    }

    _overlayEntryPopup?.remove();
    _overlayEntryPopup = null;
    widget.controller.updating = false;
  }

  void _getInputChipPosition() {
    final RenderBox renderBox =
        _inputChipKey.currentContext?.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    widget.controller.chipX = position.dx;
    widget.controller.chipY = position.dy;
    widget.controller.chipWidth = size.width;
    widget.controller.chipHeight = size.height;
  }

  void onRemove() {
    widget.controller.numRange = null;
    widget.controller.updating = false;
    widget.controller.displayed = false;
  }
}

// Rest of the ChipRangeController and NumberInputFormatter classes remain unchanged...
class ChipRangeController extends ChipItemController with ChipsPoupAttributs {
  ChipRangeController({
    required super.name,
    required super.group,
    super.label,
    super.chipType = ChipType.numRange,
    super.avatar,
    super.onEnter,
  }) {
    super.avatar = SvgPicture.asset(
      'packages/criteria/assets/images/slider-h-range.svg',
    );
    _focusStartNode = FocusNode()..addListener(_onFocusChange);
    _textStartControleur = TextEditingController();

    _focusEndNode = FocusNode()..addListener(_onFocusChange);
    _textEndControleur = TextEditingController();
    chipHeight = 50;
  }

  List<TextInputFormatter> inputFormatters = [];

  late final TextEditingController _textStartControleur;
  TextEditingController get textStartControleur => _textStartControleur;
  late final FocusNode _focusStartNode;
  FocusNode get focusStartNode => _focusStartNode;

  late final TextEditingController _textEndControleur;
  TextEditingController get textEndControleur => _textEndControleur;

  late final FocusNode _focusEndNode;
  FocusNode get focusEndNode => _focusEndNode;

  RangeValues? minMaxRange;

  bool eraseButton = true;
  bool removeButton = true;
  bool multiSelect = false;
  bool quitOnSelect = false;
  bool checkIcon = false;
  String? toolTipMessage;

  String labelMin = "Min";
  String labelMax = "Max";

  Widget? unitWidget;

  RangeValues? _numRange;

  int precision = 0;

  RangeValues? get numRange => _numRange;
  set numRange(RangeValues? value) {
    if (value?.start != _numRange?.start || value?.end != _numRange?.end) {
      if (value == null) {
        _numRange = null;
        _textStartControleur.clear();
        _textEndControleur.clear();
      } else {
        _numRange = RangeValues(value.start, value.end);

        final startText = value.start.toStringAsFixed(precision);
        _textStartControleur.value = TextEditingValue(
          text: startText,
          selection: TextSelection.collapsed(offset: startText.length),
        );

        final endText = value.end.toStringAsFixed(precision);
        _textEndControleur.value = TextEditingValue(
          text: endText,
          selection: TextSelection.collapsed(offset: endText.length),
        );
      }

      notifyListeners();
    }
  }

  TextStyle textStyle = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
  TextStyle inputTextStyle = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  @override
  void dispose() {
    _focusStartNode.dispose();
    _textStartControleur.dispose();
    _focusEndNode.dispose();
    _textEndControleur.dispose();
    super.dispose();
  }

  @override
  bool hasValue() => numRange != null;

  void _onFocusChange() {}

  @override
  void clean() {
    numRange = null;
    updating = false;
  }

  @override
  RangeValues? get value => displayed ? _numRange : null;
  @override
  set value(dynamic newValue) {
    assert(
      newValue is RangeValues ||
          newValue is Map<String, dynamic> ||
          newValue == null,
      'La valeur doit être de type RangeValues ou Map<String, dynamic> ou null',
    );

    if (newValue == null) {
      _numRange = null;
      _textStartControleur.clear();
      _textEndControleur.clear();
    } else if (newValue is Map<String, dynamic>) {
      try {
        newValue = RangeValues(newValue['start'], newValue['end']);
      } catch (e) {
        debugPrint('Erreur lors de l\'affectation: $e');
      }
    }
    if (newValue?.start != _numRange?.start ||
        newValue?.end != _numRange?.end) {
      _numRange = RangeValues(
        newValue.start ?? newValue.end ?? 0,
        newValue.end ?? newValue.start ?? 0,
      );
      notifyListeners();
    }
  }

  @override
  Map<String, dynamic> get toJson {
    return {
      "name": name,
      "type": chipType.value,
      "value": _numRange != null
          ? {"start": _numRange!.start, "end": _numRange!.end}
          : null,
      "displayed": displayed,
    };
  }

  void setValuesFromInput({double? start, double? end}) {
    if (start == null && end == null) return;

    if (minMaxRange != null) {
      double currentStart = numRange?.start ?? (minMaxRange?.start ?? 0);
      double currentEnd = numRange?.end ?? (minMaxRange?.end ?? 0);

      start ??= currentStart;
      end ??= currentEnd;

      if (minMaxRange != null) {
        start = start.clamp(minMaxRange!.start, minMaxRange!.end);
        end = end.clamp(minMaxRange!.start, minMaxRange!.end);
      }

      if (start > end) {
        if (start != currentStart) {
          start = end;
        } else if (end != currentEnd) {
          end = start;
        }
      }
    } else {
      double currentStart = numRange?.start ?? 0;
      double currentEnd = numRange?.end ?? 0;

      start ??= currentStart;
      end ??= currentEnd;

      if (start != currentStart && start > end) {
        // Keep end unchanged
      } else if (end != currentEnd && end < start) {
        // Keep start unchanged
      }
    }

    if (start != numRange?.start || end != numRange?.end) {
      numRange = RangeValues(start, end);
    }
  }
}

class NumberInputFormatter extends TextInputFormatter {
  final RegExp regExp = RegExp(r'^-?\d*$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (regExp.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}
