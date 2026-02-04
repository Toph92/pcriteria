import 'package:criteria/chips/chip_controllers.dart';
import 'package:criteria/chips/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChipAdd extends StatefulWidget {
  const ChipAdd({
    required this.controller,
    required this.groupsFilterSelector,
    this.layout,
    super.key,
  });

  final ChipsController controller;
  final List<ChipGroup>? groupsFilterSelector;
  final ChipLayout? layout;

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
    return widget.layout == ChipLayout.layout2
        ? _buildLayout2()
        : _buildLayout1();
  }

  Widget _buildLayout1() {
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

  Widget _buildLayout2() {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        key: _btnKey,
        margin: const EdgeInsets.only(bottom: 4.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
            BoxShadow(
              color: Colors.lightBlue.withOpacity(0.15),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Material(
          borderRadius: BorderRadius.circular(12),
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              if (_chips.isNotEmpty) {
                _showOverlayPopup2(context);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.lightBlue.shade50,
                    Colors.lightBlue.shade100,
                    Colors.lightBlue.shade200,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
                border: Border.all(
                  color: Colors.lightBlue.shade300,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icône avec animation
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.lightBlue.shade600,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.lightBlue.shade600.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_circle_outline,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Texte avec style amélioré
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Critères',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.lightBlue.shade800,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.filter_list,
                            size: 12,
                            color: Colors.lightBlue.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_chips.where((e) => e.displayed).length}/${_chips.length} affichés',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.lightBlue.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(width: 8),

                  // Indicateur avec badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.lightBlue.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _chips.where((e) => e.hasValue()).isNotEmpty
                                ? Colors.green.shade500
                                : Colors.grey.shade400,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${_chips.where((e) => e.hasValue()).length}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.lightBlue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void initChips() {
    _groupsNameFilterSelector =
        widget.groupsFilterSelector?.map((e) => e.name).toList() ?? [];
    _chips
      ..addAll(
        widget.controller.chips.where(
          (e) =>
              _groupsNameFilterSelector.contains(e.group.name) ||
              _groupsNameFilterSelector.isEmpty,
        ),
      )
      ..sort((a, b) => a.group.order.compareTo(b.order))
      ..sort((a, b) {
        if (a.group != b.group) {
          return a.group.order.compareTo(b.order);
        }
        return a.order.compareTo(b.order);
      });

    for (final element in _chips) {
      element.key_ ??= GlobalKey();
      if (!groups.contains(element.group)) {
        groups.add(element.group);
      }
    }
  }

  void _updateHeights() {
    ChipGroup? group;
    ChipGroup? lastGroup;

    for (final element in _chips) {
      if (element.group != lastGroup) {
        group = groups.firstWhere(
          (g) => g.name == element.group.name,
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

  void _showOverlayPopup2(BuildContext context) {
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
                  width: width.clamp(350, 600),
                  height: height.clamp(400, 700),
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
                                    color: Colors.lightBlue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.add_circle_outline,
                                    color: Colors.lightBlue.shade600,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Ajouter des critères',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: _closeOverlayPopup,
                                  icon: Icon(
                                    Icons.close_rounded,
                                    color: Colors.grey.shade600,
                                    size: 20,
                                  ),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    padding: const EdgeInsets.all(8),
                                    minimumSize: const Size(32, 32),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Contenu principal moderne
                          Expanded(child: body2(setState)),

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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${_chips.where((e) => e.displayed).length}/${_chips.length} critères affichés',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (_chips
                                        .where((e) => e.hasValue())
                                        .isNotEmpty)
                                      IconButton.outlined(
                                        //tooltip: "Effacer toutes les valeurs",
                                        onPressed: () {
                                          setState(() {
                                            for (final element in _chips) {
                                              element.clean();
                                            }
                                          });
                                          this.setState(() {});
                                        },
                                        icon: const Icon(
                                          Icons.clear_all,
                                          size: 18,
                                        ),
                                        style: IconButton.styleFrom(
                                          backgroundColor:
                                              Colors.orange.shade50,
                                          foregroundColor:
                                              Colors.orange.shade600,
                                          side: BorderSide(
                                            color: Colors.orange.shade200,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(width: 8),
                                    if (_chips
                                        .where(
                                          (e) =>
                                              e.displayed && !e.alwaysDisplayed,
                                        )
                                        .isNotEmpty)
                                      IconButton.outlined(
                                        //tooltip: "Masquer tous les critères",
                                        onPressed: () {
                                          setState(() {
                                            for (final element in _chips) {
                                              if (!element.alwaysDisplayed) {
                                                element
                                                  ..clean()
                                                  ..displayed = false;
                                              }
                                            }
                                          });
                                          this.setState(() {});
                                        },
                                        icon: const Icon(
                                          Icons.visibility_off,
                                          size: 18,
                                        ),
                                        style: IconButton.styleFrom(
                                          backgroundColor: Colors.red.shade50,
                                          foregroundColor: Colors.red.shade600,
                                          side: BorderSide(
                                            color: Colors.red.shade200,
                                          ),
                                        ),
                                      ),
                                  ],
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
                              initX = details.globalPosition.dx;
                              initY = details.globalPosition.dy;
                            },
                            onPanUpdate: (details) {
                              setState(() {
                                width += details.globalPosition.dx - initX;
                                height += details.globalPosition.dy - initY;
                                initX = details.globalPosition.dx;
                                initY = details.globalPosition.dy;

                                width = width.clamp(350, 800);
                                height = height.clamp(400, 800);
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

  Widget body2(StateSetter setState) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Liste des groupes et critères moderne
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: List.generate(groups.length, (groupIndex) {
                final group = groups[groupIndex];
                final groupChips = _chips
                    .where((chip) => chip.group == group)
                    .toList();

                return Column(
                  children: [
                    // En-tête du groupe
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: group.backgroundColor,
                        borderRadius: groupIndex == 0
                            ? const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              )
                            : BorderRadius.zero,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.category,
                              size: 16,
                              color: group.backgroundColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            group.labelText ?? 'Groupe ${groupIndex + 1}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${groupChips.where((c) => c.displayed).length}/${groupChips.length}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: group.backgroundColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Critères du groupe
                    ...List.generate(groupChips.length, (chipIndex) {
                      final chip = groupChips[chipIndex];
                      final isLast =
                          chipIndex == groupChips.length - 1 &&
                          groupIndex == groups.length - 1;

                      return Container(
                        decoration: BoxDecoration(
                          color: chipIndex % 2 == 0
                              ? Colors.grey.shade50
                              : Colors.white,
                          borderRadius: isLast
                              ? const BorderRadius.only(
                                  bottomLeft: Radius.circular(8),
                                  bottomRight: Radius.circular(8),
                                )
                              : BorderRadius.zero,
                        ),
                        child: ListTile(
                          key: chip.key_,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          onTap: !chip.alwaysDisplayed
                              ? () {
                                  setState(() {
                                    chip.displayed = !chip.displayed;
                                  });
                                  this.setState(() {});
                                }
                              : null,
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Indicateur de statut
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: chip.alwaysDisplayed
                                      ? Colors.grey.shade200
                                      : chip.displayed
                                      ? Colors.green.shade100
                                      : Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  chip.alwaysDisplayed
                                      ? Icons.lock_outline
                                      : chip.displayed
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  size: 16,
                                  color: chip.alwaysDisplayed
                                      ? Colors.grey.shade600
                                      : chip.displayed
                                      ? Colors.green.shade600
                                      : Colors.red.shade600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Avatar du critère
                              if (!chip.hideAvatar && chip.avatar != null)
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: chip.avatar,
                                ),
                            ],
                          ),
                          title: Text(
                            chip.label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: chip.alwaysDisplayed
                                  ? Colors.grey.shade600
                                  : Colors.grey.shade800,
                            ),
                          ),
                          subtitle: chip.comments != null
                              ? Text(
                                  chip.comments!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                )
                              : null,
                          trailing: chip.hasValue()
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Valeur',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      );
                    }),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
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
