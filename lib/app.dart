import 'package:flutter/material.dart';
import 'package:flutter_awesome_shaders/ripple_effect/pages/ripple_effect_page.dart';

class FlutterAwesomeShaderApp extends StatelessWidget {
  const FlutterAwesomeShaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Awesome Shader',
      home: RippleEffectPage(),
    );
  }
}
