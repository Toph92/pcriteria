import 'package:criteria/chips/chips.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';

/// User class to represent a client with autocomplete
class User extends SearchEntry {
  @override
  factory User.from(SearchEntry other) {
    if (other is User) {
      return other.copyWith();
    }
    return User(sID: other.sID, lastName: other.displaySelected);
  }

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
        Flexible(
          child: Text.rich(
            TextSpan(
              children: [
                ...controller.hightLightChunksFound(lastName),
                const TextSpan(text: ' '),
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

/// Static list of users for autocomplete
List<User> staticUsers =
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
        ]
        .map(
          (userData) => User(
            sID: ((userData['first'] ?? '') + (userData['last'] ?? '')).hashCode
                .toRadixString(16),
            firstName: userData['first']!,
            lastName: userData['last']!,
          ),
        )
        .toList();

/// List of countries with flags
List<ChipListItem> countries = [
  ChipListItem(
    text: 'France',
    children: [
      Text(
        'France',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
      ),
      Spacer(),
      Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Container(
          width: 40,
          height: 26,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              'FR',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    ],
    id: '1',
    shortText: 'FR',
    comments: "65 millions d'habitants",
    leading: CountryFlags.flag('FR', height: 20, width: 30),
  ),
  ChipListItem(
    text: 'Allemagne',
    id: '2',
    shortText: 'DE',
    comments: "83 millions d'habitants",
    leading: CountryFlags.flag('DE', height: 20, width: 30),
  ),
  ChipListItem(
    text: 'Belgique',
    id: '3',
    shortText: 'BE',
    comments: "11 millions d'habitants",
    leading: CountryFlags.flag('BE', height: 20, width: 30),
  ),
  ChipListItem(
    text: 'Suisse',
    id: '4',
    shortText: 'CH',
    comments: "8 millions d'habitants",
    leading: CountryFlags.flag('CH', height: 20, width: 30),
  ),
  ChipListItem(
    text: 'Luxembourg',
    id: '5',
    shortText: 'LU',
    comments: "630 000 habitants",
    leading: CountryFlags.flag('LU', height: 20, width: 30),
  ),
  ChipListItem(
    text: 'Espagne',
    id: '6',
    shortText: 'ES',
    comments: "47 millions d'habitants",
    leading: CountryFlags.flag('ES', height: 20, width: 30),
  ),
  ChipListItem(
    text: 'Italie',
    id: '7',
    shortText: 'IT',
    comments: "60 millions d'habitants",
    leading: CountryFlags.flag('IT', height: 20, width: 30),
  ),
  ChipListItem(
    text: 'Portugal',
    id: '8',
    shortText: 'PT',
    comments: "10 millions d'habitants",
    leading: CountryFlags.flag('PT', height: 20, width: 30),
  ),
  ChipListItem(
    text: 'Pays-Bas',
    id: '9',
    shortText: 'NL',
    comments: "17 millions d'habitants",
    leading: CountryFlags.flag('NL', height: 20, width: 30),
  ),
  ChipListItem(
    text: 'Danemark',
    id: '10',
    shortText: 'DK',
    comments: "6 millions d'habitants",
    leading: CountryFlags.flag('DK', height: 20, width: 30),
  ),
];
