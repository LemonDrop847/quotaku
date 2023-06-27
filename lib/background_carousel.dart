import 'package:flutter/material.dart';
import 'background_option.dart';

class BackgroundCarousel extends StatefulWidget {
  final List<BackgroundOption> backgroundOptions;
  final BackgroundOption? selectedBackgroundOption;
  final Function(BackgroundOption) onBackgroundOptionSelected;

  const BackgroundCarousel({
    Key? key,
    required this.backgroundOptions,
    required this.selectedBackgroundOption,
    required this.onBackgroundOptionSelected,
  }) : super(key: key);

  @override
  _BackgroundCarouselState createState() => _BackgroundCarouselState();
}

class _BackgroundCarouselState extends State<BackgroundCarousel> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  int _actualIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedBackgroundOption!.id;
    if (_currentIndex == -1) {
      _currentIndex = 0;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<BackgroundOption> duplicatedOptions = [
      ...widget.backgroundOptions,
      ...widget.backgroundOptions,
    ];

    return Container(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30.0),
          child: Card(
            child: GestureDetector(
              onTap: () {
                widget.onBackgroundOptionSelected(
                  widget.backgroundOptions[_actualIndex],
                );
                Navigator.pop(context);
              },
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex++;
                        _currentIndex =
                            _currentIndex % widget.backgroundOptions.length;
                      });
                    },
                    itemCount: duplicatedOptions.length,
                    itemBuilder: (BuildContext context, int index) {
                      _actualIndex =
                          _currentIndex % widget.backgroundOptions.length;
                      return Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                              duplicatedOptions[_actualIndex].imagePath,
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
