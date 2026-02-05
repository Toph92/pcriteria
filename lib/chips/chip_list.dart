import 'package:criteria/chips/chip_controllers.dart';
import 'package:criteria/chips/chip_decorator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
export 'chip_list_maker.dart';

class ChipList extends StatefulWidget {
  const ChipList({required this.controller, super.key});

  final ChipListController controller;
  @override
  State<ChipList> createState() => _ChipListState();
}

class _ChipListState extends State<ChipList> {
  final GlobalKey _inputChipKey = GlobalKey();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntryPopup;
  OverlayEntry? _overlayEntryHover;
  double _initX = 0;
  double _initY = 0;

  double _popupWidth = 0;
  double _popupHeight = 0;

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
    return _buildLayout1();
  }

  Widget _buildLayout1() {
    return CompositedTransformTarget(
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
        child: ChipDecorator(
          key: _inputChipKey,
          controller: widget.controller,
          onTap: () {
            _showOverlayPopup(context);
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.controller.selectedItems.isNotEmpty
                  ? _displayResume(mode: widget.controller.displayMode)
                  : Text(
                      '${widget.controller.label} ?',
                      style: widget.controller.emptyLabelStyle,
                    ),
            ],
          ),
        ),
      ),
    );
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

  List<Widget> sanitizeChildren(List<Widget> children) {
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

  Widget displayResume({
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
                    children: sanitizeChildren(item.children!),
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
                    : Row(children: sanitizeChildren(item.children!)),
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
