import 'dart:convert';

import 'package:country_flags/country_flags.dart';
import 'package:crc32_checksum/crc32_checksum.dart';
import 'package:criteria/chips/chips.dart';
import 'package:criteria/credentials.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

ChipGroup? gr1, gr2, gr3;
ChipsController? chipsListControllers;

mixin class CommonPages {
  void fillChipsMenu() {
    gr1 = ChipGroup(name: "G1", labelText: "Civilité")
      ..backgroundColor = Colors.blueGrey.shade500;

    gr2 = ChipGroup(name: "G2", labelText: "Lieu de résidence")
      ..backgroundColor = Colors.orange.shade500;
    gr3 = ChipGroup(name: "G3", labelText: "Habitation")
      ..backgroundColor = Colors.green.shade500;

    chipsListControllers = ChipsController(name: "test1")
      ..chips = [
        ChipTextController(name: "compagny", group: gr1!, label: "Société")
          ..comments = "Raison sociale de la société"
          ..avatar = const Icon(Icons.home, color: Colors.blue, size: 24)
          ..labelStyle = const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
        ChipTextCompletionController<User>(
            name: "client",
            group: gr1!,
            label: "Client",
            onRequestUpdateDataSource:
                (
                  List<String>? arCriteria,
                  List<PopupHeaderControllerItem>? popupHeaderItems,
                  Map<SearchOptionKey, dynamic> searchOptions,
                ) async {
                  try {
                    // Construire les paramètres de recherche
                    Map<String, dynamic> searchParams = {};

                    searchParams['criteria'] = arCriteria;

                    // Ajouter les filtres actifs
                    if (popupHeaderItems != null) {
                      List<String> activeFilters = popupHeaderItems
                          .where((item) => item.value)
                          .map((item) => item.key)
                          .toList();
                      if (activeFilters.isNotEmpty) {
                        searchParams['filters'] = activeFilters;
                      }
                      searchParams['searchOptions'] = jsonEncode(
                        searchOptions.map(
                          (key, value) => MapEntry(key.toString(), value),
                        ),
                      );
                    }

                    // Appel HTTP au backend avec authentification Basic
                    //final uri = Uri.parse('http://iSrv1:2881/api/users/search');
                    final uri = Uri.parse(
                      'http://109.24.210.55/apicriteria/api/users/search',
                    );

                    // Authentification Basic (login/password)
                    String username = Credentials.username;
                    String password = Credentials.password;
                    String basicAuth =
                        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

                    final response = await http
                        .post(
                          uri,
                          headers: {
                            'Content-Type': 'application/json',
                            'Accept': 'application/json',
                            'Authorization': basicAuth,
                          },
                          body: json.encode(searchParams),
                        )
                        .timeout(const Duration(seconds: 5));

                    if (response.statusCode == 200) {
                      Map<String, dynamic> jsonTmp = json.decode(response.body);
                      final List<dynamic> jsonData =
                          jsonTmp['data'] as List<dynamic>;
                      return (
                        jsonData
                            .map(
                              (userData) => User(
                                sID: userData['i'] ?? '',
                                firstName: userData['p'],
                                lastName: userData['n'] ?? '',
                              ),
                            )
                            .toList(),
                        jsonTmp['meta'] as Map<String, dynamic>?,
                      );
                    } else {
                      debugPrint(
                        'Erreur HTTP: ${response.statusCode} - ${response.body}',
                      );
                      return (null, null);
                    }
                  } catch (e) {
                    debugPrint(
                      'Erreur lors de la récupération des utilisateurs: $e',
                    );
                    return (null, null);
                  }
                },
          )
          ..fuzzySearchStep = 1
          ..maxResults = 500
          ..alwaysDisplayed = true
          ..comments = "Autocompletion de clients"
          ..avatar = const Icon(Icons.person, color: Colors.pink, size: 24)
          ..popupHeaderItems = [
            PopupHeaderControllerItem(key: 'id', label: "Code"),
            PopupHeaderControllerItem(
              key: 'first',
              label: "Prénoms",
              value: true,
            ),
            PopupHeaderControllerItem(key: 'last', label: "Nom", value: true),
          ]
          ..keepPopupOpen = true
          ..maxEntries = 3,
        ChipRangeController(name: "age2", group: gr1!, label: "Age")
          ..minMaxRange = const RangeValues(1, 120)
          ..comments = "Recherche par tranche d'âge"
          ..labelMin = "Min (1)"
          ..labelMax = "Max (120)"
          //..unitWidget = Icon(Icons.euro, color: Colors.blue, size: 16)
          ..unitWidget = const Padding(
            padding: EdgeInsets.only(left: 4.0),
            child: Text(
              "Ans",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          )
          ..hideLabelIfNotEmpty =
              false // TODO utile ?
          ..popupHelper = const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 20),
                Text('En années', style: TextStyle(fontSize: 12)),
              ],
            ),
          )
          ..alwaysDisplayed = false,
        ChipDatesRangeController(
            name: "birthdate",
            group: gr1!,
            label: "Date de naissance",
          )
          ..alwaysDisplayed = false
          ..comments = "Exemple intervalle de dates",

        ChipBooleanController(name: "dcd", group: gr1!, label: "Décédé")
          ..displayRemoveButton = false,

        ChipBooleanController(name: "married", group: gr1!, label: "Marié")
          ..avatar = const Icon(
            Icons.volunteer_activism,
            color: Colors.pink,
            size: 24,
          )
          ..disable = true,
        ChipListController(name: "gender", group: gr1!, label: "Genre")
          ..comments = "Genre"
          ..dataset = genders
          ..toolTipMessage = "Sélectionnez un genre"
          ..avatar = const Icon(Icons.wc, size: 24)
          ..gridAlign = Alignment.center
          ..gridCols = 2
          ..gridAspectRatio = 2
          ..displayMode = ChipListDisplayMode.iconAndShortDescription
          ..displayModeHoverPopup = ChipListDisplayMode.iconAndShortDescription
          ..multiSelect = false
          ..quitOnSelect = true
          ..displayModeStepQty = 10
          ..popupXoffset = 0.0
          ..alwaysDisplayed = false,

        ChipTextController(name: "city", group: gr2!, label: "Ville")
          ..comments = "Ville de résidence"
          ..avatar = const Icon(
            Icons.location_city,
            color: Colors.blue,
            size: 24,
          )
          ..labelStyle = const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.green,
          ),
        ChipListController(name: "country", group: gr2!, label: "Pays")
          //..alwaysDisplayed = true
          ..comments = "Pays de résidence"
          ..dataset = items
          ..toolTipMessage = "Sélectionnez un pays"
          ..avatar = const Icon(Icons.flag, size: 24)
          ..hideAvatar = false
          ..gridAlign = Alignment.center
          ..gridCols = 2
          ..gridAspectRatio = 2
          ..displayMode = ChipListDisplayMode.iconAndShortDescription
          ..displayModeHoverPopup = ChipListDisplayMode.iconAndShortDescription
          ..multiSelect = true
          ..quitOnSelect = false
          ..displayModeStepQty = 4
          ..popupXoffset = 0.0
          ..alwaysDisplayed = false,

        ChipListController(
            name: "citySize",
            group: gr2!,
            label: "Taille de la ville",
          )
          ..comments = "Taille de la ville"
          ..dataset = citySize
          ..toolTipMessage = "Sélectionnez une taille de ville"
          ..avatar = const Icon(Icons.diversity_3, size: 24)
          ..gridAlign = Alignment.centerLeft
          ..gridCols = 2
          ..gridAspectRatio = 2
          ..displayMode = ChipListDisplayMode.iconAndShortDescription
          ..displayModeHoverPopup = ChipListDisplayMode.iconAndShortDescription
          ..multiSelect = true
          ..quitOnSelect = false
          ..displayModeStepQty = 3
          ..popupXoffset = 0.0,

        ChipDateController(
          name: "constructDate",
          group: gr3!,
          label: "Construction après",
        )..comments = "Exemple d'une date",

        ChipListController(
            name: "house",
            group: gr3!,
            label: "Type d'habitation",
          )
          ..dataset = houseType
          ..toolTipMessage = "Appartement ou maison"
          ..comments = "Exemple d'une liste à choix unique"
          ..avatar = const Icon(Icons.home, size: 24)
          ..gridAlign = Alignment.center
          ..gridCols = 2
          ..gridAspectRatio = 1
          ..displayMode = ChipListDisplayMode.iconAndShortDescription
          ..displayModeHoverPopup = ChipListDisplayMode.iconAndShortDescription
          ..multiSelect = true
          ..quitOnSelect = false
          ..displayModeStepQty = 3
          ..multiSelect = false
          ..quitOnSelect = true
          ..popupXoffset = 0.0,

        ChipRangeController(name: "prixAchat", group: gr3!, label: "Prix achat")
          //..minMaxRange = const RangeValues(0, 10000)
          ..comments = "Prix achat résidence H.T. en k€"
          ..labelMin = "Min en k€"
          ..labelMax = "Max en k€"
          ..avatar = const Icon(Icons.euro, color: Colors.blue, size: 24)
          ..unitWidget = const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Text(
              "k€",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
            ),
          )
          //..hideLabelIfNotEmpty = fal
          ..popupHelper = const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 20,
                ),
                Text(
                  'Saisie en k€',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ChipListController(name: "dpe", group: gr3!, label: "DPE")
          ..comments = "Un exemple de liste à choix multiple"
          ..dataset = dpe
          ..avatar = SvgPicture.asset(
            'assets/images/dpe_logo.svg',
            width: 22,
            height: 22,
          )
          ..gridAlign = Alignment.centerLeft
          ..gridCols = 1
          ..gridAspectRatio = 4
          ..displayMode = ChipListDisplayMode.icon
          ..displayModeHoverPopup = ChipListDisplayMode.iconAndDescription
          ..multiSelect = true
          ..quitOnSelect = false
          ..displayModeStepQty = 5
          ..popupXoffset = 0.0
          ..hideLabelIfNotEmpty = false,
      ]
      ..loadCriteria();
  }

  Widget headerPage(dynamic title, [Widget right = const SizedBox()]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Material(
        elevation: 4,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueGrey.shade900, Colors.blueGrey.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(children: [title, const Spacer(), right]),
          ),
        ),
      ),
    );
  }

  TextStyle titleStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Colors.grey.shade300,
  );

  Widget dropDownLoadProfiles({Function()? onUpdate}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Icon(Icons.file_open_outlined, color: Colors.black),
        const SizedBox(width: 8),
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            hint: const Text("Charger un profil de recherche"),
            isDense: true,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.blueGrey),
            items: [
              const DropdownMenuItem(
                value:
                    '[{"name":"compagny","type":10,"value":"","displayed":true},{"name":"client","type":20,"value":[],"displayed":true},{"name":"age2","type":30,"value":null,"displayed":true},{"name":"birthdate","type":40,"value":null,"displayed":false},{"name":"dcd","type":60,"value":false,"displayed":true},{"name":"married","type":60,"value":false,"displayed":true},{"name":"gender","type":10,"value":[],"displayed":true},{"name":"city","type":10,"value":"","displayed":false},{"name":"country","type":10,"value":[],"displayed":true},{"name":"citySize","type":10,"value":[],"displayed":true},{"name":"constructDate","type":50,"value":null,"displayed":false},{"name":"house","type":10,"value":[],"displayed":false},{"name":"prixAchat","type":30,"value":null,"displayed":true},{"name":"dpe","type":10,"value":[],"displayed":true}]',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 16, color: Colors.blueGrey),
                    SizedBox(width: 4),
                    Text("Critères sans valeurs"),
                  ],
                ),
              ),
              const DropdownMenuItem(
                value:
                    ' [{"name":"compagny","type":10,"value":"ACE compagny","displayed":true},{"name":"client","type":20,"value":[{"sID":"2039117198","displayedValue":"LE","hoverDescription":"LEMOINE Ethan"},{"sID":"1415346159","displayedValue":"DF","hoverDescription":"DEBUS Fabrice"}],"displayed":true},{"name":"age2","type":30,"value":{"start":18.0,"end":62.0},"displayed":true},{"name":"birthdate","type":40,"value":null,"displayed":false},{"name":"dcd","type":60,"value":false,"displayed":true},{"name":"married","type":60,"value":false,"displayed":false},{"name":"gender","type":10,"value":["3"],"displayed":true},{"name":"city","type":10,"value":"","displayed":false},{"name":"country","type":10,"value":["1","2"],"displayed":true},{"name":"citySize","type":10,"value":[],"displayed":false},{"name":"constructDate","type":50,"value":null,"displayed":false},{"name":"house","type":10,"value":[],"displayed":false},{"name":"prixAchat","type":30,"value":null,"displayed":false},{"name":"dpe","type":10,"value":["1","3","6","2"],"displayed":true}]',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 16, color: Colors.blueGrey),
                    SizedBox(width: 4),
                    Text("Critères avec valeurs"),
                  ],
                ),
              ),
              const DropdownMenuItem(
                value:
                    '[{"name":"compagny","type":10,"value":"","displayed":true},{"name":"client","type":20,"value":[],"displayed":true},{"name":"age2","type":30,"value":null,"displayed":true},{"name":"birthdate","type":40,"value":null,"displayed":false},{"name":"dcd","type":60,"value":true,"displayed":true},{"name":"married","type":60,"value":false,"displayed":false},{"name":"gender","type":10,"value":["1"],"displayed":true},{"name":"city","type":10,"value":"","displayed":false},{"name":"country","type":10,"value":[],"displayed":true},{"name":"citySize","type":10,"value":[],"displayed":false},{"name":"constructDate","type":50,"value":null,"displayed":false},{"name":"house","type":10,"value":[],"displayed":false},{"name":"prixAchat","type":30,"value":null,"displayed":false},{"name":"dpe","type":10,"value":[],"displayed":false}]',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 16, color: Colors.blueGrey),
                    SizedBox(width: 4),
                    Text("Autre profil"),
                  ],
                ),
              ),
            ],
            onChanged: (value) {
              chipsListControllers?.loadCriteria(fromJsonString: value);
              onUpdate?.call();
            },
          ),
        ),
      ],
    );
  }
}

List<ChipListItem> genders = [
  ChipListItem(
    text: 'Homme',
    id: '1',
    shortText: 'H',
    comments: "C'est un homme",
    leading: const Icon(Icons.male, color: Colors.blue),
  ),
  ChipListItem(
    text: 'Femme',
    id: '2',
    shortText: 'F',
    comments: "C'est une femme",
    leading: const Icon(Icons.female, color: Colors.pink),
  ),
  ChipListItem(
    text: 'Non défini',
    id: '3',
    shortText: '?',
    comments: "On ne sait pas trop",
    leading: Icon(Icons.transgender, color: Colors.pink.shade200),
  ),
];

List<ChipListItem> citySize = [
  ChipListItem(
    text: '< 1000 habitants',
    id: '1',
    shortText: '< 1k',
    comments: "Un gros village",
    leading: const Icon(Icons.location_city, color: Colors.black12),
  ),
  ChipListItem(
    text: '1000 - 10000 habitants',
    id: '2',
    shortText: '1 - 10K',
    comments: "Une petite ville",
    leading: const Icon(Icons.location_city, color: Colors.black26),
  ),
  ChipListItem(
    text: '10000 - 100000 habitants',
    id: '3',
    shortText: '10 - 100K',
    comments: "Une ville moyenne",
    leading: const Icon(Icons.location_city, color: Colors.black38),
  ),
  ChipListItem(
    text: '100000 - 1000000 habitants',
    id: '4',
    shortText: '100K - 1M',
    comments: "Une grande ville",
    leading: const Icon(Icons.location_city, color: Colors.black54),
  ),
  ChipListItem(
    text: '> 1000000 habitants',
    id: '5',
    shortText: '> 1M',
    comments: "Une très grande ville",
    leading: const Icon(Icons.location_city, color: Colors.black),
  ),
];

List<ChipListItem> items = [
  ChipListItem(
    text: 'France',
    id: '1',
    shortText: 'FR',
    comments: "65 millions",
    leading: CountryFlags.flag('FR', height: 20, width: 30),
  ),
  ChipListItem(
    text: 'Allemagne',
    id: '2',
    shortText: 'DE',
    comments: "80 millions",
    leading: CountryFlags.flag('DE', height: 20, width: 30),
  ),
  ChipListItem(
    text: 'Belgique',
    id: '3',
    shortText: 'BE',
    comments: "11 millions",
    leading: CountryFlags.flag('BE', height: 20, width: 30),
  ),
  ChipListItem(
    text: 'Suisse',
    id: '4',
    shortText: 'CH',
    comments: "8 millions",
    leading: CountryFlags.flag('CH', height: 20, width: 30),
  ),
  ChipListItem(
    text: 'Luxembourg',
    id: '5',
    shortText: 'LU',
    comments: "1 million",
    leading: CountryFlags.flag('LU', height: 20, width: 30),
  ),
  ChipListItem(
    text: 'Espagne',
    id: '6',
    shortText: 'ES',
    comments: "47 millions",
    leading: CountryFlags.flag('ES', height: 20, width: 30),
  ),
  ChipListItem(
    text: 'Italie',
    id: '7',
    shortText: 'IT',
    comments: "60 millions",
    leading: CountryFlags.flag('IT', height: 20, width: 30),
  ),
  ChipListItem(
    text: 'Portugal',
    id: '8',
    shortText: 'PT',
    comments: "10 millions",
    leading: CountryFlags.flag('PT', height: 20, width: 30),
  ),
  ChipListItem(
    text: 'Pays-Bas',
    id: '9',
    shortText: 'NL',
    comments: "17 millions",
    leading: CountryFlags.flag('NL', height: 20, width: 30),
  ),
  ChipListItem(
    text: 'Danemark',
    id: '10',
    shortText: 'DK',
    comments: "6 millions",
    leading: CountryFlags.flag('DK', height: 20, width: 30),
  ),
  ChipListItem(text: 'Suède', id: '11', shortText: 'SE'),
  ChipListItem(
    text: 'Finlande',
    id: '12',
    shortText: 'FI',
    comments: "5 millions",
    leading: CountryFlags.flag('FI', height: 20, width: 30),
  ),
  ChipListItem(
    text: 'Norvège',
    id: '13',
    shortText: 'NO',
    comments: "5 millions",
    leading: CountryFlags.flag('NO', height: 20, width: 30),
  ),
];

List<ChipListItem> houseType = [
  ChipListItem(
    text: 'Appartement',
    id: '1',
    shortText: 'Appartement',
    comments: "Résidence collective",
    leading: const Icon(Icons.apartment, color: Colors.blue),
  ),
  ChipListItem(
    text: 'Maison',
    id: '2',
    shortText: 'Maison',
    comments: "Résidence individuelle",
    leading: const Icon(Icons.house, color: Colors.blue),
  ),
];

List<ChipListItem> dpe = [
  ChipListItem(
    text: '<70 kWh/m²/an',
    id: '1',
    shortText: 'A',
    leading: Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: CircleAvatar(
        radius: 12,
        backgroundColor: Colors.green.shade900,
        child: const Text(
          'A',
          style: TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  ),
  ChipListItem(
    text: '71 - 110 kWh/m²/an',
    id: '2',
    shortText: 'B',
    leading: Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: CircleAvatar(
        radius: 12,
        backgroundColor: Colors.green.shade700,
        child: const Text(
          'B',
          style: TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  ),
  ChipListItem(
    text: '111 - 180 kWh/m²/an',
    id: '3',
    shortText: 'C',
    leading: Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: CircleAvatar(
        radius: 12,
        backgroundColor: Colors.green.shade500,
        child: const Text(
          'C',
          style: TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  ),
  ChipListItem(
    text: '181 - 250 kWh/m²/an',
    id: '4',
    shortText: 'D',
    leading: Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: CircleAvatar(
        radius: 12,
        backgroundColor: Colors.yellow.shade700,
        child: const Text(
          'D',
          style: TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  ),
  ChipListItem(
    text: '251 - 330 kWh/m²/an',
    id: '5',
    shortText: 'E',
    leading: Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: CircleAvatar(
        radius: 12,
        backgroundColor: Colors.yellow.shade500,
        child: const Text(
          'E',
          style: TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  ),
  ChipListItem(
    text: '331 - 420 kWh/m²/an',
    id: '6',
    shortText: 'F',
    leading: Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: CircleAvatar(
        radius: 12,
        backgroundColor: Colors.red.shade500,
        child: const Text(
          'F',
          style: TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  ),
  ChipListItem(
    text: '> 420 kWh/m²/an',
    id: '7',
    shortText: 'G',
    leading: Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: CircleAvatar(
        radius: 12,
        backgroundColor: Colors.red.shade900,
        child: const Text(
          'G',
          style: TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  ),
];

class User extends SearchEntry {
  @override
  factory User.from(SearchEntry other) {
    if (other is User) {
      return other.copyWith();
    }
    return User(sID: other.sID, lastName: other.displaySelected);
  }
  /* @override
  void fromJson(Map<String, dynamic> json) {
    firstName = json['firstName'] ?? firstName;
    lastName = json['lastName'] ?? lastName;
    initials = computeInitials(lastName, firstName);
    sID = json['sID'] ?? sID;
    hoverDescription = "$lastName ${firstName ?? ''}";
  } */

  User({required super.sID, required this.lastName, this.firstName})
    : initials = computeInitials(lastName, firstName),
      super(
        display: computeInitials(lastName, firstName),
        txtValue:
            "$lastName ${firstName ?? ''} ${computeInitials(lastName, firstName)}",
        hoverDescription: "$lastName ${firstName ?? ''}",
      );

  static String computeInitials(String lastName, String? firstName) =>
      "${lastName.isNotEmpty ? lastName[0] : ''}${firstName != null && firstName.isNotEmpty ? firstName[0] : ''}"
          .toUpperCase();

  String? firstName;
  String lastName;
  String initials;

  @override
  String toString() {
    return "$lastName $firstName";
  }

  // add == opérator
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.firstName == firstName &&
        other.lastName == lastName;
  }

  @override
  int get hashCode => firstName.hashCode ^ lastName.hashCode;

  @override
  User copyWith() {
    User newUser = User(sID: sID, firstName: firstName, lastName: lastName)
      // Copier les propriétés héritées de SearchEntry
      ..fuzzySearchResult = fuzzySearchResult
      ..hoverDescription = hoverDescription;

    return newUser;
  }

  @override
  Widget displayInList(ChipTextCompletionController controller) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Container(
          color: Colors.grey.shade400,
          width: 75,
          child: Text.rich(
            TextSpan(children: controller.hightLightChunksFound(sID)),
          ),
        ),
        /* Flexible(
          child: Text.rich(
            TextSpan(children: controller.hightLightChunksFound(lastName)),
            softWrap: true,
          ),
        ), */
        Flexible(
          child: Text.rich(
            TextSpan(
              children: [
                ...controller.hightLightChunksFound(lastName),
                const TextSpan(text: ' '), // Espace entre nom et prénom
                ...controller.hightLightChunksFound(firstName ?? ''),
              ],
            ),
            softWrap: true,
          ),
        ),
      ],
    );
  }

  @override
  set displaySelected(String value) => initials;

  @override
  String get displaySelected => initials;
}

List<User> fakeUsers =
    <Map<String, String>>[
          {'first': 'Sophie', 'last': 'MARTIN'},
          {'first': 'Lucas', 'last': 'DUBOIS'},
          {'first': 'Emma', 'last': 'LEFEVRE'},
          {'first': 'Louis', 'last': 'MOREAU'},
          {'first': 'Chloé', 'last': 'GIRARD'},
          {'first': 'Nathan', 'last': 'LAMBERT'},
          {'first': 'Camille', 'last': 'ROUX'},
          {'first': 'Léo', 'last': 'FONTAINE'},
          {'first': 'Manon', 'last': 'BENOIT'},
          {'first': 'Hugo', 'last': 'BARBIER'},
          {'first': 'Lola', 'last': 'GARNIER'},
          {'first': 'Jules', 'last': 'MARCHAND'},
          {'first': 'Inès', 'last': 'GIRAUD'},
          {'first': 'Gabriel', 'last': 'PICHON'},
          {'first': 'Léa', 'last': 'BOURGEOIS'},
          {'first': 'Arthur', 'last': 'CHEVALIER'},
          {'first': 'Zoé', 'last': 'COLLET'},
          {'first': 'Ethan', 'last': 'LEMOINE'},
          {'first': 'Alice', 'last': 'RENAUD'},
          {'first': 'Christophe', 'last': 'DESBOIS'},
          {'first': 'Maxime', 'last': 'DESBOIS'},
          {'first': 'Christelle', 'last': 'DAUTREMAY'},
          {'first': 'Xenus', 'last': 'LE DUC'},
          {'first': 'Albert', 'last': 'DUPONT'},
          {'first': 'Pierre-Henri', 'last': 'DURAND'},
          {'first': 'Fabrice', 'last': 'DEBUS'},
          {'first': 'Xavier', 'last': 'GIBOULOT'},
          {'first': 'Pascal', 'last': 'VEYRET'},
          {'first': 'Paul', 'last': 'DURAND'},
          {'first': 'Marie', 'last': 'LEROY'},
          {'first': 'Thomas', 'last': 'ROUSSEAU'},
          {'first': 'Sarah', 'last': 'MOREL'},
          {'first': 'Antoine', 'last': 'FONTAINE'},
          {'first': 'Julie', 'last': 'BLANC'},
          {'first': 'Alexandre', 'last': 'GARNIER'},
          {'first': 'Claire', 'last': 'LEGRAND'},
          {'first': 'Nicolas', 'last': 'ROBIN'},
          {'first': 'Elodie', 'last': 'CLEMENT'},
          {'first': 'Julien', 'last': 'GAUTHIER'},
          {'first': 'Sophie', 'last': 'CHEVALIER'},
          {'first': 'Matthieu', 'last': 'FRANCOIS'},
          {'first': 'Isabelle', 'last': 'MARTINEZ'},
          {'first': 'Vincent', 'last': 'LEFEBVRE'},
          {'first': 'Aurélie', 'last': 'GUILLAUME'},
          {'first': 'Guillaume', 'last': 'MARTIN'},
          {'first': 'Céline', 'last': 'ROGER'},
          {'first': 'Benjamin', 'last': 'BERTRAND'},
          {'first': 'Sandrine', 'last': 'DAVID'},
          {'first': 'Romain', 'last': 'MOREAU'},
          {'first': 'Caroline', 'last': 'SIMON'},
          {'first': 'Lucas', 'last': 'MICHEL'},
          {'first': 'Amélie', 'last': 'LECLERC'},
          {'first': 'Hugo', 'last': 'LAMBERT'},
          {'first': 'Marine', 'last': 'BONNET'},
          {'first': 'Pierre', 'last': 'DUVAL'},
          {'first': 'Camille', 'last': 'MENARD'},
          {'first': 'Louis', 'last': 'GERARD'},
          {'first': 'Manon', 'last': 'BARON'},
          {'first': 'Arthur', 'last': 'SCHMITT'},
          {'first': 'Léa', 'last': 'COLLIN'},
          {'first': 'Maxime', 'last': 'MARCHAL'},
          {'first': 'Chloé', 'last': 'JOLY'},
          {'first': 'Ethan', 'last': 'GUERIN'},
          {'first': 'Alice', 'last': 'PERROT'},
          {'first': 'Jules', 'last': 'BOUCHER'},
          {'first': 'Inès', 'last': 'LEROY'},
          {'first': 'Gabriel', 'last': 'ROY'},
          {'first': 'Zoé', 'last': 'NOEL'},
          {'first': 'Emma', 'last': 'REY'},
          {'first': 'Nathan', 'last': 'HENRY'},
          {'first': 'Pauline', 'last': 'RICHARD'},
          {'first': 'Baptiste', 'last': 'BOURDON'},
          {'first': 'Eva', 'last': 'GUYOT'},
          {'first': 'Quentin', 'last': 'MARTEL'},
          {'first': 'Laura', 'last': 'CARON'},
          {'first': 'Adrien', 'last': 'BARRE'},
          {'first': 'Mélanie', 'last': 'MORIN'},
          {'first': 'Simon', 'last': 'LEMAIRE'},
          {'first': 'Anaïs', 'last': 'MUNOZ'},
          {'first': 'Florian', 'last': 'MARCHAND'},
          {'first': 'Lucie', 'last': 'GROS'},
          {'first': 'Benoît', 'last': 'COLAS'},
          {'first': 'Amandine', 'last': 'MENIER'},
          {'first': 'Guillaume', 'last': 'LEBRUN'},
          {'first': 'Sébastien', 'last': 'BARBIER'},
          {'first': 'Aurélien', 'last': 'GILBERT'},
          {'first': 'Morgane', 'last': 'BOURDILLON'},
          {'first': 'Valentin', 'last': 'LEJEUNE'},
          {'first': 'Estelle', 'last': 'MARTY'},
          {'first': 'Corentin', 'last': 'MORVAN'},
          {'first': 'Laetitia', 'last': 'LEMOINE'},
          {'first': 'Thibault', 'last': 'GUILLOT'},
          {'first': 'Sabrina', 'last': 'MARTIN'},
          {'first': 'Olivier', 'last': 'DUHAMEL'},
          {'first': 'Cédric', 'last': 'LECLERCQ'},
          {'first': 'Auriane', 'last': 'ROUSSEL'},
          {'first': 'Mickael', 'last': 'BOURDON'},
          {'first': 'Sonia', 'last': 'LECOQ'},
          {'first': 'Damien', 'last': 'MARTIN'},
          {'first': 'Elise', 'last': 'LEMAITRE'},
          {'first': 'Kevin', 'last': 'LEBLANC'},
          {'first': 'Mathilde', 'last': 'MARTIN'},
          {'first': 'Jonathan', 'last': 'LEFORT'},
          {'first': 'Sophie', 'last': 'LEBRUN'},
          {'first': 'Laurent', 'last': 'LELONG'},
          {'first': 'Julie', 'last': 'LEMAIRE'},
          {'first': 'Patricia', 'last': 'LEGRAND'},
          {'first': 'Eric', 'last': 'LECLERC'},
          {'first': 'Christine', 'last': 'LEFEBVRE'},
          {'first': 'David', 'last': 'LEBLOND'},
          {'first': 'Nathalie', 'last': 'LEJEUNE'},
          {'first': 'Pascal', 'last': 'LEPAGE'},
          {'first': 'Isabelle', 'last': 'LEBAS'},
          {'first': 'Jean', 'last': 'LEMAITRE'},
          {'first': 'Sophie', 'last': 'LEBRUN'},
          {'first': 'Philippe', 'last': 'LEBLANC'},
          {'first': 'Catherine', 'last': 'LEGRAND'},
          {'first': 'François', 'last': 'LEFORT'},
          {'first': 'Sandrine', 'last': 'LELONG'},
          {'first': 'Bruno', 'last': 'LEMAIRE'},
          {'first': 'Sylvie', 'last': 'LECLERC'},
          {'first': 'Patrick', 'last': 'LEFEBVRE'},
          {'first': 'Valérie', 'last': 'LEBLOND'},
          {'first': 'Alain', 'last': 'LEJEUNE'},
          {'first': 'Martine', 'last': 'LEPAGE'},
          {'first': 'Gérard', 'last': 'LEBAS'},
          {'first': 'Monique', 'last': 'LEMAITRE'},
          {'first': 'Bernard', 'last': 'LEBRUN'},
          {'first': 'Jacques', 'last': 'LEBLANC'},
          {'first': 'Nicole', 'last': 'LEGRAND'},
          {'first': 'Michel', 'last': 'LEFORT'},
          {'first': 'Dominique', 'last': 'LELONG'},
          {'first': 'Jean-Pierre', 'last': 'LEMAIRE'},
          {'first': 'Hélène', 'last': 'LECLERC'},
          {'first': 'André', 'last': 'LEFEBVRE'},
          {'first': 'Marie-Claude', 'last': 'LEBLOND'},
          {'first': 'Christian', 'last': 'LEJEUNE'},
          {'first': 'Chantal', 'last': 'LEPAGE'},
          {'first': 'Daniel', 'last': 'LEBAS'},
          {'first': 'Josiane', 'last': 'LEMAITRE'},
          {'first': 'Paul', 'last': 'MARTIN'},
          {'first': 'Luc', 'last': 'DURAND'},
          {'first': 'Sophie', 'last': 'LEROY'},
          {'first': 'Julie', 'last': 'MOREAU'},
          {'first': 'Antoine', 'last': 'SIMON'},
          {'first': 'Camille', 'last': 'LAURENT'},
          {'first': 'Vincent', 'last': 'MICHEL'},
          {'first': 'Emma', 'last': 'ROUSSEAU'},
          {'first': 'Thomas', 'last': 'GARNIER'},
          {'first': 'Chloé', 'last': 'FAURE'},
          {'first': 'Lucas', 'last': 'ROGER'},
          {'first': 'Manon', 'last': 'BLANCHARD'},
          {'first': 'Arthur', 'last': 'GUERIN'},
          {'first': 'Léa', 'last': 'BOUCHER'},
          {'first': 'Gabriel', 'last': 'DUVAL'},
          {'first': 'Zoé', 'last': 'MENARD'},
          {'first': 'Nathan', 'last': 'LECLERC'},
          {'first': 'Alice', 'last': 'LEFEBVRE'},
          {'first': 'Jules', 'last': 'BARRE'},
          {'first': 'Inès', 'last': 'COLLET'},
          {'first': 'Marie', 'last': 'MARTY'},
          {'first': 'Hugo', 'last': 'MUNOZ'},
          {'first': 'Pauline', 'last': 'REY'},
          {'first': 'Baptiste', 'last': 'CARON'},
          {'first': 'Eva', 'last': 'LEMAIRE'},
          {'first': 'Quentin', 'last': 'LEFORT'},
          {'first': 'Laura', 'last': 'LEGRAND'},
          {'first': 'Adrien', 'last': 'DAVID'},
          {'first': 'Mélanie', 'last': 'BERTRAND'},
          {'first': 'Simon', 'last': 'GUILLAUME'},
          {'first': 'Anaïs', 'last': 'LEBLANC'},
          {'first': 'Florian', 'last': 'ROUSSEL'},
          {'first': 'Lucie', 'last': 'LEMOINE'},
          {'first': 'Benoît', 'last': 'GILBERT'},
          {'first': 'Amandine', 'last': 'LEBRUN'},
          {'first': 'Guillaume', 'last': 'LEPAGE'},
          {'first': 'Sébastien', 'last': 'LEBAS'},
          {'first': 'Aurélien', 'last': 'LEJEUNE'},
          {'first': 'Morgane', 'last': 'LELONG'},
          {'first': 'Valentin', 'last': 'LEMAITRE'},
          {'first': 'Estelle', 'last': 'LEBLOND'},
          {'first': 'Corentin', 'last': 'LECOQ'},
          {'first': 'Laetitia', 'last': 'LEFORT'},
          {'first': 'Thibault', 'last': 'LEGRAND'},
          {'first': 'Sabrina', 'last': 'LEMAIRE'},
          {'first': 'Olivier', 'last': 'LEBLANC'},
          {'first': 'Cédric', 'last': 'LEPAGE'},
          {'first': 'Auriane', 'last': 'LEBAS'},
          {'first': 'Mickael', 'last': 'LEJEUNE'},
          {'first': 'Sonia', 'last': 'LELONG'},
          {'first': 'Damien', 'last': 'LEMAITRE'},
          {'first': 'Elise', 'last': 'LEBLOND'},
          {'first': 'Kevin', 'last': 'LECOQ'},
          {'first': 'Mathilde', 'last': 'LEFORT'},
          {'first': 'Jonathan', 'last': 'LEGRAND'},
          {'first': 'Sophie', 'last': 'LEMAIRE'},
          {'first': 'Laurent', 'last': 'LEBLANC'},
          {'first': 'Julie', 'last': 'LEPAGE'},
          {'first': 'Patricia', 'last': 'LEBAS'},
          {'first': 'Eric', 'last': 'LEJEUNE'},
          {'first': 'Christine', 'last': 'LELONG'},
          {'first': 'David', 'last': 'LEMAITRE'},
          {'first': 'Nathalie', 'last': 'LEBLOND'},
          {'first': 'Pascal', 'last': 'LECOQ'},
          {'first': 'Isabelle', 'last': 'LEFORT'},
          {'first': 'Jean', 'last': 'LEGRAND'},
          {'first': 'Sophie', 'last': 'LEMAIRE'},
          {'first': 'Philippe', 'last': 'LEBLANC'},
          {'first': 'Catherine', 'last': 'LEPAGE'},
          {'first': 'François', 'last': 'LEBAS'},
          {'first': 'Sandrine', 'last': 'LEJEUNE'},
          {'first': 'Bruno', 'last': 'LELONG'},
          {'first': 'Sylvie', 'last': 'LEMAITRE'},
          {'first': 'Patrick', 'last': 'LEBLOND'},
          {'first': 'Valérie', 'last': 'LECOQ'},
          {'first': 'Alain', 'last': 'LEFORT'},
          {'first': 'Martine', 'last': 'LEGRAND'},
          {'first': 'Gérard', 'last': 'LEMAIRE'},
          {'first': 'Monique', 'last': 'LEBLANC'},
          {'first': 'Bernard', 'last': 'LEPAGE'},
          {'first': 'Jacques', 'last': 'LEBAS'},
          {'first': 'Nicole', 'last': 'LEJEUNE'},
          {'first': 'Michel', 'last': 'LELONG'},
          {'first': 'Dominique', 'last': 'LEMAITRE'},
          {'first': 'Jean-Pierre', 'last': 'LEBLOND'},
          {'first': 'Hélène', 'last': 'LECOQ'},
          {'first': 'André', 'last': 'LEFORT'},
          {'first': 'Marie-Claude', 'last': 'LEGRAND'},
          {'first': 'Christian', 'last': 'LEMAIRE'},
          {'first': 'Chantal', 'last': 'LEBLANC'},
          {'first': 'Daniel', 'last': 'LEPAGE'},
          {'first': 'Josiane', 'last': 'LEBAS'},
          {'first': 'Emilie', 'last': 'MARTIN'},
          {'first': 'Alexis', 'last': 'DURAND'},
          {'first': 'Caroline', 'last': 'LEROY'},
          {'first': 'Guillaume', 'last': 'MOREAU'},
          {'first': 'Sébastien', 'last': 'SIMON'},
          {'first': 'Aurélie', 'last': 'LAURENT'},
          {'first': 'Nicolas', 'last': 'MICHEL'},
          {'first': 'Amélie', 'last': 'ROUSSEAU'},
          {'first': 'Julien', 'last': 'GARNIER'},
          {'first': 'Marine', 'last': 'FAURE'},
          {'first': 'Bastien', 'last': 'ROGER'},
          {'first': 'Charlotte', 'last': 'BLANCHARD'},
          {'first': 'Matthieu', 'last': 'GUERIN'},
          {'first': 'Sophie', 'last': 'BOUCHER'},
          {'first': 'Clément', 'last': 'DUVAL'},
          {'first': 'Aurélie', 'last': 'MENARD'},
          {'first': 'Mickaël', 'last': 'LECLERC'},
          {'first': 'Elodie', 'last': 'LEFEBVRE'},
          {'first': 'Maxime', 'last': 'BARRE'},
          {'first': 'Aline', 'last': 'COLLET'},
        ]
        .map(
          (e) => User(
            sID: Crc32.calculate((e['first'] ?? '') + e['last']!).toString(),
            firstName: e['first'],
            lastName: e['last']!,
          ),
        )
        .toList();
