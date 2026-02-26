import 'package:criteria/chips/chip_decorator.dart';
import 'package:criteria/chips/chip_text_completion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChipTextCompletionSingle extends StatefulWidget {
  const ChipTextCompletionSingle({required this.controller, super.key});

  final ChipTextCompletionController controller;

  @override
  State<ChipTextCompletionSingle> createState() =>
      _ChipTextCompletionSingleState();
}

class _ChipTextCompletionSingleState extends State<ChipTextCompletionSingle>
    with WidgetsBindingObserver {
  final OverlayPortalController _overlayPortalController =
      OverlayPortalController();
  final GlobalKey _chipKey = GlobalKey();

  // Resize vars
  double _initX = 0;
  double _initY = 0;
  late double _popupWidth;
  late double _popupHeight;
  bool _isResizing = false;

  @override
  void initState() {
    super.initState();
    widget.controller.focusNode?.addListener(_onFocusChange);
    widget.controller.textControleur.addListener(_onTextChanged);
    widget.controller.addListener(_refresh);
    WidgetsBinding.instance.addObserver(this);

    _popupWidth =
        widget.controller.popupWidth ??
        (widget.controller.popupInitWidth * 1.8);
    _popupHeight =
        widget.controller.popupHeight ?? widget.controller.popupInitHeight;
  }

  @override
  void didUpdateWidget(covariant ChipTextCompletionSingle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.focusNode?.removeListener(_onFocusChange);
      oldWidget.controller.textControleur.removeListener(_onTextChanged);
      oldWidget.controller.removeListener(_refresh);

      widget.controller.focusNode?.addListener(_onFocusChange);
      widget.controller.textControleur.addListener(_onTextChanged);
      widget.controller.addListener(_refresh);

      if (widget.controller.popupWidth != null) {
        _popupWidth = widget.controller.popupWidth!;
      }
      if (widget.controller.popupHeight != null) {
        _popupHeight = widget.controller.popupHeight!;
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.controller.focusNode?.removeListener(_onFocusChange);
    widget.controller.textControleur.removeListener(_onTextChanged);
    widget.controller.removeListener(_refresh);
    super.dispose();
  }

  void _onFocusChange() async {
    if (!mounted) return;
    if (widget.controller.focusNode == null) return;

    if (!widget.controller.focusNode!.hasFocus) {
      // Delay to allow onTap to set selectedFromList
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;
      if (_isResizing) return;
      if (!widget.controller.focusNode!.hasFocus) {
        if (widget.controller.popupDisplayed) {
          _closeOverlayPopup();
        } else {
          await _validateSelection();
        }
        widget.controller.updating = false;
        _refresh();
      }
    } else {
      // Gain focus
      if (widget.controller.minCharacterNeeded == 0 &&
          !widget.controller.popupDisplayed) {
        await Future.delayed(const Duration(milliseconds: 50));
        if (!mounted) return;
        if (widget.controller.focusNode?.hasFocus ?? false) {
          _openOverlayPopup();
        }
      }
    }
  }

  Future<void> _validateSelection() async {
    if (widget.controller.needSelectedItem &&
        !widget.controller.selectedFromList) {
      final text = widget.controller.textControleur.text;
      if (text.isNotEmpty) {
        if (text.length < widget.controller.minCharacterNeeded) {
          widget.controller.textControleur.clear();
          widget.controller.selectedItems.clear();
          widget.controller.onSelected?.call([]);
          return;
        }

        // Wait for search to finish if in progress
        int timeout = 0;
        while (widget.controller.searching && timeout < 10) {
          await Future.delayed(const Duration(milliseconds: 100));
          timeout++;
        }
        if (widget.controller.dataSourceFiltered != null &&
            widget.controller.dataSourceFiltered!.isNotEmpty) {
          final item = widget.controller.dataSourceFiltered!.first;
          widget.controller.textControleur.text = item.displaySelected;
          widget.controller.selectedItems = [item];
          widget.controller.selectedFromList = true;
          widget.controller.onSelected?.call(
            widget.controller.selectedItems.cast<SearchEntry>() as dynamic,
          );
        } else {
          widget.controller.textControleur.clear();
          widget.controller.selectedItems.clear();
          widget.controller.onSelected?.call([]);
        }
      } else {
        widget.controller.selectedItems.clear();
        widget.controller.onSelected?.call([]);
      }
    }
  }

  void _onTextChanged() {
    if (widget.controller.programmaticUpdate) return;
    widget.controller.selectedFromList = false;
    final text = widget.controller.textControleur.text;
    if (text.length >= widget.controller.minCharacterNeeded) {
      if (!widget.controller.popupDisplayed) {
        _openOverlayPopup();
      } else {
        _updateResults();
      }
    } else {
      if (widget.controller.popupDisplayed) {
        _closeOverlayPopup();
      }
    }
    _refresh();
  }

  Future<void> _updateResults() async {
    if (!mounted) return;
    widget.controller.updateCriteria(widget.controller.textControleur.text);
    await widget.controller.updateResultset();
    if (!mounted) return;
    setState(() {});
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _openOverlayPopup() {
    if (!mounted) return;
    widget.controller.updating = true;
    widget.controller.popupDisplayed = true;
    _overlayPortalController.show();
    _updateResults();
  }

  void _closeOverlayPopup() async {
    await _validateSelection();
    widget.controller.popupDisplayed = false;
    widget.controller.updating = false;
    _overlayPortalController.hide();
    _refresh();
  }

  Widget _resizer() {
    return Positioned(
      right: 0,
      bottom: 0,
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeDownRight,
        child: GestureDetector(
          onPanDown: (details) {
            _isResizing = true;
          },
          onPanStart: (details) {
            _isResizing = true;
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
          onPanEnd: (details) {
            _isResizing = false;
            widget.controller.focusNode?.requestFocus();
          },
          onPanCancel: () {
            _isResizing = false;
            widget.controller.focusNode?.requestFocus();
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

  Widget _popupBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.controller.popupHeaderItems.isNotEmpty) _popupHeader(),
        if (widget.controller.dataSourceFiltered != null &&
            widget.controller.dataSourceFiltered!.isNotEmpty)
          Expanded(
            child: ListView.separated(
              itemCount: widget.controller.dataSourceFiltered!.length,
              separatorBuilder: (context, index) => const Divider(height: 3),
              itemBuilder: (context, index) {
                final item = widget.controller.dataSourceFiltered![index];
                return InkWell(
                  hoverColor: Colors.yellow,
                  onTap: () {
                    // Update text and selected items
                    widget.controller.textControleur.text =
                        item.displaySelected;
                    widget.controller.selectedItems = [item];
                    widget.controller.selectedFromList = true;

                    widget.controller.onSelected?.call(
                      widget.controller.selectedItems.cast<SearchEntry>()
                          as dynamic,
                    );

                    _closeOverlayPopup();
                    widget.controller.notify();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        Expanded(child: item.displayInList(widget.controller)),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        else
          _popupNoResults(),
        _footerPopup(),
      ],
    );
  }

  Widget _popupHeader() {
    return Container(
      padding: const EdgeInsets.all(4),
      color: Colors.grey.shade100,
      child: Wrap(
        spacing: 8,
        children: widget.controller.popupHeaderItems.map((item) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                visualDensity: VisualDensity.compact,
                value: item.checked,
                onChanged: (val) {
                  item.checked = val ?? false;
                  _updateResults();
                },
              ),
              Text(item.label, style: const TextStyle(fontSize: 12)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _popupNoResults() {
    return Expanded(
      child: Center(
        child: widget.controller.searching
            ? const CircularProgressIndicator()
            : const Text(
                'Aucun résultat',
                style: TextStyle(color: Colors.grey),
              ),
      ),
    );
  }

  Widget _footerPopup() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        children: [
          const Divider(height: 1),
          Row(
            children: [
              if (widget.controller.dataSourceFiltered != null)
                Text(
                  "${widget.controller.dataSourceFiltered!.length} résultats",
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, size: 16),
                onPressed: _closeOverlayPopup,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal.overlayChildLayoutBuilder(
      controller: _overlayPortalController,
      overlayChildBuilder: (BuildContext context, OverlayChildLayoutInfo info) {
        final Offset anchorOffset = MatrixUtils.transformPoint(
          info.childPaintTransform,
          Offset.zero,
        );

        return Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _closeOverlayPopup,
              child: SizedBox.fromSize(size: info.overlaySize),
            ),
            Positioned(
              left: anchorOffset.dx + widget.controller.popupXoffset,
              top: anchorOffset.dy + info.childSize.height,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: _popupWidth,
                  height: _popupHeight,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: widget.controller.popupBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(children: [_popupBody(), _resizer()]),
                ),
              ),
            ),
          ],
        );
      },
      child: ChipDecorator(
        key: _chipKey,
        controller: widget.controller,
        onTap: () {
          if (widget.controller.minCharacterNeeded == 0 &&
              !widget.controller.popupDisplayed) {
            _openOverlayPopup();
          } else {
            widget.controller.focusNode?.requestFocus();
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: TextFormField(
            controller: widget.controller.textControleur,
            focusNode: widget.controller.focusNode,
            style: widget.controller.inputTextStyle,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: widget.controller.label,
              hintStyle: widget.controller.emptyLabelStyle,
            ),
          ),
        ),
      ),
    );
  }
}
