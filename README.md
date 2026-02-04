<div align="center">

# criteria

Rich, composable, state‑driven “criteria chips” (filters) widgets for Flutter: text, auto‑complete, lists, numeric ranges, date & date‑range, boolean, with grouping, persistence & fuzzy search.

</div>

## Why
Building a consistent, ergonomic, multi‑type filter / criteria bar in Flutter often means rewriting the same patterns (popup, selection list, range input, persistence, badges…). `criteria` bundles a set of opinionated chip widgets + controllers so you focus on business rules, not UI plumbing.

## Overview
Each criterion is a `ChipItemController` subclass (text, list, range, date, etc.). You assemble them inside a `ChipsController`, then render with the `ChipsCriteria` widget (which shows an Add button + the active chips, or only chips depending on display mode). Controllers expose simple value access, JSON (de)serialisation and persistence via `SharedPreferences`.



## Features
* Text chip (`ChipText`)
* Auto‑complete with async datasource, caching & optional fuzzy search (`ChipTextCompletion`)
* Select list (single / multi) with several display modes & hover preview (`ChipList`)
* Numeric range with slider + manual inputs (`ChipRange`)
* Single date (`ChipDate`) & date range (`ChipDatesRange`)
* Boolean toggle (`ChipBoolean`)
* Grouping (`ChipGroup`) with coloured side bars in the Add popup
* Add popup with resize handle, lock / visibility indicators
* Unified controller base (`ChipItemController`) + JSON export (`toJson`) and import (`fromJson` through `ChipsController`)
* Persistence: `saveCriteria()` / `loadCriteria()` using `SharedPreferences`
* Change detection (`isUpdated`) to avoid useless writes
* Fuzzy search fall‑back for completion when no exact results (n‑gram quick blocks)
* Accents insensitive search (`removeAccents` extension)
* Desktop / web layout adaptations (separator + clear all button)

## Installation
Add to your `pubspec.yaml` (once you decide to publish remove `publish_to: none`). Ensure you also have the assets you want for SVG icons or replace the defaults with your own widgets.

dependencies:	
    criteria:
        git:
            url: https://github.com/Toph92/pcriteria
            ref: main

## Quick start
```dart
import 'package:criteria/criteria.dart';
import 'package:flutter/material.dart';

class MyFiltersBar extends StatefulWidget {
	const MyFiltersBar({super.key});
	@override
	State<MyFiltersBar> createState() => _MyFiltersBarState();
}

class _MyFiltersBarState extends State<MyFiltersBar> {
	late final ChipsController chipsController;

	@override
	void initState() {
		super.initState();
		final groupMain = ChipGroup(name: 'main', labelText: 'Main');
		chipsController = ChipsController(name: 'searchCriteria')
			..chips = [
				ChipTextController(name: 'q', label: 'Search', group: groupMain)
					..alwaysDisplayed = true,
				ChipBooleanController(name: 'onlyFav', label: 'Only favorites', group: groupMain),
				ChipRangeController(name: 'price', label: 'Price (€)', group: groupMain)
					..minMaxRange = const RangeValues(0, 500)
					..precision = 0,
				ChipDateController(name: 'since', label: 'Since', group: groupMain),
			];
	}

	@override
	Widget build(BuildContext context) {
		return ChipsCriteria(
			title: 'Criteria',
			chipsListControllers: chipsController,
			chipDisplayMode: const [ChipDisplayMode.withTileBorder],
		);
	}
}
```

## Auto‑complete example
```dart
final autoController = ChipTextCompletionController<SearchEntry>(
	name: 'user',
	label: 'User',
	group: groupMain,
	minCharacterNeeded: 2,
	maxEntries: 3,
	fuzzySearchStep: 0, // disable fuzzy until needed
	onRequestUpdateDataSource: (criteria, headerItems, opts) async {
		// Simulate network
		await Future.delayed(const Duration(milliseconds: 50));
		final list = <SearchEntry>[
			SearchEntry(sID: 'u1', display: 'Alice', txtValue: 'Alice'),
			SearchEntry(sID: 'u2', display: 'Bob', txtValue: 'Bob'),
			SearchEntry(sID: 'u3', display: 'Charlie', txtValue: 'Charlie'),
		];
		return (list.where((e)=> criteria!.every((c)=> e.sID.toUpperCase().contains(c))).toList(), {
			SearchOptionKey.numRequest.name: opts[SearchOptionKey.numRequest],
		});
	},
);
```

## Persistence
```dart
await chipsController.saveCriteria();              // writes latest snapshot
await chipsController.loadCriteria(withKey: 'A');  // load named profile
```

## JSON output
Every chip produces a stable JSON entry:
```json
[
	{"name":"q","type":10,"value":"hello","displayed":true},
	{"name":"price","type":30,"value":{"start":10,"end":50},"displayed":true}
]
```
You can store / transmit this payload yourself if you prefer another persistence layer.

## Display modes
`ChipList` supports: quantity, shortDescription, fullDescription, icon, iconAndShortDescription, iconAndDescription. Hover (desktop/web) can expand to a grid when more than a threshold.

## Testing
Minimal unit tests are included (controllers behaviour, JSON, persistence, accent stripping, range logic). Run:
```bash
flutter test
```

## Roadmap / Ideas
* Publish to pub.dev (+ add screenshots / gifs)
* More flexible theming API
* Builder hooks for custom chip body
* More robust focus / accessibility coverage
* Better fuzzy score tuning & ranking strategies

## Contributing
Issues & PRs welcome. Please add tests for new controller logic. Keep UI changes opt‑in / backwards compatible.

---
Made with curiosity — feedback & improvements are appreciated.
