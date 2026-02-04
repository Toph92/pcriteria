import 'package:criteria/chips/chips.dart';
import 'package:flutter/material.dart';
import 'search_criteria.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minimal Criteria Example',
      theme: ThemeData(
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Search Criteria'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _hoverSearch = false;
  bool _hoverReset = false;
  String _searchResults = "";

  @override
  void dispose() {
    searchCriteriaController?.removeListener(_onUpdate);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initializeSearchCriteria();
    searchCriteriaController?.addListener(_onUpdate);
  }

  @override
  void didChangeDependencies() {
    searchCriteriaController!.getChipByName('client')?.label =
        "Client"; // Example of setting label after initialization, useful for localization
    // best pratice than in build() method
    super.didChangeDependencies();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _onUpdate() {
    searchCriteriaController?.saveCriteria();
    _refresh();
  }

  void _performSearch() {
    setState(() {
      _searchResults = getSearchSummary();
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Search Results'),
          content: SingleChildScrollView(child: Text(_searchResults)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _disableFields() {
    setState(() {
      for (var controller in searchCriteriaController!.chips) {
        controller.disable = true;
      }
    });
  }

  void _resetFields() {
    setState(() {
      _searchResults = "";
      searchCriteriaController?.clear();
    });
  }

  Widget _buildSearchButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hoverSearch = true),
        onExit: (_) => setState(() => _hoverSearch = false),
        cursor: SystemMouseCursors.click,
        child: FilledButton.icon(
          onPressed: _performSearch,
          label: const Text("Search"),
          icon: AnimatedScale(
            scale: _hoverSearch ? 1.35 : 1.0,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            child: const Icon(Icons.search),
          ),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildResetButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hoverReset = true),
        onExit: (_) => setState(() => _hoverReset = false),
        cursor: SystemMouseCursors.click,
        child: FilledButton.icon(
          onPressed: _resetFields,
          label: const Text("Clear"),
          icon: AnimatedScale(
            scale: _hoverReset ? 1.35 : 1.0,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            child: const Icon(Icons.replay),
          ),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _builDisableButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hoverReset = true),
        onExit: (_) => setState(() => _hoverReset = false),
        cursor: SystemMouseCursors.click,
        child: FilledButton.icon(
          onPressed: _disableFields,
          label: const Text("Disable all"),
          icon: AnimatedScale(
            scale: _hoverReset ? 1.35 : 1.0,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            child: const Icon(Icons.replay),
          ),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.white, size: 32),
            const SizedBox(width: 12),
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (searchCriteriaController != null)
                      ChipsCriteria(
                        chipsListControllers: searchCriteriaController!,
                        title: "Select your search criteria",
                        chipDisplayMode: [ChipDisplayMode.withTileBorder],
                        //showRefreshButton: false,
                        showEraseAllButton: false,
                        titleStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                    const SizedBox(height: 16),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Usage Instructions:",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "• Client: Type the first letters of the name or surname to see suggestions\n"
                            "• Date of birth: Click to select a date range\n"
                            "• Country: Click to see the list with flags",
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        _buildSearchButton(),
                        SizedBox(width: 16),
                        _buildResetButton(),
                        SizedBox(width: 16),
                        _builDisableButton(),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            if (_searchResults.isNotEmpty)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Last search:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _searchResults,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
