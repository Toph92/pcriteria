import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:showcase/views/common.dart';
import 'package:syntax_highlight/syntax_highlight.dart';

// Exemple de code à afficher

class PageCodeView extends StatefulWidget {
  const PageCodeView({required this.code, super.key});

  final String code;
  @override
  State<PageCodeView> createState() => _PageCodeViewState();
}

class _PageCodeViewState extends State<PageCodeView> with CommonPages {
  late final Highlighter _dartLightHighlighter;
  //late final Highlighter _dartDarkHighlighter;
  bool _themeLoaded = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  Future<void> _initAsync() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize the highlighter.
    await Highlighter.initialize([
      'dart',
      'yaml',
      'sql',
      'serverpod_protocol',
      'json',
    ]);

    // Load the default light theme and create a highlighter.
    var lightTheme = await HighlighterTheme.loadLightTheme();
    _dartLightHighlighter = Highlighter(language: 'dart', theme: lightTheme);

    // Load the default dark theme and create a highlighter.
    //var darkTheme = await HighlighterTheme.loadDarkTheme();
    //_dartDarkHighlighter = Highlighter(language: 'dart', theme: darkTheme);

    setState(() {
      _themeLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            headerPage(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Retour',
                  ),
                  const Icon(Icons.code, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Vue de Code', style: titleStyle),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                label: const Text('Fermer'),
                icon: const Icon(Icons.close),
              ),
            ),
            const Divider(color: Colors.amber, height: 1),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Material(
                  child: _themeLoaded
                      ? Material(
                          // gradiant color
                          child: SingleChildScrollView(
                            child: Container(
                              color: Colors.white12,
                              child: Text.rich(
                                // Highlight the code.
                                _dartLightHighlighter.highlight(widget.code),
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 14,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ),
                        )
                      : const Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
