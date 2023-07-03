import 'package:flutter/material.dart';

typedef MyBuilder = void Function(
    BuildContext context, void Function() runAnimation);

class LikeAnimation extends StatefulWidget {
  final MyBuilder builder;
  final double size;
  const LikeAnimation(this.size, {required this.builder, Key? key})
      : super(key: key);

  @override
  State<LikeAnimation> createState() => LikeAnimationState();
}

class LikeAnimationState extends State<LikeAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
      duration: const Duration(milliseconds: 400), vsync: this, value: 1.0);

  bool _showIcon = false;

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void runAnimation() {
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showIcon = false;
        });
      }
    });
    setState(() {
      _showIcon = true;
    });
    _controller.reverse().then((value) => _controller.forward());
  }

  @override
  Widget build(BuildContext context) {
    widget.builder.call(context, runAnimation);
    return Center(
        child: ScaleTransition(
      scale: Tween(begin: 0.5, end: 1.0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: _showIcon
          ? Icon(
              Icons.favorite,
              size: widget.size,
              color: Colors.red,
            )
          : const SizedBox(),
    ));
  }
}
