import 'dart:convert';

import 'package:criteria/chips/chip_text_completion.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ChipType {
  undefined(0),
  text(10),
  textCompletion(20),
  numRange(30),
  datesRange(40),
  date(50),
  boolean(60);

  const ChipType(this.value);
  final int value;

  static ChipType? fromValue(int value) {
    return ChipType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ChipType.undefined,
    );
  }
}

double avatarSize = 24;
double chipHeightSize = 40;

abstract class ChipItemController with ChangeNotifier {
  ChipItemController({
    required this.chipType,
    required this.avatar,
    required this.name,
    required this.group,
    this.label = '',
    Function()? onEnter,
  }) : _onEnter = onEnter;

  Function()? _onEnter;
  Function()? parentOnEnter;

  Function()? get onEnter {
    if (parentOnEnter != null) {
      return () {
        _onEnter?.call();
        parentOnEnter!.call();
      };
    }
    return _onEnter;
  }

  set onEnter(Function()? value) {
    _onEnter = value;
  }

  ChipGroup group;

  bool _displayed = false;
  bool get displayed => alwaysDisplayed ? true : _displayed;
  set displayed(bool value) {
    if (value != _displayed) {
      _displayed = value;
      notifyListeners();
    }
  }

  bool alwaysDisplayed = false;

  String name;

  ChipType chipType;

  /// Whether the chip can be removed/erased
  bool displayRemoveButton = true;

  // for backward compatibility
  @Deprecated(
    'Use displayRemoveButton instead. erasable is obsolete and will be removed in a future release.',
  )
  bool get erasable {
    // Inform developers at runtime that this member is obsolete
    // Keep the getter behavior for backward compatibility
    debugPrint(
      '[DEPRECATED] ChipItemController.erasable is obsolete — use displayRemoveButton instead.',
    );
    return displayRemoveButton;
  }

  @Deprecated(
    'Use displayRemoveButton instead. erasable is obsolete and will be removed in a future release.',
  )
  set erasable(bool value) {
    debugPrint(
      '[DEPRECATED] ChipItemController.erasable (setter) is obsolete — set displayRemoveButton instead.',
    );
    displayRemoveButton = value;
  }

  int order = 0;

  Color backgroundColor = Colors.grey.shade50;
  Color backgroundColorAlt = Colors.grey.shade200;
  Color hoverColor = Colors.yellow;
  String? groupName;
  String? comments;

  String tooltipMessageErase = "Effacer";
  String tooltipMessageRemove = "Supprimer";

  Widget? avatar;
  bool hideAvatar = false;

  bool disable = false;

  TextStyle labelStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Colors.grey.shade600,
  );
  TextStyle emptyLabelStyle = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.italic,
  );
  TextStyle altTextStyle = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
  TextStyle itemListTextStyle = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );

  String label;
  bool hideLabelIfNotEmpty = false;

  Widget? popupHelper;

  bool _updating = false;
  bool get updating => _updating;
  set updating(bool value) {
    if (value != _updating) {
      _updating = value;
      notifyListeners();
    }
  }

  bool _popupDisplayed = false;
  bool get popupDisplayed => _popupDisplayed;
  set popupDisplayed(bool value) {
    if (value != _popupDisplayed) {
      _popupDisplayed = value;
      notifyListeners();
    }
  }

  bool hasValue();
  void clean();
  dynamic get value;
  set value(dynamic newValue);

  Map<String, dynamic> get toJson;

  bool fromJson(List<Map<String, dynamic>> jsonList) {
    final Map<String, Map<String, dynamic>> mappedByName = {
      for (final item in jsonList) item['name']: item,
    };
    if (mappedByName[name] == null) {
      return false;
    }
    chipType =
        ChipType.fromValue(mappedByName[name]?['type']) ??
        ChipType.undefined; // Default to text if type is not found
    displayed = mappedByName[name]?['displayed'];
    switch (chipType) {
      case ChipType.textCompletion:
        value = (mappedByName[name]?['value'] as List<dynamic>)
            .map(
              (e) => SearchEntry(
                display: e['displayedValue'] ?? '',
                sID: e['sID'] ?? '',
                hoverDescription: e['hoverDescription'] ?? '',
              ),
            )
            .toList();
        break;

      default:
        value = mappedByName[name]?['value'];
        break;
    }

    updating = false;
    return true;
  }

  GlobalKey? key_; // for internal use only

  void notify() {
    notifyListeners(); // to force update from outside
  }
}

class ChipGroup {
  ChipGroup({required this.name, this.labelText, this.labelWidget}) {
    assert(
      (labelText != null && labelWidget == null) ||
          (labelText == null && labelWidget != null),
      "usee labelText OR child ",
    );
  }

  factory ChipGroup.none() {
    return ChipGroup(name: "none", labelText: "none");
  }
  String name;
  int order = 0;
  Widget? labelWidget;
  String? labelText;
  Color backgroundColor = Colors.amber.shade100;
  TextStyle labelStyle = const TextStyle(
    color: Colors.white,
    fontStyle: FontStyle.italic,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
  double? height_; // for internal use only
}

class ChipsController with ChipsPoupAttributs, ChangeNotifier {
  ChipsController({
    required this.name,
    double avatarSize = 24,
    String? addCriteriaTooltip,
    Function()? onEnter,
  }) : _onEnter = onEnter {
    if (addCriteriaTooltip != null) {
      addCriteriaTooltipMessage = addCriteriaTooltip;
    }
    avatarSize = avatarSize;
  }

  Function()? _onEnter;
  Function()? get onEnter => _onEnter;
  set onEnter(Function()? value) {
    _onEnter = value;
    for (final chip in _chips) {
      chip.parentOnEnter = value;
    }
  }

  String name;

  List<Map<String, dynamic>>? lastChipsJson;

  List<ChipItemController> _chips = [];

  /// Tooltip message used for the "add criteria" button (customizable)
  String addCriteriaTooltipMessage = 'Ajouter des critères';

  List<ChipItemController> get chips => _chips;

  set chips(List<ChipItemController> newChips) {
    Map<String, int> map = {};
    _chips = newChips;
    for (final chip in chips) {
      chip.addListener(notifyListeners);
      chip.parentOnEnter = onEnter;
      assert(map[chip.name] == null, "Duplicate chip name: ${chip.name}");
      map[chip.name] = map[chip.name] ?? 0 + 1;
    }
    notifyListeners();
  }

  Color backgroundColor = Colors.white;
  Color backgroundColorAlt = Colors.grey.shade200;

  ChipItemController? getChipByName(String name) {
    try {
      return chips.firstWhere((chip) => chip.name == name);
    } catch (e) {
      return null;
    }
  }

  /// hide or show remove button on all chips
  set displayAllRemoveButton(bool value) {
    for (final chip in chips) {
      chip.displayRemoveButton = value;
    }
    notifyListeners();
  }

  bool get isUpdated {
    List<Map<String, dynamic>>? tmpJson;
    bool result = false;
    if (lastChipsJson == null) {
      return true;
    }

    try {
      tmpJson = _toJson();
    } catch (e) {
      tmpJson = null;
    }

    if (tmpJson == null || tmpJson.length != lastChipsJson?.length) {
      return true;
    }
    try {
      result = jsonEncode(tmpJson) != jsonEncode(lastChipsJson);
      lastChipsJson = List.from(tmpJson);
    } catch (e) {
      result = false;
    }
    return result;
  }

  List<Map<String, dynamic>> _toJson() {
    List<Map<String, dynamic>> jsonList = [];
    for (final chip in chips) {
      jsonList.add(chip.toJson);
    }
    return jsonList;
  }

  List<Map<String, dynamic>> toJson() {
    if (lastChipsJson != null) {
      return lastChipsJson!;
    }
    lastChipsJson = _toJson();
    return lastChipsJson!;
  }

  List<Map<String, dynamic>> get value => toJson();

  /// true on success
  bool fromJson(List<Map<String, dynamic>> jsonList) {
    try {
      final Map<String, Map<String, dynamic>> mappedByName = {
        for (final item in jsonList) item['name']: item,
      };
      for (final ChipItemController chip in chips) {
        if (chip.name == mappedByName[chip.name]?['name']) {
          chip.fromJson(jsonList);
        }
      }
      return true;
    } catch (e) {
      debugPrint("Erreur fromJson: $e");
      return false;
    }
  }

  Future<void> loadCriteria({String? withKey, String? fromJsonString}) async {
    List<Map<String, dynamic>>? jsonMap;
    assert(
      withKey == null || fromJsonString == null,
      "use only one of withKey or fromJsonString",
    );
    if (fromJsonString == null) {
      {
        withKey ??= "_default_";
        String sKey = '$name|$withKey';

        final prefs = await SharedPreferences.getInstance();
        fromJsonString = prefs.getString(sKey);
      }
    }

    if (fromJsonString != null) {
      try {
        jsonMap = List<Map<String, dynamic>>.from(jsonDecode(fromJsonString));
        fromJson(jsonMap);
        debugPrint("Critères chargés: $jsonMap");
      } catch (e) {
        debugPrint("Erreur de json: $e");
        return;
      }
    }
  }

  // Sauvegarde des critères dans SharedPreferences
  Future<void> saveCriteria([String? subKey]) async {
    if (!isUpdated) {
      return;
    }
    subKey ??= "_default_";
    String sKey = '$name|$subKey';
    try {
      final prefs = await SharedPreferences.getInstance();
      String jsonData = jsonEncode(toJson());
      await prefs.setString(sKey, jsonData);
      // Feedback visuel ou sonore peut être ajouté ici
      debugPrint("Critères sauvegardés : $jsonData");
    } catch (e) {
      debugPrint("Erreur lors de la sauvegarde des critères: $e");
    }
  }

  /// Clear all chips
  void clear() {
    for (final element in _chips) {
      element.clean();
    }
    notifyListeners();
  }
}

mixin ChipsPoupAttributs {
  double popupXoffset = 0;
  double popupInitWidth = 200;
  double popupInitHeight = 500;
  double popupMinWidth = 150;
  double popupMinHeight = 200;
  double popupMaxWidth = 1000;
  double popupMaxHeight = 1000;
  double? chipX;
  double? chipY;
  double? chipWidth;
  double? chipHeight;
}

mixin ChipsAssets {
  double iconSize = 20;

  Widget get deleteIcon => Tooltip(
    message: "Supprimer",
    child: Icon(Icons.recycling, color: Colors.orange, size: iconSize),
  );
  Widget get eraseIcon => Tooltip(
    message: "Effacer",
    child: Icon(Icons.recycling, color: Colors.grey, size: iconSize),
  );

  Widget tailIcons(
    ChipItemController controller, {
    Function()? onErase,
    Function()? onDelete,
  }) {
    if (onErase == null || onDelete == null) {
      if (controller.hasValue()) {
        return eraseIcon;
      } else {
        if (!controller.alwaysDisplayed) {
          return deleteIcon;
        } else {
          return SizedBox(width: iconSize, height: iconSize);
        }
      }
    }
    if (controller.hasValue()) {
      return IconButton(
        icon: eraseIcon,
        tooltip: controller.tooltipMessageErase,
        onPressed: onErase,
        constraints: const BoxConstraints(),
      );
    } else {
      if (!controller.alwaysDisplayed && controller.displayRemoveButton) {
        return IconButton(
          icon: deleteIcon,
          tooltip: controller.tooltipMessageRemove,
          onPressed: onDelete,
          constraints: const BoxConstraints(),
        );
      }
    }
    return const SizedBox.shrink();
  }
}
