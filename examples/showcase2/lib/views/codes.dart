class Codes {
  static const String createList = '''
gr1 = ChipGroup(name: "G1", labelText: "Civilité")
  ..backgroundColor = Colors.blueGrey.shade500;

gr2 = ChipGroup(name: "G2", labelText: "Lieu de résidence")
  ..backgroundColor = Colors.orange.shade500;
gr3 = ChipGroup(name: "G3", labelText: "Habitation")
  ..backgroundColor = Colors.green.shade500;

chipsListControllers =
    ChipsController(name: "test1")
      ..chips = [
        ChipsTextController(name: "lastName", group: gr1!)
          ..label = "Nom"
          ..comments = "Nom de famille"
          ..avatar = Icon(Icons.person, color: Colors.blue, size: 24)
          ..labelStyle = TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
        ChipsTextController(name: "firstName", group: gr1!)
          ..avatar = Icon(
            Icons.person,
            color: Colors.blue.shade200,
            size: 24,
          )
          ..label = "Prénom",
        ChipDatesRangeController(name: "birthdate", group: gr1!)
          ..alwaysDisplayed = true
          ..label = "Date naissance"
          ..comments = "Exemple intervalle de dates",
        ChipFlagController(name: "dcd", group: gr1!)..label = "Décédé",
        ChipListController(name: "gender", group: gr1!)
          ..label = "Genre"
          ..comments = "Genre"
          ..dataset = genders
          ..toolTipMessage = "Sélectionnez un genre"
          ..avatar = Icon(Icons.wc, size: 24)
          ..gridAlign = Alignment.center
          ..gridCols = 2
          ..gridAspectRatio = 2
          ..displayMode = ChipListDisplayMode.iconAndShortDescription
          ..displayModeHoverPopup =
              ChipListDisplayMode.iconAndShortDescription
          ..multiSelect = true
          ..quitOnSelect = false
          ..displayModeStepQty = 10
          ..popupXoffset = 0.0
          ..alwaysDisplayed = false,
        
        ChipsTextController(name: "city", group: gr2!)
          ..label = "Ville"
          ..comments = "Ville de résidence"
          ..avatar = Icon(Icons.location_city, color: Colors.blue, size: 24)
          ..labelStyle = TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.green,
          ),
        ChipListController(name: "country", group: gr2!)              
          ..label = "Pays"
          ..comments = "Pays de résidence"
          ..dataset = items
          ..toolTipMessage = "Sélectionnez un pays"
          ..avatar = Icon(Icons.flag, size: 24)
          ..gridAlign = Alignment.center
          ..gridCols = 2
          ..gridAspectRatio = 2
          ..displayMode = ChipListDisplayMode.iconAndShortDescription
          ..displayModeHoverPopup =
              ChipListDisplayMode.iconAndShortDescription
          ..multiSelect = true
          ..quitOnSelect = false
          ..displayModeStepQty = 4
          ..popupXoffset = 0.0
          ..alwaysDisplayed = false,

        ChipListController(name: "citySize", group: gr2!)
          ..label = "Taille de la ville"
          ..comments = "Taille de la ville"
          ..dataset = citySize
          ..toolTipMessage = "Sélectionnez une taille de ville"
          ..avatar = Icon(Icons.diversity_3, size: 24)
          ..gridAlign = Alignment.centerLeft
          ..gridCols = 2
          ..gridAspectRatio = 2
          ..displayMode = ChipListDisplayMode.iconAndShortDescription
          ..displayModeHoverPopup =
              ChipListDisplayMode.iconAndShortDescription
          ..multiSelect = true
          ..quitOnSelect = false
          ..displayModeStepQty = 3
          ..popupXoffset = 0.0,

        ChipDateController(name: "constructDate", group: gr3!)
          ..label = "Construction après"
          ..comments = "Exemple d'une date",

        ChipListController(name: "house", group: gr3!)
          ..label = "Type d'habitation"
          ..dataset = houseType
          ..toolTipMessage = "Appartement ou maison"
          ..comments = "Exemple d'une liste à choix unique"
          ..avatar = Icon(Icons.home, size: 24)
          ..gridAlign = Alignment.center
          ..gridCols = 2
          ..gridAspectRatio = 1
          ..displayMode = ChipListDisplayMode.iconAndShortDescription
          ..displayModeHoverPopup =
              ChipListDisplayMode.iconAndShortDescription
          ..multiSelect = true
          ..quitOnSelect = false
          ..displayModeStepQty = 3
          ..multiSelect = false
          ..quitOnSelect = true
          ..popupXoffset = 0.0,
        ChipListController(name: "dpe", group: gr3!)
          ..label = "DPE"
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
          ..popupXoffset = 0.0,            
      ];
      ''';
  static const String createListCountry = '''
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
  ...
  ];
  ''';

  static const String createListDPE = '''
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
        child: Text(
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
        child: Text(
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
  ...
 ];
''';

  static const String createView1 = '''
  ChipsCriteria(
    chipsListControllers: chipsListControllers!,
    chipLayout: ChipLayout.layout2,
    title: "Critères de recherche",
    chipDisplayMode: [ChipDisplayMode.withTileBorder],
    titleStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.blueGrey.shade800,
    ),
    helperWidget: Text(
      "Ajouter des critères",
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: Colors.grey,
        fontStyle: FontStyle.italic,
      ),
    ),
  )
''';
  static const String createView2 = '''
  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [      
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: ChipsCriteria(
          chipsListControllers: chipsListControllers!,
          chipLayout: ChipLayout.layout2,
          title: "Critères de recherche",
          chipDisplayMode: [ChipDisplayMode.buttonOnly],
          titleStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey.shade800,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: ChipsCriteria(
          chipsListControllers: chipsListControllers!,
          chipLayout: ChipLayout.layout2,
          groupsFilterDisplay: [gr1!],
          title: gr1!.labelText,
          backgroundColor: gr1!.backgroundColor.withValues(alpha: 0.2),
          borderColor: gr1!.backgroundColor,
          chipDisplayMode: [
            ChipDisplayMode.criteriaOnly,
            ChipDisplayMode.withTileBorder,
          ],
          titleStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey.shade800,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: ChipsCriteria(
          chipsListControllers: chipsListControllers!,
          chipLayout: ChipLayout.layout2,
          groupsFilterDisplay: [gr2!],
          title: gr2!.labelText,
          backgroundColor: gr2!.backgroundColor.withValues(alpha: 0.3),
          borderColor: gr2!.backgroundColor,
          chipDisplayMode: [
            ChipDisplayMode.criteriaOnly,
            ChipDisplayMode.withTileBorder,
          ],
          titleStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey.shade800,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: ChipsCriteria(
          chipsListControllers: chipsListControllers!,
          chipLayout: ChipLayout.layout2,
          groupsFilterDisplay: [gr3!],
          title: gr3!.labelText,
          backgroundColor: gr3!.backgroundColor.withValues(alpha: 0.3),
          borderColor: gr3!.backgroundColor,
          chipDisplayMode: [
            ChipDisplayMode.criteriaOnly,
            ChipDisplayMode.withTileBorder,
          ],
          titleStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey.shade800,
          ),
        ),
      ),      
    ],
  )
''';
  static const String createView5 = '''
  Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [        
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ChipsCriteria(
              chipsListControllers: chipsListControllers!,
              chipLayout: ChipLayout.layout2,
              groupsFilterDisplay: [gr1!],
              title: gr1!.labelText,
              backgroundColor: gr1!.backgroundColor.withValues(alpha: 0.2),
              borderColor: gr1!.backgroundColor,
              chipDisplayMode: [ChipDisplayMode.withTileBorder],
              titleStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey.shade800,
              ),              
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ChipsCriteria(
              chipsListControllers: chipsListControllers!,
              chipLayout: ChipLayout.layout2,
              groupsFilterDisplay: [gr2!, gr3!],
              title: "Autre critères",
              backgroundColor: Colors.yellow.shade100,
              borderColor: Colors.pink,
              chipDisplayMode: [
                ChipDisplayMode.criteriaOnly,
                ChipDisplayMode.withTileBorder,
              ],
              titleStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: Colors.green,
              ),
            ),
          ),        
        ],
      )
''';
}
