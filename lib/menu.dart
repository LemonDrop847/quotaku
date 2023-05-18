import 'package:flutter/material.dart';

class Menu extends StatefulWidget {
  final VoidCallback onRefreshPressed;
  final VoidCallback onSharePressed;

  const Menu({
    required this.onRefreshPressed,
    required this.onSharePressed,
  });

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  bool _isOpen = false;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isOpen = !_isOpen;
    });

    if (_isOpen) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (_isOpen) ...[
          FloatingActionButton(
            onPressed: widget.onRefreshPressed,
            child: const Icon(Icons.refresh),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: widget.onSharePressed,
            child: const Icon(Icons.share),
          ),
          const SizedBox(height: 16),
        ],
        FloatingActionButton(
          onPressed: _toggleMenu,
          child: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: _rotationAnimation,
          ),
        ),
      ],
    );
  }
}
