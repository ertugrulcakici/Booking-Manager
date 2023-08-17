import 'package:flutter/material.dart';

import '../../core/services/navigation/navigation_service.dart';

class AnimatedInfoDialog extends StatefulWidget {
  final String title;
  final bool isSuccessful;
  const AnimatedInfoDialog(
      {super.key, required this.title, required this.isSuccessful});

  @override
  State<AnimatedInfoDialog> createState() => AnimatedInfoDialogState();
}

class AnimatedInfoDialogState extends State<AnimatedInfoDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  final double _animationStartValue = 0.8;
  final Duration _animationDuration = const Duration(milliseconds: 500);
  final Duration _animationReverseDuration = const Duration(milliseconds: 100);

  final Duration _contentDelayTime = const Duration(seconds: 1);

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: _animationDuration,
      reverseDuration: _animationReverseDuration,
      lowerBound: 0,
      upperBound: 1,
    );

    _animation = CurvedAnimation(
        parent: _controller,
        curve: Curves.decelerate,
        reverseCurve: Curves.easeOut);

    _startAnimation();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: _animationDuration,
      scale: _animation.value,
      child: AlertDialog(
        title: Text(widget.title),
        icon: Icon(
          widget.isSuccessful ? Icons.check_circle : Icons.error,
          color: widget.isSuccessful ? Colors.green : Colors.red,
        ),
      ),
    );
  }

  void _startAnimation() async {
    _animation.addListener(() {
      setState(() {});
    });
    final tickerFuture = _controller.forward(from: _animationStartValue);
    late final TickerFuture reversedTickerFuture;
    await tickerFuture.whenComplete(() async {
      await Future.delayed(_contentDelayTime);
      reversedTickerFuture = _controller.reverse();
    });
    await reversedTickerFuture.whenComplete(() {
      NavigationService.back();
    });
  }
}
