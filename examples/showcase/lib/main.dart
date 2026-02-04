import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:showcase/page_views.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Criteria Demo',
      theme: ThemeData(
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Carousel Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({required this.title, super.key});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool hoverNext = false;
  bool hoverPrev = false;
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  late AnimationController _shimmerController;
  bool _showShimmer = false;

  final List<Widget> _pages = [
    const Page1(),
    const Page2(),
    const Page3(),
    const Page4(),
    const Page5(),
    const Page6(),
    const Page7(),
  ];

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Start the periodic shimmer effect
    _startPeriodicShimmer();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  void _startPeriodicShimmer() {
    Future.delayed(const Duration(seconds: 20), () {
      if (mounted) {
        setState(() {
          _showShimmer = true;
        });
        _shimmerController.forward().then((_) {
          if (mounted) {
            _shimmerController.reset();
            setState(() {
              _showShimmer = false;
            });
            _startPeriodicShimmer(); // Restart the cycle
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        toolbarHeight: 0,
        //title: Text(widget.title),
      ),
      body: Material(
        color: Colors.grey.shade100,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      CarouselSlider(
                        carouselController: _carouselController,
                        options: CarouselOptions(
                          height: MediaQuery.of(context).size.height * 1,
                          viewportFraction: 1.0,
                          autoPlayInterval: const Duration(seconds: 3),
                          onPageChanged: (index, reason) {
                            setState(() {
                              _currentIndex = index;
                            });
                          },
                        ),
                        items: _pages,
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 200),
                          child: Row(
                            children: [
                              MouseRegion(
                                onHover: (event) {
                                  setState(() {
                                    hoverPrev = true;
                                  });
                                },
                                onExit: (event) {
                                  setState(() {
                                    hoverPrev = false;
                                  });
                                },
                                child: IconButton(
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  icon: const Icon(Icons.arrow_back_ios),
                                  onPressed: () {
                                    _carouselController.previousPage();
                                  },
                                  padding: const EdgeInsets.all(16.0),
                                  color: hoverPrev
                                      ? Colors.black
                                      : Colors.grey.shade300,
                                  iconSize: 40,
                                  alignment: Alignment.center,
                                ),
                              ),
                              const Spacer(),
                              MouseRegion(
                                onHover: (event) {
                                  setState(() {
                                    hoverNext = true;
                                  });
                                },
                                onExit: (event) {
                                  setState(() {
                                    hoverNext = false;
                                  });
                                },
                                child: IconButton(
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  icon: const Icon(Icons.arrow_forward_ios),
                                  onPressed: () {
                                    _carouselController.nextPage();
                                  },
                                  padding: const EdgeInsets.all(16.0),
                                  color: hoverNext
                                      ? Colors.black
                                      : Colors.grey.shade300,
                                  iconSize: 40,
                                  alignment: Alignment.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < _pages.length; i++)
                        GestureDetector(
                          onTap: () {
                            _carouselController.animateToPage(i);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentIndex == i
                                  ? Colors.deepPurple
                                  : Colors.grey,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                /* Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _carouselController.previousPage();
                        },
                        child: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () {
                          _carouselController.nextPage();
                        },
                        child: const Icon(Icons.arrow_forward),
                      ),
                    ],
                  ),
                ), */
              ],
            ),
            if (!kDebugMode)
              Positioned(
                bottom: 12,
                left: 12,
                child: _showShimmer
                    ? Shimmer.fromColors(
                        baseColor: Colors.green,
                        highlightColor: Colors.green.shade100,
                        child: const Row(
                          children: [
                            Icon(Icons.eco, color: Colors.green),
                            SizedBox(width: 4),
                            Text(
                              "Green IT compatible",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    : const Row(
                        children: [
                          Icon(Icons.eco, color: Colors.green),
                          SizedBox(width: 4),
                          Text(
                            "Green IT compatible",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
