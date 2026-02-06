import 'package:criteria/chips/chip_controllers.dart';
import 'package:criteria/chips/chip_decorator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

export 'package:flutter/services.dart';

class CacheItem<T> {
  CacheItem({required this.key, required this.value});
  final String key;
  final List<T> value;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CacheItem) return false;
    return key == other.key;
  }

  @override
  int get hashCode => key.hashCode;
}

class CacheManager<T> {
  CacheManager({this.maxSize = 100}) {
    assert(maxSize > 0);
  }

  int maxSize;
  List<CacheItem> cache = [];

  void add(CacheItem item) {
    if (get(item.key) != null) {
      return;
    }
    cache.add(item);
    if (cache.length > maxSize) {
      cache.removeAt(0);
    }
  }

  List<T>? get(String key) {
    for (final CacheItem item in cache) {
      if (item.key == key) {
        return item.value.cast<T>();
      }
    }
    return null;
  }

  bool isNotEmpty() {
    return cache.isNotEmpty;
  }

  List<T> get fullContent {
    List<T> result = [];
    for (final CacheItem item in cache) {
      result.addAll(item.value.cast<T>());
    }
    result = result.toSet().toList();
    return result;
  }
}

class ChipTextCompletion extends StatefulWidget {
  const ChipTextCompletion({required this.controller, super.key});

  final ChipTextCompletionController controller;

  @override
  State<ChipTextCompletion> createState() => _ChipTextCompletionState();
}

class _ChipTextCompletionState extends State<ChipTextCompletion>
    with WidgetsBindingObserver {
  StateSetter? _overlaySetState;
  final GlobalKey _inputChipKey = GlobalKey();
  final GlobalKey _textKey = GlobalKey();

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntryPopup;
  String? hintMessage;

  // Variables pour le redimensionnement
  double _initX = 0;
  double _initY = 0;
  late double _popupWidth;
  late double _popupHeight;
  final GlobalKey _wrapKey = GlobalKey();

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.controller.focusNode.removeListener(_onFocusChange);
    widget.controller.removeListener(_refresh);
    _overlaySetState = null;
    _overlayEntryPopup?.remove();
    _overlayEntryPopup = null;
    super.dispose();
  }

  @override
  void initState() {
    widget.controller.focusNode.addListener(_onFocusChange);
    WidgetsBinding.instance.addObserver(this);

    // Initialiser les dimensions du popup
    _popupWidth = widget.controller.popupInitWidth * 1.8; // bidouille
    _popupHeight = widget.controller.popupInitHeight;

    // Ajouter les listeners pour la completion de texte
    widget.controller.textControleur.addListener(_onTextChanged);
    widget.controller.addListener(_refresh);
    super.initState();
  }

  @override
  void didChangeMetrics() {
    // Appelé lorsque les métriques d'affichage changent (redimensionnement de fenêtre)
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateWrapHeight());
  }

  void _updateWrapHeight() {}

  void _onTextChanged() {
    _refresh();
  }

  void _onFocusChange() async {
    if (!widget.controller.focusNode.hasFocus &&
        widget.controller.popupDisplayed == false) {
      Future.delayed(const Duration(milliseconds: 100), () {
        widget.controller.updating = false;
        _refresh();
      });
    }
  }

  void _refresh() {
    _refreshOverlay();
    if (mounted) setState(() {});
  }

  void _openOverlayPopup(BuildContext context) {
    _overlayEntryPopup?.remove();
    _overlayEntryPopup = null;
    widget.controller.dataSourceFiltered = null;
    widget.controller._arCriteria = null;

    Future.delayed(const Duration(milliseconds: 50), () {
      widget.controller.focusNode.requestFocus();
    });
    //widget.controller.focusNode.requestFocus();

    _getInputChipPosition();
    widget.controller.updating = true;
    widget.controller.popupDisplayed = true;

    _overlayEntryPopup = OverlayEntry(
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          _overlaySetState = setState;
          return Stack(
            children: [
              GestureDetector(
                onTap: () {
                  _closeOverlayPopup();
                  widget.controller.updating = false;
                },
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
                    child: Stack(
                      children: [_popupBody(setState), resizer(setState)],
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

  void _refreshOverlay() {
    if (_overlayEntryPopup == null) return;
    if (_overlaySetState != null) _overlaySetState!(() {});
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

  Widget _popupHeader() {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      children: [
        ...widget.controller.popupHeaderItems.map(
          (item) => Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  visualDensity: const VisualDensity(vertical: -4),
                  value: item.checked,
                  onChanged: (bool? value) {
                    item.checked = value ?? false;
                    cannotHaveAllUnset();
                    _updateResults();
                    _refresh();
                  },
                ),
                Text(
                  item.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void cannotHaveAllUnset() {
    if (widget.controller.popupHeaderItems.isEmpty) return;
    if (widget.controller.popupHeaderItems
        .where((item) => item.checked != false)
        .isNotEmpty) {
      return;
    }
    // Si tous les items sont décochés, on coche tous
    for (final item in widget.controller.popupHeaderItems) {
      item.checked = true;
    }
  }

  Widget _popupBody(StateSetter setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _inputText(),
        if (widget.controller.popupHeaderItems.isNotEmpty) ...[
          Container(
            width: _popupWidth,
            color: Colors.grey.shade100,
            child: const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text(
                "Filtres de recherche",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.grey.shade100, Colors.grey.shade400],
              ),
            ),
            width: _popupWidth,
            child: _popupHeader(),
          ),
        ],
        if (widget.controller.dataSourceFiltered != null &&
            widget.controller.dataSourceFiltered!.isNotEmpty)
          Expanded(
            child: ListView.separated(
              itemCount: widget.controller.dataSourceFiltered!.length,
              separatorBuilder: (context, index) => const Divider(height: 3),
              itemBuilder: (context, index) {
                final SearchEntry? item =
                    widget.controller.dataSourceFiltered?[index];
                return item != null
                    ? Material(
                        type: MaterialType.transparency,
                        child: ListTile(
                          horizontalTitleGap: 4,
                          minLeadingWidth: 0,
                          minVerticalPadding: 0,
                          contentPadding: const EdgeInsets.only(
                            left: 4,
                            right: 4,
                          ),
                          visualDensity: const VisualDensity(vertical: -4),
                          dense: true,
                          hoverColor: Colors.yellow,
                          leading: item.fuzzySearchResult
                              ? Icon(
                                  Icons.help,
                                  size: 24,
                                  color: Colors.blue.withValues(
                                    alpha: ((item._fuzzyScore ?? 1.0) * 2)
                                        .clamp(0.1, 1.0),
                                  ),
                                )
                              : const Icon(
                                  Icons.keyboard_arrow_right,
                                  size: 24,
                                  color: Colors.green,
                                ),
                          title: item.displayInList(widget.controller),
                          onTap: () {
                            widget.controller.selectedItems.add(item);
                            widget.controller.onSelected?.call(
                              widget.controller.selectedItems,
                            );
                            widget.controller.selectedFromList = true;
                            if (widget.controller.keepPopupOpen &&
                                widget.controller.selectedItems.length <
                                    widget.controller.maxEntries) {
                              widget.controller.instantMessage =
                                  "Critère ajouté";
                              _refreshOverlay();
                              widget.controller.focusNode.requestFocus();
                            } else {
                              _closeOverlayPopup();
                            }
                            //_closeOverlayPopup();
                            widget.controller.dataSourceFiltered = null;
                            widget.controller._arCriteria = null;
                            widget.controller.textControleur.clear();
                            widget.controller.updating = false;
                            // Rafraîchir l'état du widget parent
                            this.setState(() {});
                          },
                        ),
                      )
                    : const SizedBox(height: 0, width: 0);
              },
            ),
          )
        else
          _popupNoResults(),
        // Barre de statut en bas
        _footerPopup(),
      ],
    );
  }

  Widget _popupNoResults() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              spacing: 2,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline, size: 24, color: Colors.blue),
                Flexible(
                  child: Text(
                    widget.controller.textControleur.text.length <
                            widget.controller.minCharacterNeeded
                        ? 'Entrez au moins ${widget.controller.minCharacterNeeded} caractères'
                        : 'Aucun résultat',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),

            Visibility(
              visible: widget.controller.searching,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _footerPopup() {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _footerResultsMessage(),
                    _footerInstantMessageWidget(),
                    _footerFuzzySearchMessage(),
                  ],
                ),
                const Expanded(child: SizedBox()),
                if (widget.controller.keepPopupOpen) ...[
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
      ),
    );
  }

  Widget _footerFuzzySearchMessage() {
    if (widget.controller.dataSourceFiltered != null &&
        widget.controller.dataSourceFiltered!.isNotEmpty &&
        widget.controller.dataSourceFiltered!.any(
          (item) => item.fuzzySearchResult,
        )) {
      return const Row(
        children: [
          Icon(Icons.help, size: 20, color: Colors.blue),
          Text(
            " recherche approchante",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _footerResultsMessage() {
    TextStyle normalStyle = const TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 12,
    );
    TextStyle labelStyle = const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: Colors.grey,
    );

    if (widget.controller.dataSourceFiltered != null &&
        widget.controller.dataSourceFiltered!.isNotEmpty) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(width: 4),
          Text(
            "${widget.controller.dataSourceFiltered!.length >= widget.controller.maxResults ? '> ' : ''}${widget.controller.dataSourceFiltered!.length}",
            style: normalStyle,
          ),
          const SizedBox(width: 2),
          Text(
            "résultat${widget.controller.dataSourceFiltered!.length > 1 ? 's' : ''}",
            style: labelStyle,
          ),
          if (widget.controller.durationLastRequest != null &&
              widget.controller.durationLastRequest!.inMilliseconds > 10) ...[
            const SizedBox(width: 30),
            Text(
              "${widget.controller.durationLastRequest!.inMilliseconds}",
              style: normalStyle,
            ),
            Text("ms", style: labelStyle),
          ],
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _footerInstantMessageWidget() {
    if (widget.controller._instantMessage == null) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.only(top: 3, bottom: 3),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.green.shade500,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        "Critère ajouté",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  void _closeOverlayPopup() {
    if (_overlayEntryPopup == null && widget.controller.popupDisplayed) {
      //widget.controller.updating = false;
      return;
    }

    _overlayEntryPopup?.remove();
    _overlayEntryPopup?.dispose();
    _overlayEntryPopup = null;
    widget.controller.popupDisplayed = false;
    //widget.controller.updating = false;
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

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: ChipDecorator(
        key: _inputChipKey,
        controller: widget.controller,
        onTap: () {
          if (widget.controller.selectedItems.isEmpty ||
              widget.controller.selectedItems.length <
                  widget.controller.maxEntries) {
            _openOverlayPopup(context);
          }
        },
        child: widget.controller.selectedItems.isNotEmpty
            ? _displayChips()
            : Text(
                '${widget.controller.label} ?',
                style: widget.controller.emptyLabelStyle,
              ),
      ),
    );
  }

  Widget _inputText() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: FormField(
            builder: (formFieldState) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  autofocus: true,
                  key: _textKey,

                  focusNode: widget.controller.focusNode,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: widget.controller.popupHeaderItems.isNotEmpty
                        ? '${widget.controller.popupHeaderItems.where((item) => item.checked).map((item) => item.label).join(', ')} ?'
                        : 'Vos critères ?',
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  controller: widget.controller.textControleur,
                  style: widget.controller.altTextStyle,
                  inputFormatters: widget.controller.inputFormatters,
                  onChanged: (value) async {
                    onChangedTxtCompletion(value);
                  },
                ),
              );
            },
          ),
        ),
        if (widget.controller.textControleur.text.isNotEmpty)
          IconButton(
            iconSize: 20,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.close),
            //tooltip: widget.controller.tooltipMessageErase,
            onPressed: () {
              widget.controller.textControleur.clear();
              widget.controller.dataSourceFiltered = null;
              widget.controller._arCriteria = null;
              widget.controller.updating = false;
              widget.controller.displayed = false;
              _refresh();
              widget.controller.focusNode.requestFocus();
              /* Future.delayed(const Duration(milliseconds: 100), () {
                widget.controller.focusNode.requestFocus();
              }); */
            },
          ),
      ],
    );
  }

  Widget _displayChips() {
    return Wrap(
      key: _wrapKey,
      //crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4.0,
      children: [
        if (widget.controller.selectedItems.isNotEmpty)
          ...widget.controller.selectedItems.map(
            (SearchEntry chip) => Tooltip(
              message: chip.hoverDescription ?? '',
              child: Chip(
                padding: const EdgeInsets.all(0),
                label: Text(chip.displaySelected),
                labelPadding: const EdgeInsets.only(left: 4),
                visualDensity: const VisualDensity(vertical: -4),
                deleteIcon: const Icon(Icons.close),
                deleteButtonTooltipMessage:
                    widget.controller.tooltipMessageRemove,
                onDeleted: widget.controller.disable
                    ? null
                    : () {
                        widget.controller.selectedItems.remove(chip);
                        widget.controller.notify();
                        widget.controller.onSelected?.call(
                          widget.controller.selectedItems,
                        );
                        _refresh();
                      },
              ),
            ),
          ),
      ],
    );
  }

  void onChangedTxtCompletion(String value) async {
    widget.controller.selectedFromList = false;
    widget.controller.updateCriteria(value);
    await _updateResults();
    _refresh();
  }

  Future<void> _updateResults() async {
    await widget.controller.updateResultset();
    if (widget.controller.dataSourceFiltered != null &&
        widget.controller.dataSourceFiltered!.isNotEmpty) {}
    _refresh();
  }
}

enum SearchOptionKey {
  unknown("unknown"),
  maxResults("maxResults"),
  numRequest("numRequest");

  const SearchOptionKey(this.key);

  final String key;

  @override
  String toString() => key;
}

class ChipTextCompletionController<T extends SearchEntry>
    extends ChipItemController
    with ChipsPoupAttributs {
  ChipTextCompletionController({
    required super.name,
    required this.onRequestUpdateDataSource,
    super.group,
    super.label,
    this.onSelected,
    this.fuzzySearchStep = 0,
    this.minCharacterNeeded = 2,
    super.avatar = const Icon(Icons.abc, size: 24),
    super.chipType = ChipType.textCompletion,
    super.onEnter,
  }) {
    if (maxEntries < 1) {
      maxEntries = 1;
    }
    assert(
      ((keepPopupOpen == true && maxEntries > 1) ||
          (keepPopupOpen == false && maxEntries == 1)),
      "maxEntries doit être supérieur à 1 si keepPopupOpen est vrai",
    );
    _focusNode = FocusNode()..addListener(_onFocusChange);
    textControleur = TextEditingController();
    cacheManager = CacheManager<T>();
    popupMinWidth = 250;
    popupMinHeight = 300;
  }

  // Nouvelles propriétés pour la completion de texte
  List<T>? dataSource;
  List<T>? dataSourceFiltered;
  late CacheManager<T> cacheManager;
  int nbBestFuzzy = 5;
  int maxResults = 1000;
  List<String>? _arCriteria;
  int? fuzzySearchStep; // null pour désactiver la recherche floue
  bool selectedFromList = false;
  int minCharacterNeeded;

  /// Garder le popup ouvert après sélection
  bool keepPopupOpen = false;

  /// Nombre maximum d'entrées à afficher
  int maxEntries = 1;

  void Function(List<T> values)? onSelected;
  List<SearchEntry> selectedItems = [];
  int _numRequest = 0;
  int _lastNumRequest = 0;
  bool _searching = false;

  bool get searching => _searching;
  /* set searching(bool value) {
    if (value != _searching) {
      _searching = value;
      notifyListeners();
    }
  } */
  // int? currentCriterionIndex;

  // callback to update data from parent
  Future<(List<T>?, Map<String, dynamic>?)> Function(
    List<String>? arCriteria,
    List<PopupHeaderControllerItem>? popupHeaderItems,
    Map<SearchOptionKey, dynamic> searchOptions,
  )
  onRequestUpdateDataSource;

  List<TextInputFormatter> inputFormatters = [];
  List<PopupHeaderControllerItem> popupHeaderItems = [];

  //late final TextEditingController _textControleur;
  //TextEditingController get textControleur => _textControleur;
  late final TextEditingController textControleur;

  late final FocusNode _focusNode;
  FocusNode get focusNode => _focusNode;

  TextStyle textStyle = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  // Propriété pour mesurer la durée des requêtes
  Duration? durationLastRequest;

  String? _instantMessage;
  set instantMessage(String? value) {
    _instantMessage = value;
    if (_instantMessage != null && _instantMessage!.isNotEmpty) {
      Future.delayed(const Duration(seconds: 2), () {
        _instantMessage = null;
        notifyListeners();
      });
    }
  }

  String? get instantMessage => _instantMessage;

  // Méthodes pour la completion de texte
  void updateCriteria(String value) {
    value = value.trim();
    List<String> chunks =
        value
            .removeAccents()
            .toUpperCase()
            .replaceAll(RegExp('\\s+'), ' ')
            .split(' ')
          ..removeWhere((element) => element == ' ' || element == '');
    chunks = Set<String>.from(chunks).toList();
    _arCriteria = chunks;
    //currentCriterionIndex = position;
  }

  Future<void> updateResultset() async {
    final stopwatch = Stopwatch()..start();
    durationLastRequest = null;
    dataSourceFiltered = null;
    Map<SearchOptionKey, dynamic>? searchOptions;
    List<T>? localDataSource;

    _arCriteria = _arCriteria
        ?.where((e) => e.length >= minCharacterNeeded)
        .toList();

    if (_arCriteria == null || _arCriteria!.isEmpty) {
      return;
    }

    try {
      String keyCache =
          '${(_arCriteria ?? []).join(' ')}|${popupHeaderItems.isNotEmpty ? popupHeaderItems.where((e) => e.checked).map((e) => e.key).join(',') : ''}'; // super lisible !
      dataSource = cacheManager.get(keyCache);

      if (dataSource != null && dataSource!.isNotEmpty) {
        dataSourceFiltered = dataSource;
        return; // on a déjà les données en cache
      }
      // rien dans le cache
      Map<String, dynamic>? tmpJson;
      _searching = true;
      notifyListeners();
      (
        localDataSource,
        tmpJson,
      ) = await onRequestUpdateDataSource(_arCriteria, popupHeaderItems, {
        SearchOptionKey.maxResults: maxResults,
        SearchOptionKey.numRequest: _numRequest++,
      });
      searchOptions = tmpJson?.map(
        (key, value) => MapEntry(
          SearchOptionKey.values.firstWhere(
            (e) => e.toString().split('.').last == key,
            orElse: () => SearchOptionKey.unknown,
          ),
          value,
        ),
      );

      if (searchOptions != null &&
          searchOptions[SearchOptionKey.numRequest] < _lastNumRequest) {
        // Si la requête est plus ancienne que la dernière, on ignore
        //print("Abort request: ${searchOptions[SearchOptionKey.numRequest]}");
        return;
      }
      _lastNumRequest = searchOptions?[SearchOptionKey.numRequest] ?? 0;
      dataSource = localDataSource;
      if (dataSource == null) return; // si null, c'est qu'il y a un problème

      /* if (dataSource != null && dataSource!.isNotEmpty) {
        cacheManager.add(
          CacheItem<T>(key: keyCache, value: List.from(dataSource!)),
        );
      } */

      assert(dataSource != null); // si null , c'est qu'il y a un problème

      dataSourceFiltered = dataSource;
      dataSourceFiltered?.forEach((element) {
        (element).fuzzySearchResult = false;
      });

      // recherche floue
      if ((dataSourceFiltered!.isEmpty ||
              dataSourceFiltered!.length <= (fuzzySearchStep ?? 0)) &&
          fuzzySearchStep != null &&
          cacheManager.isNotEmpty() &&
          _arCriteria != null) {
        List<T>? tmpBestFuzzy = _getNearestEntries(
          arCriteria: _arCriteria!,
          dataSource: cacheManager.isNotEmpty()
              ? cacheManager.fullContent
              : dataSource!,
        );

        List<T>? bestFuzzyItems = [];
        for (final T element in tmpBestFuzzy) {
          //element.fuzzySearchResult = true;
          bestFuzzyItems.add(element.copyWith() as T);
        }
        for (final T element in bestFuzzyItems) {
          element.fuzzySearchResult = true;
        }

        dataSourceFiltered!.addAll(
          bestFuzzyItems.where((p) => !dataSourceFiltered!.contains(p)),
        );
      } // fin recherche floue
      if (dataSource != null && dataSource!.isNotEmpty) {
        cacheManager.add(
          CacheItem<T>(key: keyCache, value: List.from(dataSource!)),
        );
      }
    } finally {
      durationLastRequest = stopwatch.elapsed;
      _searching = false;
      notifyListeners();
    }
  }

  /// SPLIT [source] in function of [arChunk]
  List<String> splitText(String source, List<String> arChunk) {
    List<String> result = [];

    if (arChunk.isEmpty) {
      result.add(source);
      return result;
    }
    List<String> arChunkTmp = List<String>.from(arChunk)
      ..sort((a, b) => source.indexOf(a).compareTo(source.indexOf(b)));

    int start = 0;

    for (final String chunk in arChunkTmp) {
      int index = source.removeAccents().toUpperCase().indexOf(
        chunk.removeAccents().toUpperCase(),
        start,
      );

      if (index != -1) {
        result
          ..add(source.substring(start, index))
          ..add(source.substring(index, index + chunk.length));
        start = index + chunk.length;
      }
    }

    if (start < source.length && source.substring(start) != '') {
      result.add(source.substring(start));
    }

    if (result.isNotEmpty && result[0] == '') {
      result.removeAt(0);
    }

    return result;
  }

  /// return array of Text() to fill Row()
  List<InlineSpan> hightLightChunksFound(String child) {
    List<InlineSpan> results = [];
    _arCriteria ??= [];

    List<String> arTmp = splitText(child, _arCriteria!);
    _arCriteria = _arCriteria!
        .map((element) => element.removeAccents().toUpperCase())
        .toList();

    for (final element in arTmp) {
      if (_arCriteria!.contains(element.removeAccents().toUpperCase())) {
        results.add(
          TextSpan(
            text: element,
            style: itemListTextStyle.copyWith(
              backgroundColor: getBgColor(
                _arCriteria!.indexOf(element.removeAccents().toUpperCase()),
              ),
            ),
          ),
        );
      } else {
        results.add(TextSpan(text: element, style: itemListTextStyle));
      }
    }
    return results;
  }

  List<Color> colorsBackground = [
    Colors.green.shade300,
    Colors.blue.shade300,
    Colors.pink.shade200,
    Colors.brown.shade300,
    Colors.orange.shade300,
    Colors.teal.shade200,
    Colors.grey.shade400,
    Colors.lightGreen.shade500,
    Colors.cyan.shade200,
    Colors.lime.shade500,
    Colors.blueGrey.shade200,
    Colors.yellow.shade500,
  ];

  Color getBgColor(int indice) {
    return colorsBackground[indice % colorsBackground.length];
  }

  List<T> _getNearestEntries({
    required List<String> arCriteria,
    required List<T> dataSource,
  }) {
    List<T> bestFuzzySearch = [];

    SearchEntry entry = SearchEntry(
      txtValue: arCriteria.join(),
      display: "",
      sID: 'fuzzySearch',
    );

    int occu = 0;

    for (final T element in dataSource) {
      occu = 0;
      if (element._qB2.isNotEmpty) {
        occu = (entry._qB2.toSet().intersection(element._qB2.toSet())).length;
      }
      if (element._qB3.isNotEmpty) {
        occu += (entry._qB3.toSet().intersection(element._qB3.toSet())).length;
      }
      if (element._qB4.isNotEmpty) {
        occu += (entry._qB4.toSet().intersection(element._qB4.toSet())).length;
      }
      element._fuzzyOccu = occu;
      if (occu > 0) {
        element
          .._fuzzyScore =
              (occu /
              (entry._qB2.length + entry._qB3.length + entry._qB4.length))
          ..fuzzySearchResult = true;
        bestFuzzySearch.add(element);
      } else {
        element._fuzzyScore = 0;
      }
    }

    // Trier une seule fois par _fuzzyScore décroissant, puis par _fuzzyOccu décroissant
    bestFuzzySearch.sort((a, b) {
      final scoreComparison = (b._fuzzyScore ?? 0).compareTo(
        a._fuzzyScore ?? 0,
      );
      if (scoreComparison != 0) return scoreComparison;
      return (b._fuzzyOccu ?? 0).compareTo(a._fuzzyOccu ?? 0);
    });

    // Limiter aux meilleurs résultats
    if (bestFuzzySearch.length > nbBestFuzzy) {
      bestFuzzySearch = bestFuzzySearch.take(nbBestFuzzy).toList();
    }

    return bestFuzzySearch;
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && popupDisplayed == false) {
      updating = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    textControleur.dispose();
    super.dispose();
  }

  @override
  bool hasValue() {
    return value?.isNotEmpty ?? false;
  }

  @override
  void clean() {
    textControleur.clear();
    selectedItems.clear();
    updating = false;
    notifyListeners();
  }

  @override
  List<SearchEntry>? get value => displayed ? selectedItems : null;

  @override
  set value(dynamic newValue) {
    if (newValue is List) {
      selectedItems = newValue.cast<SearchEntry>().toList();
      updating = false;
      notifyListeners();
    } else {
      throw ArgumentError(
        'value must be a List<SearchEntry>, got ${newValue.runtimeType}',
      );
    }
  }

  @override
  Map<String, dynamic> get toJson {
    return {
      "name": name,
      "type": chipType.value,
      "value": displayed ? selectedItems.map((e) => e.toJson()).toList() : null,
      'displayed': displayed,
    };
  }
}

class PopupHeaderControllerItem {
  PopupHeaderControllerItem({
    required this.label,
    required this.key,
    this.checked = false,
  });
  String label; // label visible
  String key; // clé de la colonne (nom de la colonne par exemple)
  bool checked; // si la colonne est cochée par défaut
}

class SearchEntry {
  // le pourcentage de résultat occu/occu des critères
  SearchEntry({
    required this.sID,
    required String display,
    String? txtValue,
    this.hoverDescription,
  }) {
    assert(sID.isNotEmpty, "sID cannot be empty");
    _sText = txtValue ?? '';
    _sText = _sText.replaceAll(' ', '').removeAccents().toUpperCase();
    _qB2 = _quickBlock(_sText, 2);
    _qB3 = _quickBlock(_sText, 3);
    _qB4 = _quickBlock(_sText, 4);
    displaySelected = display;
  }
  factory SearchEntry.from(SearchEntry other) {
    // Cette méthode doit être surchargée par les descendants
    throw UnsupportedError(
      'from doit être surchargée dans une sous-classe de SearchEntry',
    );
  }

  // Méthode pour créer une copie de l'objet
  SearchEntry copyWith() {
    throw UnsupportedError(
      'copyWith doit être surchargée dans une sous-classe de SearchEntry',
    );
  }

  Widget displayInList(ChipTextCompletionController controller) => const Text(
    "Overide this method",
    style: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.red,
    ),
  );

  /// display value selected in the chip
  String _displaySelected = "Overide this method";
  // ignore: unnecessary_getters_setters
  String get displaySelected => _displaySelected;
  set displaySelected(String value) {
    _displaySelected = value;
  }

  String? hoverDescription;
  String _sText = "";
  String sID;
  List<String> _qB2 = [];
  List<String> _qB3 = [];
  List<String> _qB4 = [];
  bool fuzzySearchResult =
      false; // true si c'est resultat de recherche approximative, false sinon. null si pas de recherche
  int?
  _fuzzyOccu; // le nombre d'occurences trouvée, plus c'est elevé, plus c'est approchant. Sinon si non recherche approx
  double? _fuzzyScore;

  List<String> _quickBlock(String input, int n) {
    List<String> result = [];

    for (int i = 0; i < input.length - n + 1; i++) {
      result.add(input.substring(i, i + n));
    }
    return result;
  }

  Map<String, dynamic> toJson() {
    return {
      'sID': sID,
      'displayedValue': displaySelected,
      'hoverDescription': hoverDescription,
    };
  }

  void fromJson(Map<String, dynamic> json) {
    // Cette méthode doit être surchargée par les descendants
    throw UnsupportedError(
      'fromJson doit être surchargée dans une sous-classe de SearchEntry',
    );
  }

  @override
  bool operator ==(Object other) => other is SearchEntry && other.sID == sID;

  @override
  int get hashCode => sID.hashCode;

  /* @override
  String toString() =>
      'SearchEntry(sID: $sID, displaySelected: $displaySelected, fuzzySearchResult: $fuzzySearchResult)'; */

  @override
  String toString() {
    // Retourne la description si elle existe, sinon une autre valeur pertinente
    return hoverDescription ?? _sText;
  }
}

extension RemoveAccentsExtension on String {
  String removeAccents() {
    return replaceAll(RegExp(r'[àáâãäå]'), 'a')
        .replaceAll(RegExp(r'[èéêë]'), 'e')
        .replaceAll(RegExp(r'[ìíîï]'), 'i')
        .replaceAll(RegExp(r'[òóôõö]'), 'o')
        .replaceAll(RegExp(r'[ùúûü]'), 'u')
        .replaceAll(RegExp(r'[ýÿ]'), 'y')
        .replaceAll(RegExp(r'[ÀÁÂÃÄÅ]'), 'A')
        .replaceAll(RegExp(r'[ÈÉÊË]'), 'E')
        .replaceAll(RegExp(r'[ÌÍÎÏ]'), 'I')
        .replaceAll(RegExp(r'[ÒÓÔÕÖ]'), 'O')
        .replaceAll(RegExp(r'[ÙÚÛÜ]'), 'U')
        .replaceAll(RegExp(r'[Ý]'), 'Y');
  }

  bool containsAny(List<String> keywords) {
    return keywords.any((keyword) => contains(keyword));
  }

  bool containsAll(List<String> keywords) {
    return keywords.every((keyword) => contains(keyword));
  }
}
