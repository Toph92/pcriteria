import 'package:flutter/material.dart';
import 'package:criteria/chips/chips.dart';

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
  set displaySelected(String value) =>
      '${firstName?.substring(0, 1)} $lastName';

  @override
  String get displaySelected => '${firstName?.substring(0, 1)} $lastName';

  @override
  Widget displayInList(ChipTextCompletionController controller) {
    return Row(
      //crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Colors.grey.shade400,
          width: 75,
          //height: 50,
          child: Center(
            child: Text(
              sID,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Row(
          children: [
            //Text(lastName, style: const TextStyle(fontWeight: FontWeight.bold)),
            //const SizedBox(width: 4),
            //Text(firstName ?? ''),
            const SizedBox(width: 4),
            Text.rich(
              TextSpan(
                children: [
                  ...controller.hightLightChunksFound(lastName),
                  const TextSpan(text: ' '), // Espace entre nom et prénom
                  ...controller.hightLightChunksFound(firstName ?? ''),
                ],
              ),
              softWrap: true,
            ),
          ],
        ),
      ],
    );
  }
}
