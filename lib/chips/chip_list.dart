import 'package:criteria/chips/chip_controllers.dart';
import 'package:criteria/chips/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
export 'chip_list_maker.dart';

class ChipList extends StatefulWidget {
  const ChipList({required this.controller, this.layout, super.key});

  final ChipListController controller;
  final ChipLayout? layout;

  @override
  State<ChipList> createState() => _ChipListState();
}

class _ChipListState extends State<ChipList> with ChipsAssets {
  final GlobalKey _inputChipKey = GlobalKey();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntryPopup;
  OverlayEntry? _overlayEntryHover;
  double _initX = 0;
  double _initY = 0;

  late double _popupWidth;
  late double _popupHeight;

  @override
  void dispose() {
    _overlayEntryPopup?.remove();
    _overlayEntryPopup = null;
    _overlayEntryHover?.remove();
    _overlayEntryHover = null;
    widget.controller.removeListener(_refresh);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _popupWidth = widget.controller.popupInitWidth;
    _popupHeight = widget.controller.popupInitHeight;

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
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Opacity(
        opacity: widget.controller.disable ? 0.5 : 1.0,
        child: CompositedTransformTarget(
          link: _layerLink,
          child: MouseRegion(
            onHover: (event) {
              if (widget.controller.selectedItems.length >
                  widget.controller.displayModeStepQty) {
                _openOverlayHover();
              }
            },
            onExit: (event) {
              _closeOverlayHover();
            },
            child: Tooltip(
              message: widget.controller.comments ?? '',
              child: InkWell(
                onTap: widget.controller.disable
                    ? null
                    : () {
                        _showOverlayPopup(context);
                      },
                child: Container(
                  key: _inputChipKey,
                  constraints: BoxConstraints(minHeight: chipHeightSize + 2),
                  padding: const EdgeInsets.all(0.0),
                  decoration: BoxDecoration(
                    color: widget.controller.disable
                        ? Colors.grey.shade300
                        : widget.controller.backgroundColor,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Avatar/icône
                      if (!widget.controller.hideAvatar &&
                          widget.controller.avatar != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 12, left: 6),
                          child: widget.controller.avatar,
                        ),

                      // Contenu principal
                      Flexible(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            widget.controller.selectedItems.isNotEmpty
                                ? _displayResume(
                                    mode: widget.controller.displayMode,
                                  )
                                : Text(
                                    '${widget.controller.label} ?',
                                    style: widget.controller.emptyLabelStyle,
                                  ),

                            // Label en bas si nécessaire
                            if (widget.controller.hasValue() &&
                                !widget.controller.hideLabelIfNotEmpty)
                              IgnorePointer(
                                child: Text(
                                  widget.controller.label,
                                  style: widget.controller.labelStyle.copyWith(
                                    height: 0.8,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Boutons d'action
                      const SizedBox(width: 8),
                      _buildActionButtons(),
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

  Widget _buildLayout2() {
    final hasValue = widget.controller.selectedItems.isNotEmpty;

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
                  : () => _showOverlayPopup2(context),
              child: IntrinsicWidth(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 150,
                    maxWidth: 300,
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
                          color: hasValue
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
                            color: hasValue
                                ? Colors.blue.shade50
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.list,
                            size: 18,
                            color: hasValue
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
                              hasValue
                                  ? _displayCompactSelection()
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
                        if (widget.controller.displayRemoveButton &&
                            hasValue) ...[
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

  Widget _displayCompactSelection() {
    return Wrap(
      spacing: 2.0,
      runSpacing: 2.0,
      children:
          widget.controller.selectedItems
              .take(3) // Show max 3 items
              .map(
                (item) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.shortText ?? item.text,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              )
              .toList()
            ..addAll(
              widget.controller.selectedItems.length > 3
                  ? [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '+${widget.controller.selectedItems.length - 3}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ]
                  : [],
            ),
    );
  }

  void _showOverlayPopup(BuildContext context) {
    _overlayEntryPopup?.remove();
    _overlayEntryPopup = null;

    _closeOverlayHover();
    _getInputChipPosition();
    widget.controller.updating = true;

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
                  width: _popupWidth,
                  height: _popupHeight,
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
                  child: Stack(
                    children: [_popupBody(setState), resizer(setState)],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntryPopup!);
  }

  void _showOverlayPopup2(BuildContext context) {
    _overlayEntryPopup?.remove();
    _overlayEntryPopup = null;

    _closeOverlayHover();
    _getInputChipPosition();
    widget.controller.updating = true;

    _overlayEntryPopup = OverlayEntry(
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          // Get screen dimensions
          final screenSize = MediaQuery.of(context).size;
          final padding = MediaQuery.of(context).padding;

          // Calculate popup dimensions (reasonable max sizes)
          final maxWidth = screenSize.width * 0.8; // 80% of screen width
          final maxHeight = screenSize.height * 0.7; // 70% of screen height

          final popupWidth = (_popupWidth * 1.8).clamp(350.0, maxWidth);
          final popupHeight = _popupHeight.clamp(300.0, maxHeight);

          // Get chip position with safe defaults
          final chipX = widget.controller.chipX ?? 0.0;
          final chipY = widget.controller.chipY ?? 0.0;
          final chipHeight = widget.controller.chipHeight ?? 48.0;

          // Preferred position (below the chip, following original behavior)
          double popupX = chipX + widget.controller.popupXoffset;
          double popupY = chipY + chipHeight;

          // Check and adjust X position only if needed
          if (popupX + popupWidth > screenSize.width - 16) {
            // Position to fit within right edge
            popupX = screenSize.width - popupWidth - 16;
          }
          if (popupX < 16) {
            // Position to fit within left edge
            popupX = 16;
          }

          // Check and adjust Y position only if needed
          if (popupY + popupHeight > screenSize.height - padding.bottom - 16) {
            // Try positioning above the chip first
            final popupYAbove = chipY - popupHeight - 8; // 8px gap above chip
            if (popupYAbove >= padding.top + 16) {
              popupY = popupYAbove;
            } else {
              // If doesn't fit above, position at bottom with max available space
              popupY = screenSize.height - padding.bottom - popupHeight - 16;
            }
          }

          // Ensure minimum top position
          if (popupY < padding.top + 16) {
            popupY = padding.top + 16;
          }

          // Create ScrollController for the Scrollbar
          final scrollController = ScrollController();

          return Stack(
            children: [
              GestureDetector(
                onTap: _closeOverlayPopup,
                child: Container(color: Colors.black.withValues(alpha: 0.3)),
              ),
              Positioned(
                left: popupX,
                top: popupY,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: popupWidth,
                    height: popupHeight,
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
                    child: Stack(
                      children: [
                        // Main content in a Column
                        Column(
                          children: [
                            // En-tête moderne
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
                                      Icons.list,
                                      color: Colors.blue.shade600,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      widget.controller.label,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade800,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (widget.controller.multiSelect) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "${widget.controller.selectedItems.length} / ${widget.controller.dataset.length}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: _closeOverlayPopup,
                                    icon: Icon(
                                      Icons.close_rounded,
                                      color: Colors.grey.shade600,
                                      size: 20,
                                    ),
                                    //tooltip: "Fermer",
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      padding: const EdgeInsets.all(8),
                                      minimumSize: const Size(32, 32),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Liste des éléments avec ScrollController
                            Expanded(
                              child: Scrollbar(
                                controller: scrollController,
                                thumbVisibility: true,
                                trackVisibility: true,
                                child: ListView.builder(
                                  controller: scrollController,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  itemCount: widget.controller.dataset.length,
                                  itemBuilder: (context, index) {
                                    final item =
                                        widget.controller.dataset[index];
                                    final isSelected = widget
                                        .controller
                                        .selectedItems
                                        .contains(item);

                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.blue.shade50
                                            : (index % 2 == 0
                                                  ? Colors.white
                                                  : Colors.grey.shade50),
                                        borderRadius: BorderRadius.circular(8),
                                        border: isSelected
                                            ? Border.all(
                                                color: Colors.blue.shade200,
                                              )
                                            : null,
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          onTap: () {
                                            setState(() {
                                              if (widget
                                                      .controller
                                                      .multiSelect ==
                                                  false) {
                                                widget.controller.selectedItems
                                                    .removeWhere((element) {
                                                      return element != item;
                                                    });
                                              }

                                              if (isSelected) {
                                                widget.controller.selectedItems
                                                    .remove(item);
                                              } else {
                                                widget.controller.selectedItems
                                                    .add(item);
                                              }
                                            });

                                            if (mounted) {
                                              this.setState(() {});
                                            }

                                            if (widget
                                                    .controller
                                                    .quitOnSelect ==
                                                true) {
                                              _closeOverlayPopup();
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 12,
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(
                                                    6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: isSelected
                                                        ? Colors.green.shade100
                                                        : Colors.grey.shade100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                  child: Icon(
                                                    isSelected
                                                        ? Icons.check_circle
                                                        : Icons
                                                              .radio_button_unchecked,
                                                    size: 16,
                                                    color: isSelected
                                                        ? Colors.green.shade600
                                                        : Colors.grey.shade500,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                if (item.leading != null) ...[
                                                  item.leading!,
                                                  const SizedBox(width: 8),
                                                ],
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        item.text,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: isSelected
                                                              ? Colors
                                                                    .blue
                                                                    .shade700
                                                              : Colors
                                                                    .grey
                                                                    .shade800,
                                                        ),
                                                      ),
                                                      if (item.comments != null)
                                                        Text(
                                                          item.comments!,
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors
                                                                .grey
                                                                .shade600,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                if (isSelected)
                                                  Icon(
                                                    Icons.check,
                                                    color:
                                                        Colors.green.shade600,
                                                    size: 18,
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                            // Pied de page moderne
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                                border: Border(
                                  top: BorderSide(color: Colors.grey.shade200),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "${widget.controller.selectedItems.length} sélectionné${widget.controller.selectedItems.length > 1 ? 's' : ''}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (widget.controller.multiSelect) ...[
                                    if (widget
                                            .controller
                                            .selectedItems
                                            .length ==
                                        widget.controller.dataset.length)
                                      IconButton.outlined(
                                        onPressed: () {
                                          setState(() {
                                            widget.controller.selectedItems
                                                .clear();
                                          });
                                          if (mounted) {
                                            this.setState(() {});
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.remove_done,
                                          size: 18,
                                        ),
                                        //tooltip: "Désélectionner tout",
                                        style: IconButton.styleFrom(
                                          backgroundColor:
                                              Colors.orange.shade50,
                                          foregroundColor:
                                              Colors.orange.shade600,
                                          side: BorderSide(
                                            color: Colors.orange.shade200,
                                          ),
                                        ),
                                      )
                                    else
                                      IconButton.outlined(
                                        onPressed: () {
                                          setState(() {
                                            widget.controller.selectedItems =
                                                List.from(
                                                  widget.controller.dataset,
                                                );
                                          });
                                          if (mounted) {
                                            this.setState(() {});
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.done_all,
                                          size: 18,
                                        ),
                                        //tooltip: "Tout sélectionner",
                                        style: IconButton.styleFrom(
                                          backgroundColor: Colors.green.shade50,
                                          foregroundColor:
                                              Colors.green.shade600,
                                          side: BorderSide(
                                            color: Colors.green.shade200,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(width: 8),
                                  ],
                                  IconButton.filled(
                                    onPressed: _closeOverlayPopup,
                                    icon: const Icon(Icons.check, size: 18),
                                    tooltip: "Valider",
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.blue.shade500,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Poignée de redimensionnement
                        Positioned(
                          right: 4,
                          bottom: 4,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.resizeDownRight,
                            child: GestureDetector(
                              onPanStart: (details) {
                                _initX = details.globalPosition.dx;
                                _initY = details.globalPosition.dy;
                              },
                              onPanUpdate: (details) {
                                setState(() {
                                  _popupWidth +=
                                      details.globalPosition.dx - _initX;
                                  _popupHeight +=
                                      details.globalPosition.dy - _initY;
                                  _initX = details.globalPosition.dx;
                                  _initY = details.globalPosition.dy;

                                  _popupWidth = _popupWidth.clamp(
                                    widget.controller.popupMinWidth,
                                    widget.controller.popupMaxWidth,
                                  );
                                  _popupHeight = _popupHeight.clamp(
                                    widget.controller.popupMinHeight,
                                    widget.controller.popupMaxHeight,
                                  );
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  Icons.drag_handle,
                                  color: Colors.grey.shade400,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    Overlay.of(context).insert(_overlayEntryPopup!);
  }

  void _showOverlayHover(BuildContext context) {
    _overlayEntryHover?.remove();
    _overlayEntryHover = null;

    _getInputChipPosition();

    _overlayEntryHover = OverlayEntry(
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Stack(
          children: [
            CompositedTransformFollower(
              link: _layerLink,
              offset: Offset(0, widget.controller.chipHeight ?? 0),
              child: Material(
                color: Colors.transparent,
                child: MouseRegion(
                  onExit: (event) {
                    _closeOverlayHover();
                  },
                  child: Container(
                    width: _popupWidth,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: widget.controller.backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _displayResume(
                      mode: widget.controller.displayModeHoverPopup,
                      isHover: true,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntryHover!);
  }

  Positioned resizer(StateSetter setState) {
    return Positioned(
      right: 0,
      bottom: 0,
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeDownRight,
        child: GestureDetector(
          onPanStart: (details) {
            _initX = details.globalPosition.dx;
            _initY = details.globalPosition.dy;
          },
          onPanUpdate: (details) {
            setState(() {
              _popupWidth += details.globalPosition.dx - _initX;
              _popupHeight += details.globalPosition.dy - _initY;
              _initX = details.globalPosition.dx;
              _initY = details.globalPosition.dy;

              _popupWidth = _popupWidth.clamp(
                widget.controller.popupMinWidth,
                widget.controller.popupMaxWidth,
              );
              _popupHeight = _popupHeight.clamp(
                widget.controller.popupMinHeight,
                widget.controller.popupMaxHeight,
              );
            });
          },
          child: SizedBox(
            width: 20,
            height: 20,
            child: SvgPicture.asset(
              'packages/criteria/assets/images/resize_handle.svg',
              width: 20,
              height: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _popupBody(StateSetter setState) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: widget.controller.dataset.length,
            itemBuilder: (context, index) {
              return Material(
                color: index % 2 == 0
                    ? widget.controller.backgroundColorAlt
                    : widget.controller.backgroundColor,
                child: ListTile(
                  horizontalTitleGap: 4,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  hoverColor: widget.controller.hoverColor,
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Visibility(
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        visible: widget.controller.selectedItems.contains(
                          widget.controller.dataset[index],
                        ),
                        child: const Icon(Icons.check),
                      ),
                      if (widget.controller.dataset[index].leading != null)
                        widget.controller.dataset[index].leading!,
                    ],
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.controller.dataset[index].children == null
                          ? Text(
                              widget.controller.dataset[index].text,
                              style: widget.controller.textStyle,
                            )
                          : Row(
                              children:
                                  widget.controller.dataset[index].children!,
                            ),
                      if (widget.controller.dataset[index].comments != null)
                        Text(
                          "${widget.controller.dataset[index].comments}",
                          style: widget.controller.labelStyle,
                        ),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      ChipListItem item = widget.controller.dataset[index];

                      if (widget.controller.multiSelect == false) {
                        widget.controller.selectedItems.removeWhere((element) {
                          return element != item;
                        });
                      }

                      // Si l'item est déjà sélectionné, on le désélectionne
                      if (widget.controller.selectedItems.contains(item)) {
                        widget.controller.selectedItems.remove(item);
                      } else {
                        // Sinon on l'ajoute à la sélection
                        widget.controller.selectedItems.add(item);
                      }
                    });

                    // Mettre à jour l'état du widget parent
                    this.setState(() {});
                    if (widget.controller.quitOnSelect == true) {
                      _closeOverlayPopup();
                    }
                  },
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${widget.controller.selectedItems.length} / ${widget.controller.dataset.length}",
                style: widget.controller.labelStyle.copyWith(
                  fontSize: widget.controller.labelStyle.fontSize! + 4,
                ),
              ),
              const Expanded(child: SizedBox()),
              if (widget.controller.selectedItems.length ==
                      widget.controller.dataset.length &&
                  widget.controller.multiSelect == true)
                IconButton(
                  //tooltip: "Désélectionner tous",
                  onPressed: () {
                    setState(() {
                      widget.controller.selectedItems.clear();
                    });
                    this.setState(() {});
                  },
                  icon: const Icon(Icons.remove_done),
                )
              else if (widget.controller.multiSelect == true &&
                  widget.controller.quitOnSelect == false)
                IconButton(
                  //tooltip: "Sélectionner tous",
                  onPressed: () {
                    setState(() {
                      widget.controller.selectedItems = List.from(
                        widget.controller.dataset,
                      );
                    });
                    this.setState(() {});
                  },
                  icon: const Icon(Icons.done_all),
                ),
              if (widget.controller.quitOnSelect == false) ...[
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: IconButton.filled(
                    style: IconButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(28, 28),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    //tooltip: "Fermer",
                    onPressed: _closeOverlayPopup,
                    icon: const Icon(Icons.close),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _closeOverlayPopup() {
    _overlayEntryPopup?.remove();
    _overlayEntryPopup?.dispose();
    _overlayEntryPopup = null;
    widget.controller.updating = false;
  }

  void _closeOverlayHover() {
    _overlayEntryHover?.remove();
    _overlayEntryHover = null;
  }

  void _openOverlayHover() {
    _showOverlayHover(context);
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
    _closeOverlayHover();
    widget.controller.selectedItems.clear();
    widget.controller.updating = false;
    widget.controller.displayed = false;
  }

  Color gridBgColor(int index) {
    if ((widget.controller.gridCols + 1) % 2 == 0) {
      return index % 2 == 0 ? Colors.grey.shade50 : Colors.grey.shade200;
    }
    if (index % 3 == 0) {
      return Colors.grey.shade50;
    } else if (index % 3 == 1) {
      return Colors.grey.shade200;
    } else {
      return Colors.blue.shade50;
    }
  }

  List<Widget> _sanitizeChildren(List<Widget> children) {
    return children.map((child) {
      if (child is Spacer) {
        return const SizedBox(width: 4);
      }
      if (child is Flexible) {
        return child.child;
      }
      return child;
    }).toList();
  }

  Widget _displayResume({
    required ChipListDisplayMode mode,
    bool isHover = false,
  }) {
    List<Widget> items = [];
    if ((mode == ChipListDisplayMode.quantity ||
            widget.controller.selectedItems.length >
                widget.controller.displayModeStepQty) &&
        isHover == false) {
      return Text(
        "# ${widget.controller.selectedItems.length}",
        style: widget.controller.textStyle,
      );
    } else if (mode == ChipListDisplayMode.shortDescription) {
      items = widget.controller.selectedItems
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                item.shortText ?? item.text,
                style: widget.controller.textStyle,
              ),
            ),
          )
          .toList();
      return isHover
          ? GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.controller.gridCols,
                childAspectRatio: widget.controller.gridAspectRatio,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return Container(
                  color: gridBgColor(index),
                  child: Align(
                    alignment: widget.controller.gridAlign,
                    child: items[index],
                  ),
                );
              },
            )
          : Wrap(spacing: 4, runSpacing: 4, children: items);
    } else if (mode == ChipListDisplayMode.fullDescription) {
      items = widget.controller.selectedItems
          .map(
            (item) => item.children == null
                ? Text(item.text, style: widget.controller.textStyle)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: _sanitizeChildren(item.children!),
                  ),
          )
          .toList();
      return isHover
          ? GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.controller.gridCols,
                childAspectRatio: widget.controller.gridAspectRatio,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return Container(
                  color: gridBgColor(index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Align(
                      alignment: widget.controller.gridAlign,
                      child: items[index],
                    ),
                  ),
                );
              },
            ) //Wrap(direction: Axis.vertical, spacing: 0, children: items)
          : Wrap(spacing: 4, children: items);
    } else if (mode == ChipListDisplayMode.icon) {
      items = widget.controller.selectedItems
          .map((item) => item.leading ?? const Icon(Icons.question_mark))
          .toList();
      return isHover
          ? GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.controller.gridCols,
                childAspectRatio: widget.controller.gridAspectRatio,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return Container(
                  color: gridBgColor(index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Align(
                        alignment: widget.controller.gridAlign,
                        child: items[index],
                      ),
                    ),
                  ),
                );
              },
            )
          : Wrap(spacing: 4, runSpacing: 4, children: items);
    } else if (mode == ChipListDisplayMode.iconAndShortDescription) {
      items = widget.controller.selectedItems
          .map(
            (item) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                item.leading ?? const Icon(Icons.question_mark),
                Text(item.shortText ?? item.text),

                const SizedBox(width: 4),
              ],
            ),
          )
          .toList();
      return isHover
          ? GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.controller.gridCols,
                childAspectRatio: widget.controller.gridAspectRatio,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return Container(
                  color: gridBgColor(index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Align(
                      alignment: widget.controller.gridAlign,
                      child: items[index],
                    ),
                  ),
                );
              },
            )
          : Wrap(spacing: 4, runSpacing: 4, children: items);
    } else if (mode == ChipListDisplayMode.iconAndDescription) {
      items = widget.controller.selectedItems
          .map(
            (item) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                item.leading ?? const Icon(Icons.question_mark),
                item.children == null
                    ? Text(item.text, style: widget.controller.textStyle)
                    : Row(children: _sanitizeChildren(item.children!)),
                const SizedBox(width: 4),
              ],
            ),
          )
          .toList();
      return isHover
          ? GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.controller.gridCols,
                childAspectRatio: widget.controller.gridAspectRatio,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return Container(
                  color: gridBgColor(index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Align(
                      alignment: widget.controller.gridAlign,
                      child: items[index],
                    ),
                  ),
                );
              },
            )
          : Wrap(spacing: 4, runSpacing: 4, children: items);
    }
    return const SizedBox.shrink();
  }

  Widget _buildActionButtons() => tailIcons(
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
            _refresh();
          },
  );
}

class ChipListController extends ChipItemController with ChipsPoupAttributs {
  ChipListController({
    required super.name,
    required super.group,
    super.label,
    super.avatar = const Icon(Icons.list, size: 24),
    super.chipType = ChipType.text,
    super.onEnter,
  });
  List<ChipListItem> dataset = [];

  List<ChipListItem> selectedItems = [];

  bool eraseButton = true;
  bool removeButton = true;
  bool multiSelect = false;
  bool quitOnSelect = false;
  bool checkIcon = false;
  int gridCols = 3;
  Alignment gridAlign = Alignment.center;
  double gridAspectRatio = 1.5;
  String? toolTipMessage;

  ChipListDisplayMode displayMode = ChipListDisplayMode.shortDescription;
  int displayModeStepQty = 3;

  ChipListDisplayMode displayModeHoverPopup =
      ChipListDisplayMode.fullDescription;

  TextStyle textStyle = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
  TextStyle inputTextStyle = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  @override
  bool hasValue() => selectedItems.isNotEmpty;

  @override
  void clean() {
    selectedItems.clear();
    updating = false;
    notifyListeners();
  }

  @override
  List<ChipListItem>? get value => displayed ? selectedItems : null;
  @override
  set value(dynamic newValue) {
    newValue = List<String>.from(newValue);
    selectedItems = dataset
        .where((element) => newValue.contains(element.id))
        .toList();

    notifyListeners();
  }

  @override
  Map<String, dynamic> get toJson {
    return {
      "name": name,
      "type": chipType.value,
      "value": selectedItems.map((e) => e.id).toList(),
      "displayed": displayed,
    };
  }
}

enum ChipListDisplayMode {
  quantity,
  shortDescription,
  fullDescription,
  icon,
  iconAndShortDescription,
  iconAndDescription,
}

class ChipListItem {
  ChipListItem({
    required this.id,
    required this.text,
    this.shortText,
    this.leading,
    this.trailing,
    this.comments,
    this.children,
  });
  final String id;
  String text;
  List<Widget>? children;
  final String? shortText;
  final String? comments;
  final Widget? leading;
  final Widget? trailing;
}
