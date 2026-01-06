import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

class RippleEffectPage extends StatefulWidget {
  const RippleEffectPage({super.key});

  @override
  State<RippleEffectPage> createState() => _RippleEffectPageState();
}

class _RippleEffectPageState extends State<RippleEffectPage> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  Offset _mouse = Offset.zero;
  double _elapsed = 0.0;
  double _tapTime = -10.0;

  Size _defaultCardSize = Size(300, 500);

  late Size _cardSize;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final screen = MediaQuery.sizeOf(context);
    double w = (screen.width * 0.8).clamp(0, 400);
    double h = (w * 1.5).clamp(0, screen.height * 0.7);

    _defaultCardSize = Size(w, h);
    if (!_isExpanded) _cardSize = _defaultCardSize;
  }

  void _onTick(Duration elapsed) {
    setState(() {
      _elapsed =
          elapsed.inMilliseconds /
          800.0; // you can adjust the multiplier as needed
    });
  }

  void _handleTap(TapDownDetails details) {
    final double x = details.localPosition.dx;
    final double y = details.localPosition.dy;

    final size = MediaQuery.sizeOf(context);

    setState(() {
      // _mouse = Offset(x / _cardSize.width, y / _cardSize.height);
      _mouse = Offset(x / size.width, y / size.height);

      _tapTime = _elapsed;

      _isExpanded = !_isExpanded;
      _cardSize = _isExpanded ? MediaQuery.sizeOf(context) : _defaultCardSize;
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      // backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapDown: _handleTap,
          child: ShaderBuilder((context, shader, child) {
            return AnimatedSampler(
              (image, size, canvas) {
                shader
                  ..setFloat(0, size.width)
                  ..setFloat(1, size.height)
                  ..setFloat(2, _mouse.dx)
                  ..setFloat(3, _mouse.dy)
                  ..setFloat(4, _elapsed)
                  ..setFloat(5, _tapTime)
                  ..setImageSampler(0, image);
                final paint = Paint()..shader = shader;

                canvas.drawRect(
                  Rect.fromLTWH(0, 0, size.width, size.height),
                  paint,
                );
              },
              child: Center(
                child: Column(
                  mainAxisSize: .min,
                  children: [
                    AnimatedContainer(
                      duration: Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      height: size.height * 0.5,
                      width: size.width * 0.8,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/image1.jpg'),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    SizedBox(height: 50),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }, assetKey: 'shaders/ripple_effect2.frag'),
        ),
      ),
    );
  }
}
