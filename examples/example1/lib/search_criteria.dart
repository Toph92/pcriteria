import 'package:criteria/chips/chips.dart';
import 'package:flutter/material.dart';
import 'package:toolbox/toolbox.dart'; // here is the barrel export
import 'data.dart';

/// Global controller for search criteria
ChipsController? searchCriteriaController;

/// Search criteria configuration
void initializeSearchCriteria() {
  // Single group for our 3 criteria
  final searchGroup = ChipGroup(name: "search", labelText: "Search Criteria")
    ..backgroundColor = Colors.blue.shade500;

  searchCriteriaController = ChipsController(name: "example1_search")
    ..chips = [
      // 1. Client criterion - Autocomplete
      ChipTextCompletionController<User>(
          name: "client",
          group: searchGroup,
          // label: "Client", // now optional
          onRequestUpdateDataSource:
              (
                List<String>? criteria,
                List<PopupHeaderControllerItem>? popupHeaderItems,
                Map<SearchOptionKey, dynamic> searchOptions,
              ) async {
                // Local filtering on our static list
                if (criteria == null || criteria.isEmpty) {
                  return (staticUsers, null);
                }

                final searchTerm = criteria.first.toLowerCase();
                final filteredUsers = staticUsers.where((user) {
                  final fullName = "${user.lastName} ${user.firstName ?? ''}"
                      .toLowerCase();
                  return fullName.contains(searchTerm) ||
                      user.initials.toLowerCase().contains(searchTerm);
                }).toList();

                return (filteredUsers, null);
              },
        )
        ..fuzzySearchStep = 1
        ..maxResults = 20
        ..alwaysDisplayed = false
        ..displayRemoveButton = false
        ..comments = "Client selection by autocomplete"
        ..avatar = const Icon(Icons.person, color: Colors.blue, size: 24)
        ..popupHeaderItems = [
          PopupHeaderControllerItem(
            key: 'last',
            label: "Last Name",
            checked: true,
          ),
          PopupHeaderControllerItem(
            key: 'first',
            label: "First Name",
            checked: true,
          ),
        ]
        ..keepPopupOpen = true
        ..maxEntries = 3,

      // 2. Date of birth criterion - Date range
      ChipDatesRangeController(
          name: "birthdate",
          group: searchGroup,
          label: "Date of Birth",
        )
        ..alwaysDisplayed = false
        ..comments = "Selection of a date of birth range"
        ..avatar = const Icon(Icons.cake, color: Colors.orange, size: 24),

      // 3. Country criterion - List with flags
      ChipListController(name: "country", group: searchGroup, label: "Country")
        ..alwaysDisplayed = false
        ..comments = "Selection of one or more countries"
        ..dataset = countries
        ..toolTipMessage = "Select one or more countries"
        ..avatar = const Icon(Icons.flag, size: 24)
        ..hideAvatar = false
        ..gridAlign = Alignment.center
        ..gridCols = 2
        ..gridAspectRatio = 2.5
        ..displayMode = ChipListDisplayMode.fullDescription
        ..displayModeHoverPopup = ChipListDisplayMode.icon
        ..multiSelect = true
        ..quitOnSelect = false
        ..displayModeStepQty = 5
        ..popupXoffset = 0.0,
      ChipTextController(name: "code", group: searchGroup, label: "Code")
        ..onPopupPressed = (BuildContext context, {dynamic other}) async {
          await DialogBuilder(
            context: context,
            message: 'Clic done !',
            dimissible: false,
          ).ok();
          searchCriteriaController?.getChipByName("code")?.value =
              "Clic done !";
        }
        ..popupIcon = const Icon(Icons.search),

      // 5. Boolean criterion
      ChipBooleanController(
          name: "is_active",
          group: searchGroup,
          label: "Active User",
        )
        ..value = false
        ..avatar = const Icon(Icons.check_circle_outline, size: 24),

      // 6. Single Date criterion
      ChipDateController(
        name: "single_date",
        group: searchGroup,
        label: "Specific Date",
      )..avatar = const Icon(Icons.calendar_today, size: 24),

      // 7. Number Range criterion
      ChipRangeController(
          name: "age_range",
          group: searchGroup,
          label: "Age Range",
        )
        ..labelMin = "Min Age"
        ..labelMax = "Max Age"
        ..avatar = const Icon(Icons.numbers, size: 24),

      //..displayRemoveButton = false,
    ]
    ..addCriteriaTooltipMessage = "Add Search Criteria"
    ..onEnter = () {
      debugPrint("Enter pressed on ChipsController!");
    }
    ..loadCriteria();
}

/// Function to get current criteria values
Map<String, dynamic> getCurrentCriteriaValues() {
  if (searchCriteriaController == null) return {};

  final values = <String, dynamic>{};

  for (final chip in searchCriteriaController!.chips) {
    switch (chip.name) {
      case "client":
        if (chip is ChipTextCompletionController<User>) {
          values["client"] = chip.value;
        }
        break;
      case "birthdate":
        if (chip is ChipDatesRangeController) {
          values["birthdate"] = chip.value;
        }
        break;
      case "country":
        if (chip is ChipListController) {
          values["country"] = chip.value;
        }
        break;
      case "code":
        if (chip is ChipTextController) {
          values["code"] = chip.value;
        }
        break;
      case "is_active":
        if (chip is ChipBooleanController) {
          values["is_active"] = chip.value;
        }
        break;
      case "single_date":
        if (chip is ChipDateController) {
          values["single_date"] = chip.value;
        }
        break;
      case "age_range":
        if (chip is ChipRangeController) {
          values["age_range"] = chip.value;
        }
        break;
    }
  }

  return values;
}

/// Function to display selected values (for debugging)
String getSearchSummary() {
  final values = getCurrentCriteriaValues();
  final summary = StringBuffer();

  summary.writeln("=== Selected Search Criteria ===");

  // Client
  final clientValue = values["client"];
  if (clientValue != null && clientValue.isNotEmpty) {
    summary.writeln(
      "Client: ${clientValue.map((u) => "${u.lastName} ${u.firstName}").join(", ")}",
    );
  } else {
    summary.writeln("Client: None");
  }

  // Date of birth
  final birthdateValue = values["birthdate"];
  if (birthdateValue != null) {
    summary.writeln(
      "Date of Birth: From ${birthdateValue.start?.toString().split(' ')[0] ?? 'Not defined'} to ${birthdateValue.end?.toString().split(' ')[0] ?? 'Not defined'}",
    );
  } else {
    summary.writeln("Date of Birth: None");
  }

  // Country
  final countryValue = values["country"];
  if (countryValue != null && countryValue.isNotEmpty) {
    final countryNames = countryValue
        .map((ChipListItem item) {
          final country = countries.firstWhere(
            (c) => c.id == item.id,
            orElse: () => ChipListItem(text: "Unknown", id: ""),
          );
          return country.text;
        })
        .join(", ");
    summary.writeln("Country: $countryNames");
  } else {
    summary.writeln("Country: None");
  }

  // Code
  final codeValue = values["code"];
  if (codeValue != null && codeValue.isNotEmpty) {
    summary.writeln("Code: $codeValue");
  } else {
    summary.writeln("Code: None");
  }

  // Active User
  final isActiveValue = values["is_active"];
  if (isActiveValue != null) {
    summary.writeln("Active User: $isActiveValue");
  } else {
    summary.writeln("Active User: None");
  }

  // Single Date
  final singleDateValue = values["single_date"];
  if (singleDateValue != null) {
    summary.writeln(
      "Specific Date: ${singleDateValue.toString().split(' ')[0]}",
    );
  } else {
    summary.writeln("Specific Date: None");
  }

  // Age Range
  final ageRangeValue = values["age_range"];
  if (ageRangeValue != null) {
    summary.writeln("Age Range: ${ageRangeValue.start} - ${ageRangeValue.end}");
  } else {
    summary.writeln("Age Range: None");
  }

  return summary.toString();
}
