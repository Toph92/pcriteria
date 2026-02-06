import 'package:criteria/chips/chip_controllers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChipAdd extends StatefulWidget {
  const ChipAdd({
    required this.controller,
    required this.groupsFilterSelector,
    super.key,
  });

  final ChipsController controller;
  final List<ChipGroup>? groupsFilterSelector;
  @override
  State<ChipAdd> createState() => _ChipAddState();
}

class _ChipAddState extends State<ChipAdd> with ChipsAssets {
  final GlobalKey _btnKey = GlobalKey();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntryPopup;
  double initX = 0;
  double initY = 0;
  double chipWidth = 0;
  double chipHeight = 0;

  double width = 300;
  double height = 500;

  RenderBox? _renderBox;
  Offset? _position;

  List<ChipGroup> groups = [];
  List<String> _groupsNameFilterSelector = [];
  final List<ChipItemController> _chips = [];

  @override
  void dispose() {
    _overlayEntryPopup?.remove();
    _overlayEntryPopup?.dispose();
    _overlayEntryPopup = null;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initChips();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 2.0),
        child: IconButton.filled(
          tooltip: widget.controller.addCriteriaTooltipMessage,
          key: _btnKey,
          onPressed: () {
            if (_chips.isNotEmpty) {
              _showOverlayPopup(context);
            }
          },
          icon: const Icon(Icons.add),
          style: IconButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }

  void initChips() {
    for (final element in _chips) {
      if (element.group == null) {
        throw Exception("Chip ${element.name} has no group");
      }
    }

    _groupsNameFilterSelector =
        widget.groupsFilterSelector?.map((e) => e.name).toList() ?? [];
    _chips
      ..addAll(
        widget.controller.chips.where(
          (e) =>
              _groupsNameFilterSelector.contains(e.group!.name) ||
              _groupsNameFilterSelector.isEmpty,
        ),
      )
      ..sort((a, b) => a.group!.order.compareTo(b.order))
      ..sort((a, b) {
        if (a.group != b.group) {
          return a.group!.order.compareTo(b.order);
        }
        return a.order.compareTo(b.order);
      });

    for (final element in _chips) {
      element.key_ ??= GlobalKey();
      if (!groups.contains(element.group)) {
        groups.add(element.group!);
      }
    }
  }

  void _updateHeights() {
    ChipGroup? group;
    ChipGroup? lastGroup;

    for (final element in _chips) {
      if (element.group != lastGroup) {
        group = groups.firstWhere(
          (g) => g.name == element.group!.name,
          orElse: () {
            throw Exception("Group not found");
          },
        )..height_ = 0.0;
      }
      assert(group != null, "Group is null");
      group?.height_ = group.height_! + (_getHeight(element) ?? 0.0);
      lastGroup = group;
    }
  }

  double? _getHeight(ChipItemController chip) {
    final key = chip.key_;
    if (key?.currentContext != null) {
      final RenderBox box =
          key?.currentContext!.findRenderObject() as RenderBox;
      return box.size.height;
    }
    return null;
  }

  void _showOverlayPopup(BuildContext context) {
    assert(context.mounted, "Context is not mounted in builder");
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
                  height: height,
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
                  child: Stack(children: [body(setState), resizer(setState)]),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntryPopup!);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 1), () {
        _updateHeights();
        if (_overlayEntryPopup != null) {
          _overlayEntryPopup!.markNeedsBuild();
        }
        super.setState(() {});
      });
    });
  }

  Positioned resizer(StateSetter setState) {
    return Positioned(
      right: 0,
      bottom: 0,
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeDownRight,
        child: GestureDetector(
          onPanStart: (details) {
            initX = details.globalPosition.dx;
            initY = details.globalPosition.dy;
          },
          onPanUpdate: (details) {
            _updateHeights();
            setState(() {
              width += details.globalPosition.dx - initX;
              height += details.globalPosition.dy - initY;
              initX = details.globalPosition.dx;
              initY = details.globalPosition.dy;

              width = width.clamp(
                widget.controller.popupMinWidth,
                widget.controller.popupMaxWidth,
              );
              height = height.clamp(
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

  Widget body(StateSetter setState) {
    return Column(
      children: [
        Expanded(
          child: Builder(
            builder: (context) {
              return SingleChildScrollView(
                child: Material(
                  elevation: 4,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Barre latérale de couleur
                      Column(
                        children: groups.map((group) {
                          return Container(
                            color: group.backgroundColor,
                            width: 30,
                            height: group.height_ ?? 0,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: RotatedBox(
                                quarterTurns: 3,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: group.labelText != null
                                      ? Text(
                                          group.labelText!,
                                          style: group.labelStyle,
                                        )
                                      : group.labelWidget,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      // Zone de liste
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(_chips.length, (index) {
                            return Material(
                              color: index % 2 == 0
                                  ? widget.controller.backgroundColorAlt
                                  : widget.controller.backgroundColor,
                              child: Builder(
                                builder: (context) {
                                  assert(
                                    context.mounted,
                                    "Context is not mounted in builder",
                                  );
                                  return ListTile(
                                    key: _chips[index].key_,
                                    horizontalTitleGap: 8,
                                    tileColor: _chips[index].backgroundColor,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    dense: true,
                                    onTap: () {
                                      assert(
                                        context.mounted,
                                        "Context is not mounted in builder",
                                      );
                                      if (_chips.length <= index) {
                                        assert(
                                          false,
                                          "Chip index out of range",
                                        );
                                        return;
                                      }
                                      if (!_chips[index].alwaysDisplayed) {
                                        setState(() {
                                          _chips[index].displayed =
                                              !_chips[index].displayed;
                                        });
                                      }
                                    },
                                    leading: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (_chips[index].alwaysDisplayed)
                                          const Icon(
                                            Icons.lock_outline,
                                            color: Colors.grey,
                                          )
                                        else if (_chips[index].displayed)
                                          const Icon(
                                            Icons.remove_red_eye_outlined,
                                          )
                                        else
                                          const Icon(
                                            Icons.lock_outline,
                                            color: Colors.transparent,
                                          ),

                                        const SizedBox(width: 4),
                                        SizedBox(
                                          width: avatarSize,
                                          height: avatarSize,
                                          child: !_chips[index].hideAvatar
                                              ? _chips[index].avatar
                                              : null,
                                        ),
                                      ],
                                    ),
                                    title: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _chips[index].label,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (_chips[index].comments != null)
                                          Text(
                                            _chips[index].comments ?? "",
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Barre d'actions en bas
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Expanded(child: SizedBox()),
              if (_chips
                  .where((e) => e.displayed && !e.alwaysDisplayed)
                  .isNotEmpty)
                IconButton(
                  //tooltip: "Supprimer tous",
                  onPressed: () {
                    setState(() {
                      for (final element in _chips) {
                        element
                          ..clean()
                          ..displayed = false;
                      }
                    });
                    this.setState(() {});
                    _closeOverlayPopup();
                  },
                  icon: const Icon(Icons.recycling, color: Colors.orange),
                ),
              if (_chips.where((e) => e.hasValue()).isNotEmpty)
                IconButton(
                  //tooltip: "Effacer tous",
                  onPressed: () {
                    setState(() {
                      widget.controller.clear();
                    });
                    this.setState(() {});
                    _closeOverlayPopup();
                  },
                  icon: const Icon(Icons.recycling),
                ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _closeOverlayPopup,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _closeOverlayPopup() {
    _overlayEntryPopup?.remove();
    _overlayEntryPopup = null;
    _renderBox = null;
    _position = null;
  }

  void _getInputChipPosition() {
    _renderBox ??= _btnKey.currentContext?.findRenderObject() as RenderBox;
    _position ??= _renderBox?.localToGlobal(Offset.zero);
    final size = _renderBox?.size;
    widget.controller.chipX = _position?.dx;
    widget.controller.chipY = _position?.dy;
    widget.controller.chipWidth = size?.width;
    widget.controller.chipHeight = size?.height;
  }
}
