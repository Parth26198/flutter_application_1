import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey[600],
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                'https://raw.githubusercontent.com/Parth26198/FlutterDock/refs/heads/main/macos-big-sur-apple-layers-fluidic-colorful-wwdc-stock-3440x1440-1455.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Dock(
                  items: const [
                    'https://raw.githubusercontent.com/Parth26198/FlutterDock/refs/heads/main/calendar-2021-04-29.png',
                    'https://raw.githubusercontent.com/Parth26198/FlutterDock/refs/heads/main/Apple_Messages-1024.webp',
                    'https://raw.githubusercontent.com/Parth26198/FlutterDock/refs/heads/main/purepng.com-appstore-iconsymbolsiconsapple-iosiosios-8-iconsios-8-721522596009rinhz.png',
                    'https://raw.githubusercontent.com/Parth26198/FlutterDock/refs/heads/main/google-chrome-icon-1.png',
                    'https://raw.githubusercontent.com/Parth26198/FlutterDock/refs/heads/main/safari_macos_bigsur_icon_189770.webp',
                    'https://raw.githubusercontent.com/Parth26198/FlutterDock/refs/heads/main/notes_be94gn.png',
                    'https://raw.githubusercontent.com/Parth26198/FlutterDock/refs/heads/main/music_hj6hvj.png',
                    'https://raw.githubusercontent.com/Parth26198/FlutterDock/refs/heads/main/reminders_fwlewx.png',
                  ],
                  builder: (url) {
                    return Container(
                      constraints: const BoxConstraints(minWidth: 48),
                      height: 48,
                      margin: const EdgeInsets.all(8),
                      child: Center(
                        child: Image.network(
                          url,
                          fit: BoxFit.contain,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Dock<T> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  final List<T> items;
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

class _DockState<T> extends State<Dock<T>> with SingleTickerProviderStateMixin {
  late List<T> _items;
  int? _hoveringIndex;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
    _hoveringIndex = null;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black26,
      ),
      padding: const EdgeInsets.all(4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_items.length, (index) {
            return _buildDraggableItem(index);
          }),
        ),
      ),
    );
  }

  Widget _buildDraggableItem(int index) {
    return GestureDetector(
      onTap: () {
        _controller.forward();
        _startDrag(index);
      },
      child: Draggable<int>(
        data: index,
        onDragStarted: () {
          _controller.forward();
        },
        onDragEnd: (_) {
          _controller.reverse();
        },
        feedback: ScaleTransition(
          scale: _scaleAnimation,
          child: Material(
            color: Colors.transparent,
            child: widget.builder(_items[index]),
          ),
        ),
        childWhenDragging: const SizedBox.shrink(),
        onDragCompleted: () {
          setState(() {
            _hoveringIndex = null;
          });
        },
        onDraggableCanceled: (_, __) {
          setState(() {
            _hoveringIndex = null;
          });
        },
        child: DragTarget<int>(
          onAcceptWithDetails: (details) {
            setState(() {
              final oldIndex = details.data;
              if (oldIndex != index) {
                final item = _items.removeAt(oldIndex);
                _items.insert(index > oldIndex ? index - 1 : index, item);
              }
              _hoveringIndex = null;
            });
          },
          onWillAcceptWithDetails: (details) {
            setState(() {
              _hoveringIndex = index;
            });
            return true;
          },
          onLeave: (_) {
            setState(() {
              _hoveringIndex = null;
            });
          },
          builder: (context, candidateData, rejectedData) {
            final isHovering = _hoveringIndex == index;
            final double gapPadding = isHovering ? 32.0 : 0.0;
            return AnimatedPadding(
              padding: EdgeInsets.only(left: gapPadding),
              duration: const Duration(milliseconds: 200),
              child: widget.builder(_items[index]),
            );
          },
        ),
      ),
    );
  }

  void _startDrag(int index) {
    _controller.forward();
    setState(() {});
  }
}
