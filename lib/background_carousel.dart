import 'package:flutter/material.dart';
import 'background_option.dart';

class BackgroundCarousel extends StatefulWidget {
  final List<BackgroundOption> backgroundOptions;
  final BackgroundOption? selectedBackgroundOption;
  final Function(BackgroundOption) onBackgroundOptionSelected;

  const BackgroundCarousel({
    super.key,
    required this.backgroundOptions,
    required this.selectedBackgroundOption,
    required this.onBackgroundOptionSelected,
  });

  @override
  _BackgroundCarouselState createState() => _BackgroundCarouselState();
}

class _BackgroundCarouselState extends State<BackgroundCarousel> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.backgroundOptions
        .indexWhere((option) => option == widget.selectedBackgroundOption);
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
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Card(
        child: GestureDetector(
          onTap: () {
            widget.onBackgroundOptionSelected(
                widget.backgroundOptions[_currentIndex]);
            Navigator.pop(context);
          },
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: widget.backgroundOptions.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                            widget.backgroundOptions[index].imagePath),
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
    );
  }
}
